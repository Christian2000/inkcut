#!/bin/bash

nginx &

mkdir -p /uploads
# Start FileBrowser on port 8080, managing the /root/Documents folder
# This is the same folder you share with the Docker -v flag.

filebrowser --address 0.0.0.0 --port 8080 --root /uploads --database /root/filebrowser.db --baseurl /upload --noauth  > /proc/1/fd/1 2>/proc/1/fd/2 &

# Start the noVNC WebSocket proxy in the background
websockify --web /opt/novnc --idle-timeout=0 6080 localhost:5901 > /proc/1/fd/1 2>/proc/1/fd/2 &

# Start TigerVNC in the FOREGROUND as the main process.
# It will run our custom xstartup.sh script internally.
exec vncserver :1 -fg -xstartup /usr/local/bin/xstartup.sh -geometry 1280x800 -SecurityTypes None -name "Inkcut"