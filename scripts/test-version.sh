echo '{
    "version": "1.0.0",
    "name": "test",
    "dependencies": {
        "ocaml": "~'"$1"'",
        "@opam/dune": "1.11.0",
        "@opam/cookie": "*"
    },
    "resolutions": {
        "@opam/cookie": "link:./package.json"
    }
}' > "$1.json"

esy -P "$1"
