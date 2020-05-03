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
          let expected = "Mon, 06 Jan 2020 08:04:19 UTC" in
          check_result_string expected (Ok expected)
            (Base.Result.map ~f:Cookie.Date.serialize
               (Cookie.Date.parse expected)));
      Alcotest.test_case "serialize" `Quick (fun () ->
          let expected = "Tue, 11 Feb 2020 09:04:19 UTC" in
          check_result_string "" (Ok expected)
            (Base.Result.map ~f:Cookie.Date.serialize
               (Cookie.Date.parse expected)));
      Alcotest.test_case "serialize" `Quick (fun () ->
          let expected = "Wed, 25 Mar 2020 10:04:19 UTC" in
          check_result_string "" (Ok expected)
            (Base.Result.map ~f:Cookie.Date.serialize
               (Cookie.Date.parse expected)));
      Alcotest.test_case "serialize" `Quick (fun () ->
          let expected = "Thu, 02 Apr 2020 11:04:19 UTC" in
          check_result_string "" (Ok expected)
            (Base.Result.map ~f:Cookie.Date.serialize
               (Cookie.Date.parse expected)));
      Alcotest.test_case "serialize" `Quick (fun () ->
          let expected = "Fri, 01 May 2020 12:04:19 UTC" in
          check_result_string "" (Ok expected)
            (Base.Result.map ~f:Cookie.Date.serialize
               (Cookie.Date.parse expected)));
      Alcotest.test_case "serialize" `Quick (fun () ->
          let expected = "Sat, 27 Jun 2020 13:04:19 UTC" in
          check_result_string "" (Ok expected)
            (Base.Result.map ~f:Cookie.Date.serialize
               (Cookie.Date.parse expected)));
      Alcotest.test_case "serialize" `Quick (fun () ->
          let expected = "Sun, 12 Jul 2020 14:04:19 UTC" in
          check_result_string "" (Ok expected)
            (Base.Result.map ~f:Cookie.Date.serialize
               (Cookie.Date.parse expected)));
      Alcotest.test_case "serialize" `Quick (fun () ->
          let expected = "Mon, 31 Aug 2020 15:04:19 UTC" in
          check_result_string "" (Ok expected)
            (Base.Result.map ~f:Cookie.Date.serialize
               (Cookie.Date.parse expected)));
      Alcotest.test_case "serialize" `Quick (fun () ->
          let expected = "Tue, 22 Sep 2020 16:04:19 UTC" in
          check_result_string "" (Ok expected)
            (Base.Result.map ~f:Cookie.Date.serialize
               (Cookie.Date.parse expected)));
      Alcotest.test_case "serialize" `Quick (fun () ->
          let expected = "Wed, 07 Oct 2020 17:04:19 UTC" in
          check_result_string "" (Ok expected)
            (Base.Result.map ~f:Cookie.Date.serialize
               (Cookie.Date.parse expected)));
      Alcotest.test_case "serialize" `Quick (fun () ->
          let expected = "Thu, 19 Nov 2020 18:04:19 UTC" in
          check_result_string "" (Ok expected)
            (Base.Result.map ~f:Cookie.Date.serialize
               (Cookie.Date.parse expected)));
      Alcotest.test_case "serialize" `Quick (fun () ->
          let expected = "Fri, 25 Dec 2020 19:04:19 UTC" in
          check_result_string "" (Ok expected)
            (Base.Result.map ~f:Cookie.Date.serialize
               (Cookie.Date.parse expected)));
      Alcotest.test_case "serialize" `Quick (fun () ->
          let expected = "Mon, 16 Nov 2020 08:04:19 UTC" in
          check_result_string "" (Ok expected)
            (Base.Result.map ~f:Cookie.Date.serialize
               (Cookie.Date.parse expected)));
    ] )

let suite, _ =
  Junit_alcotest.run_and_report ~package:"cookie" "Cookie.Date" [ tests ]
