let () =
  let path = Sys.getenv_opt "REPORT_PATH" in
  let report =
    Junit.make
      [
        Test_http_state.suite;
        Test_date.suite;
        Test_set_cookie.suite;
        Test_header_to_cookie.suite;
      ]
  in
  match path with Some path -> Junit.to_file report path | None -> ()
