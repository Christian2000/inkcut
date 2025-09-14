#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Starting Inkcut Docker Setup for Raspberry Pi ---"

# --- 1. System Update ---
echo "STEP 1: Updating system packages..."
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::="--force-confold"

# --- 2. Install Docker ---
echo "STEP 2: Installing Docker..."
if ! command -v docker &> /dev/null
then
    curl -fsSL https://get.docker.com | sh
else
    echo "Docker is already installed. Skipping installation."
fi

# Add the user who invoked sudo to the docker group.
# This allows that user to manage Docker without sudo.
# It does not affect the service, which runs as root.
if [ -n "$SUDO_USER" ]; then
    echo "Adding user '$SUDO_USER' to the 'docker' and 'dialout' groups..."
    usermod -aG docker "$SUDO_USER"
else
    echo "Warning: No sudo user detected. Skipping adding user to docker group."
    echo "You may need to run 'sudo usermod -aG docker <your-user>' manually."
fi

# --- 3. Create and Configure Systemd Service ---
echo "STEP 3: Creating systemd service file at /etc/systemd/system/inkcut-docker.service..."

# Create the service file using a heredoc
cat <<EOF > /etc/systemd/system/inkcut-docker.service
[Unit]
Description=Inkcut Docker Container
Requires=docker.service
After=docker.service

[Service]
Restart=always
RestartSec=10

# Clean up previous container instances
ExecStartPre=-/usr/bin/docker stop inkcut-container
ExecStartPre=-/usr/bin/docker rm inkcut-container

# Pull the latest image - uncomment the last line to automatically update on startup.
# This is NOT recommended since startup then takes a long time.
# To manually update run
# sudo docker pull ghcr.io/christian2000/inkcut:latest
# ExecStartPre=/usr/bin/docker pull ghcr.io/christian2000/inkcut:latest

# Start the container
# --privileged is used to grant access to all USB devices on the host
# -p 80:80 maps the container's web server to the Pi's port 80
ExecStart=/usr/bin/docker run --name inkcut-container --privileged -p 80:80 ghcr.io/christian2000/inkcut:latest

[Install]
WantedBy=multi-user.target
EOF

# --- 4. Enable and Start the Service ---
echo "STEP 4: Enabling and starting the service..."
systemctl daemon-reload
systemctl enable inkcut-docker.service
systemctl start inkcut-docker.service

echo "--- Setup Complete! ---"
echo "The Inkcut container is now running."
echo "You can access it from another computer on your network:"
echo "http://<your-pi-ip-address>"
echo ""
echo "To check the status, run: sudo systemctl status inkcut-docker.service"
echo "To view the container logs, run: sudo docker logs -f inkcut-container"

