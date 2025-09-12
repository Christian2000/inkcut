#!/bin/bash

# Start the virtual X server in the background
# Resolution is set to 1280x800. You can change this if needed.
Xvfb :0 -screen 0 1280x800x24 &

sleep 1 #Waot for the windowmanager to start

# Start the lightweight window manager in the background
openbox &

# Start the VNC server, connecting to the virtual display.
# -nopw: No password required for VNC connection (handled internally).
# -forever: Keep the VNC server running.
x11vnc -display :0 -nopw -forever -noshared -ncache 10 -nchache_cr &

# Start the noVNC WebSocket proxy.
# Listens on port 6080 and forwards traffic to the VNC server on port 5900.
websockify --web /opt/novnc 6080 localhost:5900 &

# Start Inkcut as the main foreground process.
# The 'exec' command replaces the script process with the inkcut process,
# which allows the container to stop gracefully.
exec inkcut
