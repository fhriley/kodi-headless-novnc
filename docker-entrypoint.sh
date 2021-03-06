#!/bin/bash

id -g app &>/dev/null || groupadd --gid $KODI_GID app
id -u app &>/dev/null || useradd --home-dir /data --shell /bin/bash --uid $KODI_UID --gid $KODI_GID app

mkdir -p /data/.kodi

if [ ! -f /data/.kodi/userdata/advancedsettings.xml ]; then
  mkdir -p /data/.kodi/userdata
  sed -e 's@KODI_DB_HOST@'"$KODI_DB_HOST"'@g' \
      -e 's@KODI_DB_PORT@'"$KODI_DB_PORT"'@g' \
      -e 's@KODI_DB_USER@'"$KODI_DB_USER"'@g' \
      -e 's@KODI_DB_PASS@'"$KODI_DB_PASS"'@g' \
      /usr/share/kodi/advancedsettings.xml > /data/.kodi/userdata/advancedsettings.xml
fi

chown -R app:app /data/.kodi
chown app:app /dev/stdout
exec gosu app supervisord
