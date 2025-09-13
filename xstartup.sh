#!/bin/bash
# Unset session management variables
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

# Start the window manager in the background
openbox &

# Start the main application in the foreground
inkcut &

sleep 5

DISPLAY=:1 wmctrl -r Inkcut -b add,maximized_vert,maximized_horz

wait