# Filename: Dockerfile

FROM ubuntu:22.04

# Set the default language to sv_SE.UTF-8
ENV LANG=sv_SE.UTF-8
ENV LANGUAGE=sv_SE.UTF-8
ENV LC_ALL=sv_SE.UTF-8

ENV DEBIAN_FRONTEND=noninteractive
# The DISPLAY var will be set in the entrypoint now
# ENV DISPLAY=:0

# Update packages and install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    tigervnc-standalone-server \
    openbox \
    menu \
    python3-pyqt5 \
    python3-pyqt5.qtsvg \
    locales \
    websockify \
    git \
    python3 \
    python3-pip \
    python3-dev \
    libcups2-dev \
    libusb-1.0-0-dev \
    build-essential \
    # We no longer need xvfb or x11vnc
    && rm -rf /var/lib/apt/lists/*

# Generate the sv_SE.UTF-8 locale
RUN echo "sv_SE.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen

# Download and install FileBrowser for ARM64 (Raspberry Pi)
RUN curl -fsSL https://github.com/filebrowser/filebrowser/releases/latest/download/linux-arm64-filebrowser.tar.gz \
    | tar -C /usr/local/bin -xzv filebrowser

# Clone noVNC and create an index.html that auto-connects
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc && \
    echo '<meta http-equiv="refresh" content="0; url=vnc.html?autoconnect=true&resize=remote">' > /opt/novnc/index.html

RUN pip3 install --upgrade pip setuptools wheel
RUN pip3 install inkcut

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
COPY xstartup.sh /usr/local/bin/xstartup.sh
RUN chmod +x /usr/local/bin/xstartup.sh

EXPOSE 6080
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
