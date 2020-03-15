(lang dune 1.11)
(name cookie)
(license BSD3-clause)
(source (github ulrikstrid/ocaml-cookie))
(homepage https://ulrikstrid.github.io/ocaml-cookie)
(documentation https://ulrikstrid.github.io/ocaml-cookiee)
(authors "Ulrik Strid")
(maintainers "ulrik.strid@outlook.com")

(generate_opam_files true)

(using fmt 1.2)

(package
(name cookie)
(depends
   (ocaml (>= 4.06.0))
   astring
   (bisect_ppx :with-test)
   (alcotest :with-test)
   (junit :with-test)
   (junit_alcotest :with-test)
)
)

(package
(name session-cookie)
(depends
   (ocaml (>= 4.06.0))
   cookie
   session
   (bisect_ppx :with-test)
   (alcotest :with-test)
   (junit :with-test)
   (junit_alcotest :with-test)
)
)

(package
(name session-cookie-async)
(depends
   (ocaml (>= 4.06.0))
   session-cookie
   async
   (bisect_ppx :with-test)
   (alcotest :with-test)
   (junit :with-test)
   (junit_alcotest :with-test)
)
)

(package
(name session-cookie-lwt)
(depends
   (ocaml (>= 4.06.0))
   session-cookie
   lwt
   (bisect_ppx :with-test)
   (alcotest :with-test)
   (junit :with-test)
   (junit_alcotest :with-test)
)
)
