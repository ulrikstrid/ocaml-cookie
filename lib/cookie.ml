module Date = Date

type header = string * string

let header_of_string str =
  let len = String.length str in
  (* Check if the string is longer than "Cookie: "*)
  if len > 8 && String.sub str 0 8 |> String.lowercase_ascii = "cookie: " then
    Some ("Cookie", String.sub str 8 (len - 8))
    (* Check if the string is longer than "Set-Cookie: "*)
  else if
    len > 12 && String.sub str 0 12 |> String.lowercase_ascii = "set-cookie: "
  then Some ("Set-Cookie", String.sub str 12 (len - 12))
  else None

type expires = [ `Session | `MaxAge of int64 | `Date of Ptime.t ]

let expires_of_tuple (key, value) =
  String.lowercase_ascii key |> function
  | "max-age" -> Some (`MaxAge (Int64.of_string value))
  | "expires" ->
      print_endline value;
      Date.parse value |> Result.get_ok |> Ptime.of_date_time
      |> Option.map (fun e ->
             let () =
               Format.asprintf "expires: %a" Ptime.pp e |> print_endline
             in
             `Date e)
  | "session" -> Some `Session
  | _ -> None

type same_site = [ `None | `Strict | `Lax ]

type cookie = string * string

type t = {
  expires : expires;
  scope : Uri.t;
  same_site : same_site;
  secure : bool;
  http_only : bool;
  value : cookie;
}

let make ?(expires = `Session) ?(scope = Uri.empty) ?(same_site = `Lax)
    ?(secure = false) ?(http_only = true) value =
  { expires; scope; same_site; secure; http_only; value }

let of_set_cookie_header ?origin:_ ((_, value) : header) =
  let () = print_endline ("of_set_cookie_header: " ^ value) in

  match Base.String.lsplit2 value ~on:';' with
  | None ->
      Util.Option.flat_map
        (fun (k, v) ->
          print_endline (k ^ "--" ^ v);
          if String.trim k = "" then None
          else Some (make (String.trim k, String.trim v)))
        (Base.String.lsplit2 value ~on:'=')
  | Some (cookie, attrs) ->
      Util.Option.flat_map
        (fun (k, v) ->
          print_endline (k ^ "--" ^ v);
          if k = "" then None
          else
            let value = (String.trim k, String.trim v) in
            let attrs =
              String.split_on_char ';' attrs
              |> List.map String.trim |> Attributes.list_to_map
            in
            let expires =
              Attributes.AMap.find_last_opt (( = ) "max-age") attrs
              |> Util.Option.map_none
                   (Attributes.AMap.find_last_opt (( = ) "expires") attrs)
              |> Util.Option.flat_map expires_of_tuple
            in
            let secure = Attributes.AMap.key_exists ~key:"secure" attrs in
            let http_only = Attributes.AMap.key_exists ~key:"http_only" attrs in
            let domain : string option =
              Attributes.AMap.find_last_opt (( = ) "domain") attrs
              |> Option.map snd
            in
            let path : string option =
              Attributes.AMap.find_last_opt (( = ) "path") attrs
              |> Option.map snd
            in
            let scope : Uri.t =
              Uri.empty |> fun uri ->
              Uri.with_host uri domain |> fun uri ->
              Uri.with_path uri (Util.Option.get_default ~default:"/" path)
            in

            let () = print_endline ("cookie_scope: " ^ Uri.to_string scope) in
            let () =
              print_endline ("cookie value: " ^ fst value ^ "=" ^ snd value)
            in
            Some (make ?expires ~scope ~secure ~http_only value))
        (Base.String.lsplit2 cookie ~on:'=')

let to_set_cookie_header t = ("Set-Cookie", fst t.value ^ "=" ^ snd t.value)

let is_expired ?now t =
  match now with
  | None -> false
  | Some than -> (
      match t.expires with `Date e -> Ptime.is_earlier ~than e | _ -> false )

let is_not_expired ?now t = not (is_expired ?now t)

let is_too_old ?(elapsed = Int64.of_int 0) t =
  match t.expires with
  | `MaxAge max_age ->
      if max_age <= elapsed then
        let () = print_endline "too old" in
        true
      else false
  | _ -> false

let is_not_too_old ?(elapsed = Int64.of_int 0) t = not (is_too_old ~elapsed t)

let has_matching_domain ~scope t =
  let () =
    Uri.host t.scope
    |> Option.iter (fun h -> print_endline ("has_matching_domain: " ^ h))
  in
  match (Uri.host scope, Uri.host t.scope) with
  | Some domain, Some cookie_domain ->
      let () =
        print_endline ("has_matching_domain: " ^ domain ^ "=" ^ cookie_domain)
      in
      if
        String.contains cookie_domain '.'
        && ( Base.String.is_suffix domain ~suffix:cookie_domain
           || domain = cookie_domain )
      then
        let () = print_endline "domain matching" in
        true
      else false
  | _ -> true

let has_matching_path ~scope t =
  let cookie_path = Uri.path t.scope in
  if cookie_path = "/" then true
  else
    let path = Uri.path scope in
    let () = print_endline (cookie_path ^ " sub of " ^ path) in
    Base.String.is_substring_at ~pos:0 ~substring:cookie_path path
    || cookie_path = path

let is_secure ~scope t =
  match Uri.scheme scope with
  | Some "http" -> not t.secure
  | Some "https" -> true
  | _ -> not t.secure

let to_cookie_header ?now ?(elapsed = Int64.of_int 0)
    ?(scope = Uri.of_string "/") tl =
  if List.length tl = 0 then ("", "")
  else
    let () = print_endline ("scope: " ^ Uri.to_string scope) in
    let () =
      print_endline ("cookies length: " ^ (List.length tl |> string_of_int))
    in
    let idx = ref 0 in
    let cookie_map : string CookieMap.t =
      tl
      |> List.filter (fun c ->
             is_not_expired ?now c
             && has_matching_domain ~scope c
             && has_matching_path ~scope c && is_secure ~scope c)
      |> List.fold_left
           (fun m c ->
             idx := !idx + 1;
             let key, _value = c.value in

             CookieMap.update (!idx, key)
               (fun v ->
                 let () =
                   if Base.Option.is_some v then
                     print_endline (key ^ " replaced")
                   else print_endline (key ^ " not replaced")
                 in
                 Some c)
               m)
           CookieMap.empty
      |> CookieMap.filter_value (is_not_too_old ~elapsed)
      |> CookieMap.map (fun c -> snd c.value)
    in

    if CookieMap.is_empty cookie_map then ("", "")
    else
      ( "Cookie",
        CookieMap.fold
          (fun (_idx, key) value l -> (key, value) :: l)
          cookie_map []
        |> List.rev
        |> List.map (fun (key, value) -> Printf.sprintf "%s=%s" key value)
        |> String.concat "; "
        |> fun s ->
        print_endline ("cookie: " ^ s);
        s )

let cookie_of_cookie_header (_, value) =
  match String.split_on_char '=' value with
  | key :: value -> (key, String.concat "" value)
  | _ -> raise Not_found
