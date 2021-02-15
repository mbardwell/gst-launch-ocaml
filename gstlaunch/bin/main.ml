open Core

module Opt = struct
  let verbose = ref false
  let command = ref ""
end

module MyPipeline = struct
  open Gstreamer
  open Opt
  let bin () = Gstreamer.Pipeline.parse_launch !command
  let string_of_state_change = function
    | Element.State_change_success -> "success"
    | Element.State_change_async -> "async"
    | Element.State_change_no_preroll -> "no preroll"
  let print_get_state (sc, bef, aft) =
   print_endline @@ Printf.sprintf "sc: %s, bef: %s, aft: %s" (string_of_state_change sc) (Element.string_of_state bef) (Element.string_of_state aft)
  let start_pipeline () =
    init ();
    Element.set_state (bin ()) Element.State_playing |> string_of_state_change |> print_endline;
    Element.get_state (bin ()) |> print_get_state;
    Element.set_state (bin ()) Element.State_null |> string_of_state_change |> print_endline;
    deinit ();
    Gc.full_major
end

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
        Opt.command := command;
        MyPipeline.start_pipeline () ()
    )

let () =
  Command.run ~version:"0.1.0" ~build_info:"beta" command