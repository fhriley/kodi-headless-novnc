FROM golang:1.14-buster AS easy-novnc-build
WORKDIR /src
ARG EASY_NOVNC_REV=6e198aa0fb70c68b1bc3355bfce4df30fb0f71a4
RUN go mod init build && \
    go get github.com/pgaskin/easy-novnc@${EASY_NOVNC_REV} && \
    go build -o /bin/easy-novnc github.com/pgaskin/easy-novnc

FROM ubuntu:20.04

ARG DEBIAN_FRONTEND="noninteractive"

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        tigervnc-standalone-server \
        supervisor \
        gosu \
        gnupg && \
    rm -rf /var/lib/apt/lists

ARG KODI_VERSION=19.1
RUN apt-get update -y && \
    apt purge kodi* && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:team-xbmc/ppa && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
        kodi=2:${KODI_VERSION}+* && \
    rm -rf /var/lib/apt/lists

COPY --from=easy-novnc-build /bin/easy-novnc /usr/local/bin/
COPY supervisord.conf /etc/
COPY advancedsettings.xml /usr/share/kodi
COPY docker-entrypoint.sh /

ENV KODI_UID=2000
ENV KODI_GID=2000
ENV KODI_DB_HOST=mysql
ENV KODI_DB_PORT=3306
ENV KODI_DB_USER=kodi
ENV KODI_DB_PASS=kodi

# noVNC
EXPOSE 8000

# Kodi HTTP API
EXPOSE 8080

VOLUME /data

CMD ["/docker-entrypoint.sh"]

maintainer fhriley "fhriley+git@gmail.com"
