open Core
(* open Gstreamer *)

module Opt = struct
  let verbose = ref false
end

let print_ = print_endline

let filename_param =
  let open Command.Param in
  anon ("filename" %: string)

let command =
  Command.basic
    ~summary:"build and run a GStreamer pipeline"
    ~readme:(fun () -> "Like gst-launch-1.0, but written in OCaml")
    Command.Let_syntax.(
      let%map_open
        command = anon (("command" %: string))
        and verbose = flag "-v" no_arg ~doc:"verbose output for debugging"
      in fun () ->
        if verbose then Opt.verbose := true;
        print_ command
    )

let () =
  Command.run ~version:"0.1.0" ~build_info:"beta" command