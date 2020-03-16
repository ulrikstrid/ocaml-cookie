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
   )
)

(package
   (name session-cookie)
   (depends
      (ocaml (>= 4.06.0))
      cookie
      session
   )
)

(package
   (name session-cookie-async)
   (depends
      (ocaml (>= 4.06.0))
      session-cookie
      async
   )
)

(package
   (name session-cookie-lwt)
   (depends
      (ocaml (>= 4.06.0))
      session-cookie
      lwt
   )
)
