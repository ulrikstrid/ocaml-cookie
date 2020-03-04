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
      Date.parse value |> Result.get_ok |> Ptime.of_date_time
      |> Option.map (fun e -> `Date e)
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
  match Base.String.lsplit2 value ~on:';' with
  | None ->
      Util.Option.flat_map
        (fun (k, v) ->
          if String.trim k = "" then None
          else Some (make (String.trim k, String.trim v)))
        (Base.String.lsplit2 value ~on:'=')
  | Some (cookie, attrs) ->
      Util.Option.flat_map
        (fun (k, v) ->
          if k = "" then None
          else
            let value = (String.trim k, String.trim v) in
            let attrs =
              String.split_on_char ';' attrs
              |> List.map String.trim |> Attributes.list_to_map
            in
            let expires =
              Util.Option.first_some
                ( Attributes.AMap.find_opt "expires" attrs
                |> Option.map (fun v -> ("expires", v)) )
                ( Attributes.AMap.find_opt "max-age" attrs
                |> Option.map (fun v -> ("max-age", v)) )
              |> Util.Option.flat_map (fun a -> expires_of_tuple a)
            in
            let secure = Attributes.AMap.key_exists ~key:"secure" attrs in
            let http_only = Attributes.AMap.key_exists ~key:"http_only" attrs in
            let domain : string option =
              Attributes.AMap.find_opt "domain" attrs
            in
            let path = Attributes.AMap.find_opt "path" attrs in
            let scope =
              Uri.empty |> fun uri ->
              Uri.with_host uri domain |> fun uri ->
              Option.map (Uri.with_path uri) path
              |> Util.Option.get_default ~default:uri
            in
            Some (make ?expires ~scope ~secure ~http_only value))
        (Base.String.lsplit2 cookie ~on:'=')

let to_set_cookie_header t =
  let v = Printf.sprintf "%s=%s" (fst t.value) (snd t.value) in
  let v =
    match Uri.path t.scope with
    | "" -> v
    | path -> Printf.sprintf "%s; Path=%s" v path
  in
  let v =
    match Uri.host t.scope with
    | None -> v
    | Some domain -> Printf.sprintf "%s; Domain=%s" v domain
  in
  let v =
    match t.expires with
    | `Date ptime ->
        Printf.sprintf "%s; Expires=%s" v
          (Ptime.to_date_time ptime |> Date.serialize)
    | `MaxAge max -> Printf.sprintf "%s; Max-Age=%s" v (Int64.to_string max)
    | `Session -> v
  in
  ("Set-Cookie", v)

let is_expired ?now t =
  match now with
  | None -> false
  | Some than -> (
      match t.expires with `Date e -> Ptime.is_earlier ~than e | _ -> false )

let is_not_expired ?now t = not (is_expired ?now t)

let is_too_old ?(elapsed = Int64.of_int 0) t =
  match t.expires with
  | `MaxAge max_age -> if max_age <= elapsed then true else false
  | _ -> false

let is_not_too_old ?(elapsed = Int64.of_int 0) t = not (is_too_old ~elapsed t)

let has_matching_domain ~scope t =
  match (Uri.host scope, Uri.host t.scope) with
  | Some domain, Some cookie_domain ->
      if
        String.contains cookie_domain '.'
        && ( Base.String.is_suffix domain ~suffix:cookie_domain
           || domain = cookie_domain )
      then true
      else false
  | _ -> true

let has_matching_path ~scope t =
  let cookie_path = Uri.path t.scope in
  if cookie_path = "/" then true
  else
    let path = Uri.path scope in
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

             CookieMap.update (!idx, key) (fun _ -> Some c) m)
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
        |> String.concat "; " )

let cookie_of_cookie_header (_, value) =
  match String.split_on_char '=' value with
  | key :: value -> (key, String.concat "" value)
  | _ -> raise Not_found
