module Option = struct
  let first_some opt value = match opt with Some _ -> opt | None -> value

  let flat_map fn opt = match opt with Some v -> fn v | None -> None

  let get_default ~default opt = match opt with Some v -> v | None -> default
end
