(* Tests from https://github.com/abarth/http-state, IETF's http-state working group *)
open Helpers

let test_names =
  Sys.readdir "./fixtures" |> Array.to_list
  |> Base.List.filter ~f:(fun file ->
         not (Astring.String.is_prefix ~affix:"disabled" file))
  |> Base.List.filter ~f:(Astring.String.is_suffix ~affix:"-test")
  |> Base.List.map ~f:(fun str ->
         Astring.String.take ~rev:false str ~max:(Astring.String.length str - 5))
  |> Base.List.sort ~compare:String.compare

let file_to_lines file_path =
  let rec rl prev_lines ic =
    try rl (input_line ic :: prev_lines) ic
    with End_of_file -> Base.List.rev prev_lines
  in
  rl [] (open_in_bin file_path)

let test_header_of_string str =
  let len = String.length str in
  (* Check if the string is longer than "Cookie: "*)
  if len > 10 && String.sub str 0 10 |> String.lowercase_ascii = "location: "
  then Some ("Location", String.sub str 10 (len - 10))
  else Cookie.header_of_string str

let tests =
  ( "Fixtures",
    test_names
    |> Base.List.map ~f:(fun name ->
           Alcotest.test_case name `Quick (fun () ->
               let expected =
                 file_to_lines ("./fixtures/" ^ name ^ "-expected")
                 |> Base.List.filter_map ~f:Cookie.header_of_string
                 |> hd_safe ~default:("", "")
               in
               let test_headers =
                 file_to_lines ("./fixtures/" ^ name ^ "-test")
                 |> Base.List.filter_map ~f:test_header_of_string
               in
               let scope =
                 Base.List.filter_map
                   ~f:(fun (key, value) ->
                     let () = print_endline (key ^ ": " ^ value) in
                     if key = "Location" then Some (Uri.of_string value)
                     else None)
                   test_headers
                 |> hd_safe
                      ~default:
                        (Uri.of_string
                           ("http://home.example.org:8888/cookie-parser?" ^ name))
               in
               let () =
                 print_endline ("passed scope: " ^ Uri.to_string scope)
               in
               let set_cookie_headers =
                 Base.List.filter_map
                   ~f:(fun (key, value) ->
                     let () = print_endline (key ^ ": " ^ value) in
                     if key = "Set-Cookie" then Some (key, value) else None)
                   test_headers
                 |> Base.List.filter_map
                      ~f:(Cookie.of_set_cookie_header ~origin:"home.example.org")
               in
               let now =
                   Base.Option.( Cookie.Date.parse "Wen, 28 Feb 2018 08:04:19 GMT"
                   |> opt_of_result
                   >>= Ptime.of_date_time )
               in
               let test =
                 set_cookie_headers |> Cookie.to_cookie_header ?now ~scope
               in
               check_string "value" (snd expected) (snd test);
               check_string "key" (fst expected) (fst test))) )

let suite, _ =
  Junit_alcotest.run_and_report ~package:"cookie" "http-state" [ tests ]
