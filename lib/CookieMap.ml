module OrderedCookie = struct
  type t = int * string

  let compare (c1, s1) (c2, s2) =
    if String.equal s1 s2 then 0 else Util.Int.compare c1 c2
end

include Map.Make (OrderedCookie)

let filter_value (fn : 'a -> bool) (map : 'a t) =
  filter (fun _key v -> fn v) map
