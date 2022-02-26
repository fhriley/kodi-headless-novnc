ARG BASE_IMAGE="fhriley/vnc-base:latest"

FROM $BASE_IMAGE

ARG DEBIAN_FRONTEND="noninteractive"

RUN apt-get update -y \
  && apt-get install -y software-properties-common \
  && add-apt-repository -y ppa:team-xbmc/ppa \
  && apt-get update -y \
  && apt-get install -y \
    alsa-base \
    curl \
    kodi \
    kodi-eventclients-kodi-send \
    samba-common-bin \
    tigervnc-standalone-server \
    tzdata \
  && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* \
  && echo 'pcm.!default = null;' > /etc/asound.conf \
  && ln -s /usr/lib/*/kodi/kodi.bin /usr/bin/kodi

# assets.fanart.tv uses a ZeroSSL cert
RUN curl -sfL -o /usr/local/share/ca-certificates/ZeroSSL.crt "https://crt.sh/?d=2427368505" \
    && update-ca-certificates

COPY advancedsettings.xml /usr/share/kodi/
COPY entrypoint.sh /entrypoint.d/
COPY supervisord.conf /supervisor.d/

# VNC
EXPOSE 5900/tcp

# HTTP (noVNC)
EXPOSE 8000/tcp

# Kodi HTTP API
EXPOSE 8080/tcp

# Websockets
EXPOSE 9090/tcp

# EventServer
EXPOSE 9777/udp

ENV VNC_WINDOW_NAME=Kodi
ENV VNC_UID=2000
ENV VNC_UID=2000
ENV KODI_DB_HOST=mysql
ENV KODI_DB_PORT=3306
ENV KODI_DB_USER=kodi
ENV KODI_DB_PASS=kodi

LABEL maintainer="fhriley+git@gmail.com"
