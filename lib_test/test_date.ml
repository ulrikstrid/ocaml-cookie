open Helpers

let tests =
  ( "Date",
    [
      Alcotest.test_case "parse" `Quick (fun () ->
          match Cookie.Date.parse "Thu, 27 Feb 2020 08:04:19 UTC" with
          | Error _ -> raise Not_found
          | Ok ((year, month, day), ((hour, minute, second), offset)) ->
              check_int "year" 2020 year;
              check_int "month" 2 month;
              check_int "day" 27 day;
              check_int "hour" 8 hour;
              check_int "minute" 4 minute;
              check_int "second" 19 second;
              check_int "offset" 0 offset);
      Alcotest.test_case "parse" `Quick (fun () ->
          match Cookie.Date.parse "Thu, 27 Feb 2020 08:04:19 UTC" with
          | Error _ -> raise Not_found
          | Ok ((year, month, day), ((hour, minute, second), offset)) ->
              check_int "year" 2020 year;
              check_int "month" 2 month;
              check_int "day" 27 day;
              check_int "hour" 8 hour;
              check_int "minute" 4 minute;
              check_int "second" 19 second;
              check_int "offset" 0 offset);
      Alcotest.test_case "serialize" `Quick (fun () ->
          let expected = "Thu, 27 Feb 2020 08:04:19 UTC" in
          match Cookie.Date.parse expected with
          | Error _ -> raise Not_found
          | Ok date_time ->
              check_string "" expected (Cookie.Date.serialize date_time));
    ] )

let suite, _ =
  Junit_alcotest.run_and_report ~package:"cookie" "Cookie.Date" [ tests ]
