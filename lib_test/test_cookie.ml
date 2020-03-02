let () =
  let path = Sys.getenv_opt "REPORT_PATH" in
  let report = Junit.make [ Test_date.suite; Test_http_state.suite ] in
  match path with Some path -> Junit.to_file report path | None -> ()
