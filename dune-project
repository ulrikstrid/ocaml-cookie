(lang dune 1.11)
(name cookie)
(license BSD3-clause)
(source (github ulrikstrid/ocaml-cookie))
(homepage https://ulrikstrid.github.io/ocaml-cookie)
(documentation https://ulrikstrid.github.io/ocaml-cookie)
(authors "Ulrik Strid")
(maintainers "ulrik.strid@outlook.com")
(version 0.1.8)

(generate_opam_files true)

(using fmt 1.2)

(package
   (name cookie)
   (synopsis "Cookie handling for OCaml and ReasonML")
   (description "Parsing and printing cookies in OCaml and Reason")
   (depends
      (ocaml (>= 4.07.0))
      uri
      ptime
      astring
      (alcotest :with-test)
      (junit :with-test)
      (junit_alcotest :with-test)
   )
)

(package
   (name session-cookie)
   (synopsis "Session handling for OCaml and ReasonML")
   (description "Session implementation using the cookie library")
   (depends
      (ocaml (>= 4.07.0))
      (cookie (= :version))
      session
      (alcotest :with-test)
      (junit :with-test)
      (junit_alcotest :with-test)
   )
)

(package
   (name session-cookie-async)
   (synopsis "Session handling for OCaml and ReasonML")
   (description "Session implementation using the cookie library with async support")
   (depends
      (ocaml (>= 4.07.0))
      (session-cookie (= :version))
      async
      (alcotest :with-test)
      (junit :with-test)
      (junit_alcotest :with-test)
   )
)

(package
   (name session-cookie-lwt)
   (synopsis "Session handling for OCaml and ReasonML")
   (description "Session implementation using the cookie library with lwt support")
   (depends
      (ocaml (>= 4.07.0))
      (session-cookie (= :version))
      lwt
      (alcotest :with-test)
      (junit :with-test)
      (junit_alcotest :with-test)
   )
)
