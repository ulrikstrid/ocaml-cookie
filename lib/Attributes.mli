module AMap : sig
  include Map.S with type key = string

  val key_exists : key:string -> 'a t -> bool
end

val list_to_map : string list -> string AMap.t
