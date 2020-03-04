module String = struct
  (* Chops the provided prefix or returns the string*)
  let chop_prefix ~(prefix : string) str =
    match Base.String.chop_prefix ~prefix str with Some s -> s | None -> str
end

module Option = struct
  let first_some opt value = match opt with Some _ -> opt | None -> value

  let flat_map fn opt = match opt with Some v -> fn v | None -> None

  let get_default ~default opt = match opt with Some v -> v | None -> default
end
