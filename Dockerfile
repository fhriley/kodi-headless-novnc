ARG BASE_IMAGE="ubuntu:22.04"
ARG EASY_NOVNC_IMAGE="fhriley/easy-novnc:1.3.0"

FROM $EASY_NOVNC_IMAGE as easy-novnc
FROM $BASE_IMAGE

ARG DEBIAN_FRONTEND="noninteractive"

RUN apt-get update -y \
  && apt-get install -y software-properties-common \
  && add-apt-repository -y ppa:team-xbmc/ppa \
  && apt-get update -y \
  && apt-get install -y \
    alsa-base \
    ca-certificates \
    curl \
    gosu \
    kodi \
    kodi-eventclients-kodi-send \
    samba-common-bin \
    supervisor \
    tigervnc-standalone-server \
    tzdata \
  && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* \
  && echo 'pcm.!default = null;' > /etc/asound.conf

# assets.fanart.tv uses a ZeroSSL cert
RUN mkdir -p /usr/local/share/ca-certificates \
  && curl -sfL -o /usr/local/share/ca-certificates/ZeroSSL.crt "https://crt.sh/?d=2427368505" \
  && update-ca-certificates

COPY --from=easy-novnc /usr/local/bin/easy-novnc /usr/local/bin/easy-novnc

COPY supervisord.conf /etc/
COPY advancedsettings.xml /usr/share/kodi/
COPY docker-entrypoint.sh /

VOLUME /data

CMD ["/docker-entrypoint.sh"]

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

VOLUME /data

ENV KODI_UID=2000
ENV KODI_GID=2000
ENV KODI_DB_HOST=mysql
ENV KODI_DB_PORT=3306
ENV KODI_DB_USER=kodi
ENV KODI_DB_PASS=kodi

HEALTHCHECK --start-period=5s --interval=30s --retries=1 --timeout=5s \
  CMD /usr/bin/supervisorctl status all >/dev/null || exit 1

LABEL maintainer="fhriley+git@gmail.com"
