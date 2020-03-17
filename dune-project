(lang dune 1.11)
(name cookie)
(license BSD3-clause)
(source (github ulrikstrid/ocaml-cookie))
(homepage https://ulrikstrid.github.io/ocaml-cookie)
(documentation https://ulrikstrid.github.io/ocaml-cookie)
(authors "Ulrik Strid")
(maintainers "ulrik.strid@outlook.com")

(generate_opam_files true)

(using fmt 1.2)

(package
   (name cookie)
   (synopsis "Cookie handling for OCaml and ReasonML")
   (description "Parsing and printing cookies in OCaml and Reason")
   (depends
      (ocaml (>= 4.08.0))
      uri
      ptime
      astring
   )
)

(package
   (name session-cookie)
   (synopsis "Session handling for OCaml and ReasonML")
   (description "Session implementation using the cookie library")
   (depends
      (ocaml (>= 4.08.0))
      cookie
      session
   )
)

(package
   (name session-cookie-async)
   (synopsis "Session handling for OCaml and ReasonML")
   (description "Session implementation using the cookie library with async support")
   (depends
      (ocaml (>= 4.08.0))
      session-cookie
      async
   )
)

(package
   (name session-cookie-lwt)
   (synopsis "Session handling for OCaml and ReasonML")
   (description "Session implementation using the cookie library with lwt support")
   (depends
      (ocaml (>= 4.08.0))
      session-cookie
      lwt
   )
)
