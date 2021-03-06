open Helpers

let cases =
  [
    "foo=bar; Expires=Mon, 16 Nov 2020 08:04:19 UTC";
    "foo=bar; Path=/";
    "foo=bar; Domain=example.com";
    "foo=bar; Max-Age=60";
    "foo=bar; Max-Age=60; Secure";
    "foo=bar; Max-Age=60; HttpOnly";
    "foo=bar; Path=/; Expires=Mon, 16 Nov 2020 08:04:19 UTC";
    "foo=bar; Domain=example.com; Expires=Mon, 16 Nov 2020 08:04:19 UTC";
    "foo=bar; Domain=example.com; Max-Age=60";
  ]

let tests =
  ( "Set-Cookie",
    [
      Alcotest.test_case "roundtrip - multiple Expires" `Quick (fun () ->
          let input =
            "foo=bar; Domain=example.com; Expires=Mon, 16 Nov 2020 08:04:19 \
             UTC; Expires=Sun, 15 Nov 2020 08:04:19 UTC"
          in
          let expected =
            "foo=bar; Domain=example.com; Expires=Sun, 15 Nov 2020 08:04:19 UTC"
          in
          let test =
            Cookie.of_set_cookie_header ("Set-Cookie", input)
              ~origin:"home.example.org"
            |> Base.Option.map ~f:Cookie.to_set_cookie_header
            |> Base.Option.map ~f:snd
          in
          check_option_string "value" (Some expected) test);
      Alcotest.test_case "roundtrip - multiple Max-Age" `Quick (fun () ->
          let input = "foo=bar; Domain=example.com; Max-Age=60; Max-Age=0" in
          let expected = "foo=bar; Domain=example.com; Max-Age=0" in
          let test =
            Cookie.of_set_cookie_header ("Set-Cookie", input)
              ~origin:"home.example.org"
            |> Base.Option.map ~f:Cookie.to_set_cookie_header
            |> Base.Option.map ~f:snd
          in
          check_option_string "value" (Some expected) test);
      Alcotest.test_case "roundtrip - trailing =" `Quick (fun () ->
          let input = "foo=bar; Max-Age=60; HttpOnly=" in
          let expected = "foo=bar; Max-Age=60; HttpOnly" in
          let test =
            Cookie.of_set_cookie_header ("Set-Cookie", input)
              ~origin:"home.example.org"
            |> Base.Option.map ~f:Cookie.to_set_cookie_header
            |> Base.Option.map ~f:snd
          in
          check_option_string "value" (Some expected) test);
      Alcotest.test_case "roundtrip - . before domain" `Quick (fun () ->
          let input = "foo=bar; Domain=.example.com" in
          let expected = "foo=bar; Domain=example.com" in
          let test =
            Cookie.of_set_cookie_header ("Set-Cookie", input)
              ~origin:"home.example.org"
            |> Base.Option.map ~f:Cookie.to_set_cookie_header
            |> Base.Option.map ~f:snd
          in
          check_option_string "value" (Some expected) test);
      Alcotest.test_case "roundtrip - .. before domain" `Quick (fun () ->
          let input = "foo=bar; Domain=..example.com" in
          let expected = "foo=bar" in
          let test =
            Cookie.of_set_cookie_header ("Set-Cookie", input)
              ~origin:"home.example.org"
            |> Base.Option.map ~f:Cookie.to_set_cookie_header
            |> Base.Option.map ~f:snd
          in
          check_option_string "value" (Some expected) test);
      Alcotest.test_case "roundtrip - . after domain" `Quick (fun () ->
          let input = "foo=bar; Domain=example.com." in
          let expected = "foo=bar" in
          let test =
            Cookie.of_set_cookie_header ("Set-Cookie", input)
              ~origin:"home.example.org"
            |> Base.Option.map ~f:Cookie.to_set_cookie_header
            |> Base.Option.map ~f:snd
          in
          check_option_string "value" (Some expected) test);
      Alcotest.test_case "roundtrip - custom value" `Quick (fun () ->
          let input = "foo=bar; customvalue=example.com" in
          let expected = "foo=bar" in
          let test =
            Cookie.of_set_cookie_header ("Set-Cookie", input)
              ~origin:"home.example.org"
            |> Base.Option.map ~f:Cookie.to_set_cookie_header
            |> Base.Option.map ~f:snd
          in
          check_option_string "value" (Some expected) test);
      Alcotest.test_case "roundtrip - extra empty - 1" `Quick (fun () ->
          let input = "foo=bar; =example.com" in
          let expected = "foo=bar" in
          let test =
            Cookie.of_set_cookie_header ("Set-Cookie", input)
              ~origin:"home.example.org"
            |> Base.Option.map ~f:Cookie.to_set_cookie_header
            |> Base.Option.map ~f:snd
          in
          check_option_string "value" (Some expected) test);
      Alcotest.test_case "roundtrip - extra empty - 2" `Quick (fun () ->
          let input = "foo=bar; =" in
          let expected = "foo=bar" in
          let test =
            Cookie.of_set_cookie_header ("Set-Cookie", input)
              ~origin:"home.example.org"
            |> Base.Option.map ~f:Cookie.to_set_cookie_header
            |> Base.Option.map ~f:snd
          in
          check_option_string "value" (Some expected) test);
    ]
    @ List.mapi
        (fun i expected ->
          Alcotest.test_case
            ("roundtrip - " ^ string_of_int i)
            `Quick
            (fun () ->
              let test =
                Cookie.of_set_cookie_header ("Set-Cookie", expected)
                  ~origin:"home.example.org"
                |> Base.Option.map ~f:Cookie.to_set_cookie_header
                |> Base.Option.map ~f:snd
              in
              check_option_string "value" (Some expected) test))
        cases )

let suite, _ =
  Junit_alcotest.run_and_report ~package:"cookie" "Set-Cookie" [ tests ]
