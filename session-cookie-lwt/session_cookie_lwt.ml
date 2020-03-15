open Session_cookie

module Make(B:Backend with type +'a io = 'a Lwt.t) = Make(Lwt)(B)
