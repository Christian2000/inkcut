#!/bin/bash
# Unset session management variables
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS

# Start the window manager in the background
openbox &

while true
do
  # Start the main application in the foreground
  DISPLAY=:1 inkcut &

  echo "Waiting for Inkcut window..."
  for i in {1..100}; do # Timeout after 10 seconds (100 * 0.1s)
      # Check if a window with "Inkcut" in the title exists
      if DISPLAY=:1 wmctrl -l | grep -q "Inkcut"; then
          echo "Inkcut window found. Maximizing."
          DISPLAY=:1 wmctrl -r Inkcut -b add,maximized_vert,maximized_horz
          break # Exit the loop once the window is found and maximized
      fi
      sleep 0.1
  done

  wait $!
  sleep 1
done