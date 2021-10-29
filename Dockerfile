FROM golang:1.14-buster AS easy-novnc-build

ARG EASY_NOVNC_BRANCH=master
RUN cd $GOPATH/src \
    && git clone --depth=1 --branch ${EASY_NOVNC_BRANCH} https://github.com/fhriley/easy-novnc \
    && cd $GOPATH/src/easy-novnc \
    && go mod edit -replace github.com/pgaskin/easy-novnc=github.com/fhriley/easy-novnc@${EASY_NOVNC_BRANCH} \
    && go mod tidy \
    && go build -o /bin/easy-novnc

FROM ubuntu:20.04

ARG DEBIAN_FRONTEND="noninteractive"

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
        tigervnc-standalone-server \
        supervisor \
        gosu \
        gnupg \
        alsa-base \
        samba-common-bin \
    && rm -rf /var/lib/apt/lists

ARG KODI_VERSION=6:19.3
RUN apt-get update -y && \
    apt purge kodi* && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:team-xbmc/ppa && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
        kodi=${KODI_VERSION}+* \
    && rm -rf /var/lib/apt/lists

RUN echo 'pcm.!default = null;' > /etc/asound.conf

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
