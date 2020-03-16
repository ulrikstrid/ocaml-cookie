let values =
  [
    ("Set-Cookie", "foo=bar; Expires=Mon, 16 Nov 2020 08:04:19 UTC");
    ("Set-Cookie", "foo=bar; Path=/");
    ("Set-Cookie", "foo=bar; Domain=example.com");
    ("Set-Cookie", "foo=bar; Max-Age=60");
    ("Set-Cookie", "foo=bar; Max-Age=60; Secure");
    ("Set-Cookie", "foo=bar; Max-Age=60; HttpOnly");
    ("Set-Cookie", "foo=bar; Path=/; Expires=Mon, 16 Nov 2020 08:04:19 UTC");
    ( "Set-Cookie",
      "foo=bar; Domain=example.com; Expires=Mon, 16 Nov 2020 08:04:19 UTC" );
    ("Set-Cookie", "foo=bar; Domain=example.com; Max-Age=60");
    ( "Set-Cookie",
      "foo=bar; Domain=example.com; Expires=Mon, 16 Nov 2020 08:04:19 UTC; \
       Expires=Sun, 15 Nov 2020 08:04:19 UTC" );
    ("Set-Cookie", "foo=bar; Domain=example.com; Max-Age=60; Max-Age=0");
    ("Set-Cookie", "foo=bar; Max-Age=60; HttpOnly=");
    ("Set-Cookie", "foo=bar; Domain=.example.com");
    ("Set-Cookie", "foo=bar; Domain=..example.com");
    ("Set-Cookie", "foo=bar; Domain=example.com.");
    ("Set-Cookie", "foo=bar; customvalue=example.com");
    ("Set-Cookie", "foo=bar; =example.com");
    ("Set-Cookie", "foo=bar; =");
  ]

let bench_parse =
  List.iter (fun header ->
      Cookie.of_set_cookie_header ~origin:"home.example.org" header |> ignore)

let bench =
  let open Core_bench in
  Bench.Test.create ~name:"Parse Bench" (fun () -> bench_parse values)

let benches = [ bench ]
