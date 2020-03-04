module AMap = struct
  include Map.Make (String)

  let key_exists ~key map = exists (fun k _ -> k = key) map
end

let force_set v _ = Some v

let keep_numbers s =
  Base.String.filter
    ~f:(fun c ->
      let code = Char.code c in
      if code = 45 || (code >= 48 && code <= 57) then true else false)
    s

let is_invalid_char c = c = ';' || c = '"'

let is_valid_char c = not (is_invalid_char c)

let set_attributes amap attr =
  match attr with
  | [] | [ ""; _ ] | [ "" ] | "" :: _ | "version" :: _ -> amap
  | [ key ] when String.lowercase_ascii key |> String.trim = "httponly" ->
      AMap.update "http_only" (force_set "") amap
  | key :: _ when String.lowercase_ascii key |> String.trim = "httponly" ->
      AMap.update "http_only" (force_set "") amap
  | [ key ] when String.lowercase_ascii key |> String.trim = "secure" ->
      AMap.update "secure" (force_set "") amap
  | key :: _ when String.lowercase_ascii key |> String.trim = "secure" ->
      AMap.update "secure" (force_set "") amap
  | key :: value when String.lowercase_ascii key |> String.trim = "path" ->
      AMap.update "path"
        (force_set
           ( String.concat "" value |> String.trim
           |> Base.String.filter ~f:is_valid_char ))
        amap
  | key :: value when String.lowercase_ascii key |> String.trim = "domain" ->
      let domain =
        value |> String.concat "" |> String.trim
        |> Util.String.chop_prefix ~prefix:"."
        |> String.lowercase_ascii
      in
      if
        domain = ""
        || Base.String.is_suffix domain ~suffix:"."
        || Base.String.is_prefix domain ~prefix:"."
      then amap
      else AMap.update "domain" (force_set domain) amap
  | key :: value when String.lowercase_ascii key |> String.trim = "expires" ->
      let expires = String.concat "" value |> String.trim in
      AMap.update "expires" (force_set expires) amap
  | [ key; value ] when String.lowercase_ascii key = "max-age" ->
      AMap.update "max-age" (force_set (keep_numbers value)) amap
  | _ -> amap

let list_to_map attrs =
  let amap : string AMap.t = AMap.empty in
  attrs
  |> List.map (String.split_on_char '=')
  |> List.fold_left set_attributes amap
