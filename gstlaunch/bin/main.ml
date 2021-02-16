open Core

module MyPipeline = struct
  open Gstreamer
  open Gstreamer_ext
  let verbose = ref false
  let command = ref ""
  let init () =
    print_endline "Initialising pipeline";
    init ()
  let deinit () =
    print_endline "Deinitialising pipeline";
    deinit ();
    Gc.full_major ()
  let run () =
    init ();
    let bin = Gstreamer.Pipeline.parse_launch !command in
    begin
      try begin
        get_state bin;
        set_state (bin) Element.State_ready;
        get_state bin;
        set_state (bin) Element.State_paused;
        get_state bin;
        set_state (bin) Element.State_playing;
        get_state bin;
        Unix.sleep 5;
        set_state (bin) Element.State_paused;
        get_state bin;
        set_state (bin) Element.State_ready;
        get_state bin;
        set_state (bin) Element.State_null;
        end
      with
      | Error x -> print_endline x
      | Stopped -> print_endline "Stopped"
      | Timeout -> print_endline "Timeout"
      | Failed -> print_endline "Failed"
      | End_of_stream -> print_endline "End of stream"
    end;
    deinit ()
end

let command =
  Command.basic
    ~summary:"build and run a GStreamer pipeline"
    ~readme:(fun () -> "Like gst-launch-1.0, but written in OCaml")
    Command.Let_syntax.(
      let%map_open
        command = anon (("command" %: string)) and
        verbose = flag "-v" no_arg ~doc:"verbose output for debugging"
      in fun () ->
        if verbose then MyPipeline.verbose := true;
        MyPipeline.command := command;
        MyPipeline.run ()
    )

let () =
  Command.run ~version:"0.1.0" ~build_info:"beta" command