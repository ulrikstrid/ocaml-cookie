open Core
open Core_bench

let () =
  let benches = List.concat [ Parse.benches ] in
  Command.run @@ Bench.make_command benches
