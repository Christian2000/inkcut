FROM ubuntu:22.04

# --- SET SWEDISH LOCALE ---
# Set the default language to sv_SE.UTF-8
ENV LANG=sv_SE.UTF-8
ENV LANGUAGE=sv_SE.UTF-8
ENV LC_ALL=sv_SE.UTF-8

# Generate the sv_SE.UTF-8 locale
RUN sed -i -e 's/# sv_SE.UTF-8 UTF-8/sv_SE.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

# Set environment variables to prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:0

# Update packages and install dependencies in a single layer to save space
RUN apt-get update && apt-get install -y --no-install-recommends \
    # X11 & Virtual Framebuffer for headless GUI
    xvfb \
    x11vnc \
    openbox \
    menu \
    # noVNC Web Interface
    python3-pyqt5 \
    python3-pyqt5.qtsvg \
    websockify \
    git \
    # Inkcut Python & System dependencies
    python3 \
    python3-pip \
    python3-dev \
    libcups2-dev \
    libusb-1.0-0-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Clone noVNC and set it up
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc && \
    echo '<meta http-equiv="refresh" content="0; url=vnc.html?autoconnect=true&resize=remote">' > /opt/novnc/index.html

RUN pip3 install --upgrade pip setuptools wheel

# Install Inkcut using pip
RUN pip3 install inkcut

# Copy the container's startup script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose the port for the noVNC web interface
EXPOSE 6080

# Set the entrypoint to our startup script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
