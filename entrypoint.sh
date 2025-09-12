#!/bin/bash

# Start TigerVNC server. It creates a virtual display (:1) and
# runs openbox as the window manager. It runs in the background by default.
# The VNC server will listen on port 5901 (5900 + 1).
vncserver :1 -xstartup /usr/bin/openbox -geometry 1280x800 -SecurityTypes None

# Start the noVNC WebSocket proxy, pointing to the new VNC port.
websockify --web /opt/novnc 6080 localhost:5901 &

# Set the display for Inkcut to use
export DISPLAY=:1

# Start Inkcut as the main foreground process.
exec inkcut
