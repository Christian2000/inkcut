#!/bin/bash

# Start the noVNC WebSocket proxy in the background
websockify --web /opt/novnc 6080 localhost:5901 &

# Start TigerVNC in the FOREGROUND as the main process.
# It will run our custom xstartup.sh script internally.
exec vncserver :1 -fg -xstartup /usr/local/bin/xstartup.sh -geometry 1280x800 -SecurityTypes None