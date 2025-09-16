#!/bin/bash
# Unset session management variables
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

# Start the window manager in the background
openbox  > /proc/1/fd/1 2>/proc/1/fd/2 &

# Loop so that Inkcut is automatically restarted if closed
while true
do
  # Start the main application in the foreground
  HOME=/uploads XAUTHORITY=/root/.Xauthority DISPLAY=:1 inkcut > /proc/1/fd/1 2>/proc/1/fd/2
done