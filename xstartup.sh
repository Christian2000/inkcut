#!/bin/bash

exec >> /tmp/xstartup.log 2>&1

# Unset session management variables
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

echo "Starting openbox"
# Start the window manager in the background
openbox &
# Loop so that Inkcut is automatically restarted if closed
while true
do
  # Start the main application in the foreground
  echo "Starting inkcut"
  DISPLAY=:1 inkcut --config /home/kioskuser/.config/inkcut
  echo "Inkcut exited, restarting"
done