type date_time = Ptime.date * Ptime.time

let int_of_month month =
  String.lowercase_ascii month |> function
  | "jan" -> 1
  | "feb" -> 2
  | "mar" -> 3
  | "apr" -> 4
  | "may" -> 5
  | "jun" -> 6
  | "jul" -> 7
  | "aug" -> 8
  | "sep" -> 9
  | "oct" -> 10
  | "nov" -> 11
  | "dec" -> 12
  | _ -> 1

let month_of_int = function
  | 1 -> "Jan"
  | 2 -> "Feb"
  | 3 -> "Mar"
  | 4 -> "Apr"
  | 5 -> "May"
  | 6 -> "Jun"
  | 7 -> "Jul"
  | 8 -> "Aug"
  | 9 -> "Sep"
  | 10 -> "Oct"
  | 11 -> "Nov"
  | 12 -> "Dec"
  | _ -> "Jan"

type time_zone = GMT | UTC

let time_zone_of_string = function "GMT" -> GMT | "UTC" -> UTC | _ -> UTC

let int_of_time_zone = function GMT -> 0 | UTC -> 0

(* Fri, 07 Aug 2007 08:04:19 GMT *)
let parse str =
  let len = String.length str in
  if len = 29 then
    let day = String.sub str 5 2 |> int_of_string in
    let month = String.sub str 8 3 |> int_of_month in
    let year = String.sub str 12 4 |> int_of_string in
    let hour = String.sub str 17 2 |> int_of_string in
    let minute = String.sub str 20 2 |> int_of_string in
    let second = String.sub str 23 2 |> int_of_string in
    let time_zone =
      String.sub str 26 3 |> time_zone_of_string |> int_of_time_zone
    in
    let date = (year, month, day) in
    let time = ((hour, minute, second), time_zone) in
    Ok (date, time)
  else Error `Malformed

type weekday = [ `Fri | `Mon | `Sat | `Sun | `Thu | `Tue | `Wed ]

let string_of_weekday = function
  | `Mon -> "Mon"
  | `Tue -> "Tue"
  | `Wed -> "Wed"
  | `Thu -> "Thu"
  | `Fri -> "Fri"
  | `Sat -> "Sat"
  | `Sun -> "Sun"

let zero_pad ~len str =
  let pad = len - String.length str in
  if pad > 0 then
    List.init (pad + 1) (fun i -> if i = pad then str else "0")
    |> String.concat ""
  else str

(* Fri, 07 Aug 2007 08:04:19 GMT *)
let serialize date_time =
  let ptime = Ptime.of_date_time date_time |> Option.get in
  let weekday = Ptime.weekday ptime |> string_of_weekday in
  let (year, month, day), ((hour, minute, second), _) = date_time in
  Printf.sprintf "%s, %s %s %s %s:%s:%s UTC" weekday
    (day |> string_of_int |> zero_pad ~len:2)
    (month_of_int month) (year |> string_of_int)
    (hour |> string_of_int |> zero_pad ~len:2)
    (minute |> string_of_int |> zero_pad ~len:2)
    (second |> string_of_int |> zero_pad ~len:2)
