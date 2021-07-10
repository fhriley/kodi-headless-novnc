#!/bin/bash

id -g app &>/dev/null || groupadd --gid $GID app
id -u app &>/dev/null || useradd --home-dir /data --shell /bin/bash --uid $UID --gid $GID app

if [ ! -f /data/.kodi/userdata/advancedsettings.xml ]; then
  mkdir -p /data/.kodi/userdata
  sed -e 's@DB_HOST@'"$DB_HOST"'@g' \
      -e 's@DB_PORT@'"$DB_PORT"'@g' \
      -e 's@DB_USER@'"$DB_USER"'@g' \
      -e 's@DB_PASS@'"$DB_PASS"'@g' \
      /usr/share/kodi/advancedsettings.xml > /data/.kodi/userdata/advancedsettings.xml
fi

if [ ! -f /data/.kodi/userdata/sources.xml ]; then
  mkdir -p /data/.kodi/userdata
  sed -e 's@TV_SOURCE@'"$TV_SOURCE"'@g' \
      -e 's@MOVIES_SOURCE@'"$MOVIES_SOURCE"'@g' \
      /usr/share/kodi/sources.xml > /data/.kodi/userdata/sources.xml
fi

chown app:app /dev/stdout
exec gosu app supervisord
