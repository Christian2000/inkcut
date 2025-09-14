FROM ubuntu:22.04 AS builder

RUN apt update && apt install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-dev \
    python3-venv \
    libcups2-dev \
    build-essential

RUN python3 -m venv /opt/venv --system-site-packages
RUN /opt/venv/bin/pip install --upgrade pip setuptools wheel
RUN /opt/venv/bin/pip install inkcut

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
    wmctrl\
    nginx\
    curl \
    ca-certificates \
    tigervnc-standalone-server \
    openbox \
    menu \
    python3-pyqt5 \
    python3-pyqt5.qtsvg \
    locales \
    websockify \
    git \
    libcups2-dev \
    libusb-1.0-0-dev \
    # We no longer need xvfb or x11vnc
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Generate the sv_SE.UTF-8 locale
RUN echo "sv_SE.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen

# Download and install FileBrowser for the correct architecture
ARG TARGETARCH
RUN case ${TARGETARCH} in \
        "arm") FB_ARCH="armv7";; \
        "arm64") FB_ARCH="arm64";; \
        *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1;; \
    esac && \
    curl -fsSL https://github.com/filebrowser/filebrowser/releases/latest/download/linux-${FB_ARCH}-filebrowser.tar.gz \
    | tar -C /usr/local/bin -xzv filebrowser


# Clone noVNC and create an index.html that auto-connects
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc && \
    echo '<meta http-equiv="refresh" content="0; url=vnc.html?autoconnect=true&resize=remote">' > /opt/novnc/index.html

RUN mkdir -p /root/.config/openbox/
COPY rc.xml /root/.config/opnebox/rc.xml

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
COPY xstartup.sh /usr/local/bin/xstartup.sh
RUN chmod +x /usr/local/bin/xstartup.sh

COPY nginx.conf /etc/nginx/nginx.conf
COPY html/* /var/www/html/

COPY inkcut.device.json /root/.config/inkcut/inkcut.device.json

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
