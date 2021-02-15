open Core

module Opt = struct
  let verbose = ref false
  let command = ref ""
end

module MyPipeline = struct
  open Gstreamer
  open Opt
  let () = init ()
  let message_type_to_string : (Bus.message_payload -> string) = function
    | `Unknown -> "Unknown"
    | `End_of_stream -> "EOS"
    | `Error (str) -> "Error: " ^ str
    | `Warning (str) -> "Warning: " ^ str
    | `Info (str) -> "Info: " ^ str
    | `Tag _ -> "Tag: TODO CATCH ARGS"
    | `Buffering (int) -> Printf.sprintf "Buffering: %d" int
    | `State_changed _ -> "State changed: TODO CATCH ARGS"
    | `State_dirty -> "State dirty"
    | `Step_done -> "Step done"
    | `Clock_provide -> "Clock provide"
    | `Clock_lost -> "Clock lost"
    | `New_clock -> "New clock"
    | `Structure_change -> "Structure change"
    | `Stream_status -> "Stream status"
    | `Application -> "Application"
    | `Element -> "Element"
    | `Segment_start -> "Segment start"
    | `Segment_done -> "Segment done"
    | `Duration_changed -> "Duration changed"
    | `Latency -> "Latency"
    | `Async_start -> "Async start"
    | `Async_done -> "Async done"
    | `Request_state -> "Request state"
    | `Step_start -> "Step start"
    | `Qos -> "Qos"
    | `Progress -> "Progress"
    | `Toc -> "Toc"
    | `Reset_time -> "Reset time"
    | `Stream_start -> "Stream start"
    | `Need_context -> "Need context"
    | `Have_context -> "Have context"
  let bin () = Gstreamer.Pipeline.parse_launch !command
  let string_of_state_change = function
    | Element.State_change_success -> "success"
    | Element.State_change_async -> "async"
    | Element.State_change_no_preroll -> "no preroll"
  let print_get_state (sc, bef, aft) =
    print_endline @@ Printf.sprintf "sc: %s, bef: %s, aft: %s" (string_of_state_change sc) (Element.string_of_state bef) (Element.string_of_state aft)
  let print_bus_message (msg : Bus.message) =
    print_endline @@ "source: " ^ msg.source ^ " payload: " ^ (message_type_to_string msg.payload)
  let start_pipeline () =
    let timeToString nsd =
      let msd = Int64.(to_int (nsd / (of_int 1_000_000)) |> function
      | None -> raise Failed
      | Some(x) -> x) in
      let h = msd / 3_600_000 in
      let m = (msd - (h * 3_600_000)) / 60_000 in
      let s = (msd - (h * 3_600_000) - (m * 60_000)) / 1000 in
      let h = if h = 0 then "" else Printf.sprintf "%d:" h in
      Printf.sprintf "%s%d:%d" h m s in
    let duration = Element.duration (bin ()) Format.Time |> timeToString in
    Element.set_state (bin ()) Element.State_playing |> string_of_state_change |> print_endline;
    Element.get_state (bin ()) |> print_get_state;
    let rec wait () =
      let position = Element.position (bin ()) Format.Time |> timeToString in
      print_endline @@ "position: " ^ position;
      print_endline @@ "duration: " ^ duration;
      let timeout = (Int64.of_int 1_000_000_000) in
      let filter = [`End_of_stream] in
      match Bus.timed_pop_filtered (Bus.of_element (bin ())) ~timeout filter with
      | exception Timeout -> wait ()
      | exception Failed -> wait ()
      | x -> print_bus_message x
    in
    wait ();
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