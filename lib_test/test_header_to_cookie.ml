open Helpers

let tests =
  ( "Date",
    [
      Alcotest.test_case "cookies_of_header" `Quick (fun () ->
          let header = ("Cookie", "foo=bar; baz=qux") in
          let cookies = Cookie.cookies_of_header header in
          List.iteri
            (fun idx (key, value) ->
              match idx with
              | 0 ->
                  check_string "first key" key "foo";
                  check_string "first value" value "bar"
              | 1 ->
                  check_string "second key" key "baz";
                  check_string "second value" value "qux"
              | _ -> raise_notrace (Failure "Too many items in list"))
            cookies);
      Alcotest.test_case "cookies_of_header - 1" `Quick (fun () ->
          let header = ("Cookie", "foo=bar") in
          let cookies = Cookie.cookies_of_header header in
          List.iteri
            (fun idx (key, value) ->
              match idx with
              | 0 ->
                  check_string "first key" key "foo";
                  check_string "first value" value "bar"
              | _ -> raise_notrace (Failure "Too many items in list"))
            cookies);
      Alcotest.test_case "cookies_of_header, space in value" `Quick (fun () ->
          let header = ("Cookie", "foo= bar; baz= qux ") in
          let cookies = Cookie.cookies_of_header header in
          List.iteri
            (fun idx (key, value) ->
              match idx with
              | 0 ->
                  check_string "first key" key "foo";
                  check_string "first value" value "bar"
              | 1 ->
                  check_string "second key" key "baz";
                  check_string "second value" value "qux"
              | _ -> raise_notrace (Failure "Too many items in list"))
            cookies);
      Alcotest.test_case "cookies_of_header, citation" `Quick (fun () ->
          let header = ("Cookie", {|foo=bar; baz=" qux ";|}) in
          let cookies = Cookie.cookies_of_header header in
          List.iteri
            (fun idx (key, value) ->
              match idx with
              | 0 ->
                  check_string "first key" key "foo";
                  check_string "first value" value "bar"
              | 1 ->
                  check_string "second key" key "baz";
                  check_string "second value" value {|" qux "|}
              | _ -> raise_notrace (Failure "Too many items in list"))
            cookies);
    ] )

let suite, _ =
  Junit_alcotest.run_and_report ~package:"cookie" "Cookie.cookies_of_header"
    [ tests ]
