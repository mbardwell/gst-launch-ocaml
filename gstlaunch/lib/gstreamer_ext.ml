open Gstreamer
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
let string_of_state_change = function
  | Element.State_change_success -> "success"
  | Element.State_change_async -> "async"
  | Element.State_change_no_preroll -> "no preroll"
let print_get_state (sc, bef, aft) =
  print_endline @@ Printf.sprintf "sc: %s, bef: %s, aft: %s" (string_of_state_change sc) (Element.string_of_state bef) (Element.string_of_state aft)
let print_bus_message (msg : Bus.message) =
  print_endline @@ "source: " ^ msg.source ^ " payload: " ^ (message_type_to_string msg.payload)
let handler ~on_error msg =
  let source = msg.Bus.source in
  match msg.Bus.payload with
    | `Error err ->
        Printf.printf "[%s] Error: %s" source err;
        on_error err
    | `Warning err -> Printf.printf "[%s] Warning: %s" source err
    | `Info err -> Printf.printf "[%s] Info: %s" source err
    | `State_changed (o, n, p) ->
        let f = Gstreamer.Element.string_of_state in
        let o = f o in
        let n = f n in
        let p =
          match p with
            | Gstreamer.Element.State_void_pending -> ""
            | _ -> Printf.sprintf " (pending: %s)" (f p)
        in
        Printf.printf "[%s] State change: %s -> %s%s" source o n p
    | _ -> assert false
let flush
  ?(types = [`Error; `Warning; `Info; `State_changed])
  ?(on_error = print_endline)
  bin =
  let bus = Gstreamer.Bus.of_element bin in
  let rec f () =
    match Gstreamer.Bus.pop_filtered bus types with
      | Some msg ->
          handler ~on_error msg;
          f ()
      | None -> print_endline "none"; ()
  in
  f ()
let get_state bin = Element.get_state (bin) |> print_get_state
let set_state bin state = Element.set_state (bin) state |> string_of_state_change |> print_endline
