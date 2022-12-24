ARG BASE_IMAGE="ubuntu:22.04"
ARG EASY_NOVNC_IMAGE="fhriley/easy-novnc:1.3.0"

FROM $EASY_NOVNC_IMAGE as easy-novnc
FROM $BASE_IMAGE as build

ARG DEBIAN_FRONTEND="noninteractive"

RUN apt-get update -y \
  && apt purge kodi* \
  && apt-get update -y \
  && apt-get install -y \
    libavcodec-dev \
    libavfilter-dev \
    libavformat-dev \
    libavutil-dev \
    libswscale-dev \
    libswresample-dev \
    libpostproc-dev \
    libdav1d-dev \
    flatbuffers-compiler \
    flatbuffers-compiler-dev \
    git \
    autoconf \
    automake \
    autopoint \
    gettext \
    autotools-dev \
    cmake \
    curl \
    default-jre \
    gawk \
    gcc  \
    g++  \
    cpp  \
    libflatbuffers-dev \
    gdc \
    gperf \
    libasound2-dev \
    libass-dev  \
    libavahi-client-dev \
    libavahi-common-dev \
    libbluetooth-dev \
    libbluray-dev \
    libbz2-dev \
    libcdio-dev \
    libcdio++-dev \
    libcec-dev \
    libp8-platform-dev \
    libcrossguid-dev \
    libcurl4-openssl-dev \
    libcwiid-dev \
    libdrm-dev \
    libdbus-1-dev \
    libegl1-mesa-dev \
    libenca-dev \
    libflac-dev \
    libfontconfig-dev \
    libfmt-dev  \
    libfreetype6-dev \
    libfribidi-dev \
    libfstrcmp-dev \
    libgbm-dev \
    libgcrypt-dev \
    libgif-dev  \
    libgl1-mesa-dev \
    libglew-dev \
    libglu1-mesa-dev \
    libgnutls28-dev \
    libgpg-error-dev \
    libgtest-dev  \
    libinput-dev \
    libiso9660-dev \
    libiso9660++-dev \
    libjpeg-dev \
    liblcms2-dev \
    liblirc-dev \
    libltdl-dev \
    liblzo2-dev \
    libmicrohttpd-dev \
    libmysqlclient-dev \
    libnfs-dev \
    libogg-dev \
    libomxil-bellagio-dev \
    libpcre3-dev \
    libplist-dev \
    libpng-dev \
    libpulse-dev \
    libsmbclient-dev \
    libspdlog-dev  \
    libsqlite3-dev \
    libssh-dev \
    libssl-dev \
    libtag1-dev \
    libtiff5-dev \
    libtinyxml-dev \
    libtool \
    libudev-dev \
    libunistring-dev \
    libva-dev \
    libvdpau-dev \
    libvorbis-dev \
    libxkbcommon-dev \
    libxmu-dev \
    libxrandr-dev \
    libxslt1-dev \
    libxt-dev \
    meson \
    ninja-build \
    waylandpp-dev \
    wayland-protocols \
    lsb-release \
    nasm \
    python3-dev \
    python3-pil \
    rapidjson-dev \
    swig \
    unzip \
    uuid-dev \
    yasm \
    zip \
    zlib1g-dev \
  && rm -rf /var/lib/apt/lists

ARG KODI_BRANCH="19.4-Matrix"
ARG KODI_ADDONS="vfs.libarchive vfs.rar vfs.sftp"

RUN cd /tmp \
 && git clone --depth=1 --branch ${KODI_BRANCH} https://github.com/xbmc/xbmc.git

RUN mkdir -p /tmp/xbmc/build \
  && cd /tmp/xbmc/build \
  && cmake ../. \
    -DCMAKE_INSTALL_LIBDIR=/usr/lib \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DAPP_RENDER_SYSTEM=gl \
    -DCORE_PLATFORM_NAME="x11" \
    -DENABLE_AIRTUNES=OFF \
    -DENABLE_ALSA=ON \
    -DENABLE_AVAHI=OFF \
    -DENABLE_BLUETOOTH=OFF \
    -DENABLE_BLURAY=OFF \
    -DENABLE_CAP=OFF \
    -DENABLE_CEC=OFF \
    -DENABLE_DBUS=OFF \
    -DENABLE_DVDCSS=OFF \
    -DENABLE_GLX=ON \
    -DFFMPEG_PATH=/usr \
    -DENABLE_INTERNAL_FFMPEG=OFF \
    -DENABLE_INTERNAL_DAV1D=OFF \
    -DENABLE_INTERNAL_FLATBUFFERS=OFF \
    -DENABLE_INTERNAL_FMT=OFF \
    -DENABLE_INTERNAL_SPDLOG=OFF \
    -DENABLE_INTERNAL_GTEST=OFF \
    -DENABLE_LIBUSB=OFF \
    -DENABLE_NFS=ON \
    -DENABLE_OPTICAL=OFF \
    -DENABLE_PULSEAUDIO=OFF \
    -DENABLE_SNDIO=OFF \
    -DENABLE_UDEV=OFF \
    -DENABLE_UPNP=ON \
    -DENABLE_LCMS2=OFF \
    -DENABLE_EVENTCLIENTS=OFF \
    -DENABLE_LIRCCLIENT=OFF \
    -DENABLE_VAAPI=OFF \
    -DENABLE_VDPAU=OFF \
 && make -j $(nproc) \
 && make DESTDIR=/tmp/kodi-build install

RUN set -ex \
 && cd /tmp/xbmc \
 && make -j$(nproc) -C tools/depends/target/binary-addons \
	ADDONS="$KODI_ADDONS" \
	PREFIX=/tmp/kodi-build/usr

RUN install -Dm755 \
	/tmp/xbmc/tools/EventClients/Clients/KodiSend/kodi-send.py \
	/tmp/kodi-build/usr/bin/kodi-send \
 && install -Dm644 \
	/tmp/xbmc/tools/EventClients/lib/python/xbmcclient.py \
	/tmp/kodi-build/usr/lib/python3.8/xbmcclient.py


FROM $BASE_IMAGE

ARG DEBIAN_FRONTEND="noninteractive"

RUN apt-get update -y \
  && apt-get install -y --no-install-recommends \
    alsa-base \
    ca-certificates \
    curl \
    gosu \
    supervisor \
    tigervnc-standalone-server \
    samba-common-bin \
    libavcodec58 \
    libavfilter7 \
    libavformat58 \
    libavutil56 \
    libswscale5 \
    libswresample3 \
    libpostproc55 \
    libass9 \
    libcurl4 \
    libegl1 \
    libfmt8 \
    libfstrcmp0 \
    libgl1 \
    libiso9660-11 \
    liblzo2-2 \
    libmariadbd19 \
    libmicrohttpd12 \
    libmysqlclient21 \
    libnfs13 \
    libpcrecpp0v5 \
    libpython3.10 \
    libsmbclient \
    libspdlog1 \
    libtag1v5 \
    libtinyxml2.6.2v5 \
    libudf0 \
    libudfread0 \
    libxrandr2 \
    libxslt1.1 \
    libplist3 \
  && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* \
  && echo 'pcm.!default = null;' > /etc/asound.conf

# assets.fanart.tv uses a ZeroSSL cert
RUN mkdir -p /usr/local/share/ca-certificates \
  && curl -sfL -o /usr/local/share/ca-certificates/ZeroSSL.crt "https://crt.sh/?d=2427368505" \
  && update-ca-certificates

COPY --from=build /tmp/kodi-build/usr/ /usr/
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

