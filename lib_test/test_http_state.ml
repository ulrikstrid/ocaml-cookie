(* Tests from https://github.com/abarth/http-state, IETF's http-state working group *)
open Helpers

let test_names =
  Sys.readdir "./fixtures" |> Array.to_list
  |> List.filter (fun file ->
         not (Astring.String.is_prefix ~affix:"disabled" file))
  |> List.filter (Astring.String.is_suffix ~affix:"-test")
  |> List.map (fun str ->
         Astring.String.take ~rev:false str ~max:(Astring.String.length str - 5))
  |> List.sort String.compare

let file_to_lines file_path =
  let rec rl prev_lines ic =
    try rl (input_line ic :: prev_lines) ic
    with End_of_file -> List.rev prev_lines
  in
  rl [] (open_in_bin file_path)

let now =
  Ptime.of_date_time
    (Cookie.Date.parse "Wen, 28 Feb 2018 08:04:19 GMT" |> Result.get_ok)

let test_header_of_string str =
  let len = String.length str in
  (* Check if the string is longer than "Cookie: "*)
  if len > 10 && String.sub str 0 10 |> String.lowercase_ascii = "location: "
  then Some ("Location", String.sub str 10 (len - 10))
  else Cookie.header_of_string str

let hd_safe ~default l = try List.hd l with Failure _ -> default

let tests =
  ( "Fixtures",
    test_names
    |> List.map (fun name ->
           Alcotest.test_case name `Quick (fun () ->
               let expected =
                 file_to_lines ("./fixtures/" ^ name ^ "-expected")
                 |> List.filter_map Cookie.header_of_string
                 |> hd_safe ~default:("", "")
               in
               let test_headers =
                 file_to_lines ("./fixtures/" ^ name ^ "-test")
                 |> List.filter_map test_header_of_string
               in
               let scope =
                 List.filter_map
                   (fun (key, value) ->
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
                 List.filter_map
                   (fun (key, value) ->
                     let () = print_endline (key ^ ": " ^ value) in
                     if key = "Set-Cookie" then Some (key, value) else None)
                   test_headers
                 |> List.filter_map
                      (Cookie.of_set_cookie_header ~origin:"home.example.org")
               in
               let test =
                 set_cookie_headers |> Cookie.to_cookie_header ?now ~scope
               in
               check_string "value" (snd expected) (snd test);
               check_string "key" (fst expected) (fst test))) )

let suite, _ =
  Junit_alcotest.run_and_report ~package:"cookie" "http-state" [ tests ]
