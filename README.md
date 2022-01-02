# fhriley/kodi-headless-novnc

[![Build Images](https://github.com/fhriley/kodi-headless-novnc/actions/workflows/actions.yml/badge.svg?branch=master)](https://github.com/fhriley/kodi-headless-novnc/actions/workflows/actions.yml)

A headless install of kodi in a docker container.
Commonly used with MySQL Kodi setup to allow library updates via web interface.

https://hub.docker.com/r/fhriley/kodi-headless-novnc

This image has 2 major advantages over other headless images:

1. The Kodi GUI is available in a web browser on port 8000, which means you don't need a
second "real" Kodi running to configure everything.

2. This Kodi image does not use any patches to modify the code, which means it can easily
be updated to any new versions of Kodi.

## Usage

```bash
docker run --name=kodi-headless-novnc \
-d --init \
-v <MY_DATA_PATH>:/data \
-e KODI_DB_HOST=<MY_KODI_DBHOST> \
-e KODI_DB_USER=<MY_KODI_DBUSER> \
-e KODI_DB_PASS=<MY_KODI_DBPASS> \
-e TZ=<MY_TIMEZONE> \
-p 8000:8000/tcp \
-p 8080:8080/tcp \
-p 9090:9090/tcp \
-p 9777:9777/udp \
fhriley/kodi-headless-novnc:latest
```

Docker compose example:

```yaml
version: "3"

services:
  kodi:
   image: fhriley/kodi-headless-novnc
   restart: always
   init: true
   ports:
     - "8000:8000/tcp"
     - "8080:8080/tcp"
     - "9090:9090/tcp"
     - "9777:9777/udp"
   environment:
     KODI_DB_HOST: 192.168.1.246
     KODI_DB_USER: user
     KODI_DB_PASS: password
     TZ: America/New_York
   volumes:
     - ./kodi_data:/data
```

**Ports**

* `8000/tcp` - noVNC HTTP port (Kodi GUI)
* `8080/tcp` - webui port
* `9090/tcp` - websockets port
* `9777/udp` - esall interface port

**Volumes**

* `/data` - path for kodi data and configuration files

**Environment Variables**

* `KODI_DB_HOST` - MySQL database host address (default `mysql`)
* `KODI_DB_USER` - MySQL user for Kodi (default `kodi`)
* `KODI_DB_PASS` - MySQL password for Kodi user (default `kodi`)
* `KODI_DB_PORT` - MySQL remote port (default `3306`)
* `KODI_UID` - The user ID to run all processes in the container under (default `2000`)
* `KODI_GID` - The group ID to run all processes in the container under (default `2000`)
* `TZ` - The timezone to use in the container (default `UTC`)

## Tags

| Tagname  | Branch  | Kodi version  | Base distro   | Architecture         |
|----------|---------|---------------|---------------|----------------------|
| `latest` | Matrix  | 19.3          | Ubuntu 22.04  | amd64, armv7, arm64  |
| `Matrix` | Matrix  | 19.3          | Ubuntu 22.04  | amd64, armv7, arm64  |
| `19.3`   | Matrix  | 19.3          | Ubuntu 22.04  | amd64, armv7, arm64  |
| `19.2`   | Matrix  | 19.2          | Ubuntu 20.04  | amd64                |
| `19.1`   | Matrix  | 19.1          | Ubuntu 20.04  | amd64                |

Docker will automatically pull the correct architecture for your platform.

## User / Group Identifiers

Sometimes when using data volumes (`-v` flags) permissions issues can arise between the
host OS and the container. We avoid this issue by allowing you to specify the user `KODI_UID`
and group `KODI_GID`. Ensure the data volume directory on the host is owned by the same user
you specify and it will "just work" ™.

In this instance `KODI_UID=1001` and `KODI_GID=1001`. To find yours use `id user` as below:

```
  $ id <dockeruser>
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

## Setting up the application

The database connection settings will be automatically configured the first time the container is
started and stored in `/data/.kodi/userdata/advancedsettings.xml`.
Many other settings are within this file, also. You may modify this file after it is generated.
You may also mount your own version. If you mount your own version, the database configuration variables (KODI_DB*)
will not be used.

If you intend to use this kodi instance to perform library tasks other than merely updating, eg.
library cleaning etc, it is important to copy over the sources.xml from the host machine that
you performed the initial library scan on to the userdata folder of this instance, otherwise
database loss can and most likely will occur.

## Info

* Shell access whilst the container is running: `docker exec -it kodi-headless-novnc bash`
* To monitor the logs of the container in realtime: `docker logs -f kodi-headless-novnc`

## Credits

+ [linuxserver](https://github.com/linuxserver/docker-kodi-headless/) (original headless container)
+ [matthuisman](https://github.com/matthuisman/docker-kodi-headless/) (this README)

## Fast Scanning

The below works if your media is stored on the same machine as this docker container and your using smb:// to share that media on the network.

First, mount your host media directory somewhere inside the container so Kodi can see it.  
eg. ```--mount type=bind,source=/sharedfolders/pool,target=/media```

Now, the below magic is done in Kodis advancedsettings.xml
```
<pathsubstitution>
  <substitute>
    <from>smb://192.168.20.3/sharedfolders/pool/</from>
    <to>/media/</to>
  </substitute>
</pathsubstitution>
```

That's it. 
Now instead of always needing to scan over smb://, it will replace that with /media and scan much quicker.
When it does find new items, they are correctly stored in the SQL using their smb:// path
