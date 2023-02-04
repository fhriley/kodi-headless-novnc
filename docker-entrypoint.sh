#!/bin/bash

KODI_UID=${KODI_UID:-2000}
KODI_GID=${KODI_GID:-2000}
KODI_UMASK=${KODI_UMASK:-002}

groupmod -o -g "$KODI_GID" app
usermod -o -u "$KODI_UID" app

mkdir -p /data/.kodi /data/.cache /data/.config

if [ ! -f /data/.kodi/userdata/advancedsettings.xml ]; then
  mkdir -p /data/.kodi/userdata
  sed -e 's@KODI_DB_HOST@'"$KODI_DB_HOST"'@g' \
      -e 's@KODI_DB_PORT@'"$KODI_DB_PORT"'@g' \
      -e 's@KODI_DB_USER@'"$KODI_DB_USER"'@g' \
      -e 's@KODI_DB_PASS@'"$KODI_DB_PASS"'@g' \
      /usr/share/kodi/advancedsettings.xml > /data/.kodi/userdata/advancedsettings.xml
fi

chown -R app:app /data
chown app:app /dev/stdout
exec gosu app supervisord
