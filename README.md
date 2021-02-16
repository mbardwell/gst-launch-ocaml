gst-launch-ocaml repository. Like gst-launch-1.0, but written in OCaml.

# Install
```
you@pc:~/gst-launch-ocaml/$ opam switch create 4.11.1
you@pc:~/gst-launch-ocaml/$ eval <something - the command above will tell you>
you@pc:~/gst-launch-ocaml/$ apt install libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev
you@pc:~/gst-launch-ocaml/$ opam install dune=2.7.1 gstreamer merlin core
# hello, world!
you@pc:~/gst-launch-ocaml/$ dune exec gstlaunch -- "videotestsrc ! jpegenc ! jpegdec ! xvimagesink"
you@pc:~/gst-launch-ocaml/$ dune exec gstlaunch -- "v4l2src device=/dev/video0 ! image/jpeg, width=960, height=540, pixel-aspect-ratio=1/1, framerate=30/1 ! decodebin ! xvimagesink"
# debug
you@pc:~/gst-launch-ocaml/$ GST_DEBUG=2 dune exec gstlaunch -- "whatever"
```