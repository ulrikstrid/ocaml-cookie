module Option = struct
  let first_some opt value = match opt with Some _ -> opt | None -> value

  let map fn opt = match opt with Some v -> Some (fn v) | None -> None

  let flat_map fn opt = match opt with Some v -> fn v | None -> None

  let get_default ~default opt = match opt with Some v -> v | None -> default

  let get_exn opt =
    match opt with Some v -> v | None -> invalid_arg "Option.get_exn"

  let of_result res = match res with Ok v -> Some v | Error _ -> None
end

module Int = struct
  let compare (a : int) b = compare a b
end

module List = struct
  let filter_map f l =
    let rec recurse acc l =
      match l with
      | [] -> List.rev acc
      | x :: l' ->
          let acc' = match f x with None -> acc | Some y -> y :: acc in
          recurse acc' l'
    in
    recurse [] l
end
