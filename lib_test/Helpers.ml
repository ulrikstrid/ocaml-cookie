let result_t : [> `Msg of string | `Malformed ] Alcotest.testable =
  let pp ppf = function
    | `Msg e -> Fmt.string ppf e
    | `Malformed -> Fmt.string ppf "malformed"
  in
  Alcotest.testable pp ( = )

let check_string = Alcotest.(check string)

let check_result_string = Alcotest.(check (result string result_t))

let check_result_bool = Alcotest.(check (result bool result_t))

let check_option_string = Alcotest.(check (option string))

let check_int = Alcotest.(check int)


let opt_of_result = function
| Ok v -> Some v
| _ -> None

let hd_safe ~default l = try Base.List.hd_exn l with Failure _ -> default
