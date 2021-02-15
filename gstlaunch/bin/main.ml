open Core

module Opt = struct
  let verbose = ref false
  let command = ref ""
end

module MyPipeline = struct
  open Gstreamer
  open Opt
  let bin () = Gstreamer.Pipeline.parse_launch !command
  let start_pipeline () =
    init ();
    (Element.set_state (bin ()) Element.State_playing : Element.state_change) |> ignore;
    (Element.get_state (bin ()) : Element.state_change * Element.state * Element.state) |> ignore;
    Unix.sleep 2;
    (Element.set_state (bin ()) Element.State_null : Element.state_change) |> ignore;
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