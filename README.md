```
you@pc:~/gst-launch-ocaml/$ opam switch create 4.11.1
you@pc:~/gst-launch-ocaml/$ eval <something - the command above will tell you>
you@pc:~/gst-launch-ocaml/$ apt install libgstreamer-plugins-base1.0-dev libgstreamer1.0-dev
you@pc:~/gst-launch-ocaml/$ opam install dune=2.7.1 gstreamer merlin core
you@pc:~/gst-launch-ocaml/$ dune exec gstlaunch -- "videotestsrc ! jpegenc ! jpegdec ! xvimagesink"
```