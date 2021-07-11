[![](http://kodi.wiki/images/4/43/Side-by-side-dark-transparent.png)](https://kodi.tv/)

# Introduction
A headless, dockerized Kodi instance for a shared MySQL setup to allow having a webinterface and automatic periodic library updates without the need for a player system to be permanently on.

This image has 2 major advantages over other headless images:

1. The Kodi GUI is available in a web browser on port 8000, which means you don't need a second "real" Kodi running to configure everything.

2. This Kodi image does not use any patches to modify the code. It uses the standard Ubuntu install and can easily be updated to any new versions of Kodi.

# Tags

| Tagname              | Branch      | Kodi version | Base distro          |
|----------------------|-------------|--------------|----------------------|
| `latest`             | matrix      | 19           | Ubuntu Focal Fossa   |

# Prerequisites
You need to have set up library sharing via a dedicated MySQL database beforehand by reading, understanding and executing the necessary steps in the [MySQL library sharing guide](http://kodi.wiki/view/MySQL).

WARNING - as already stated in the wiki but here once again: Every client must run the same version of Kodi!

Note that the database and your sources (SMB or NFS) must be reachable from the headless instance.
All updating, scraping and cleaning can then be handled automatically by the headless Kodi instance on its own.

REMINDER: If you are not using the default scrapers you need to take care of installing and enabling the respective addons in the container yourself.

# Usage

Get the container image:
```bash
docker pull fhriley/kodi-headless-vnc
```

Run the container and set necessary environment variables:
```bash
docker run --name=kodi-headless-vnc -e KODI_DB_HOST=<MY_KODI_DBHOST> -e KODI_DB_USER=<MY_KODI_DBUSER> -e KODI_DB_PASS=<MY_KODI_DBPASS> -e KODI_TV_SOURCE=<MY_TV_SOURCE> -e KODI_MOVIES_SOURCE=<MY_MOVIES_SOURCE> fhriley/kodi-headless-vnc
```

All kodi config that is not stored in the database will be stored in `/data`. You can mount it as follows:

```bash
-v <MY_DATA_PATH>:/data
```

If you want to access the Kodi GUI, map the noVNC port:
```bash
-p 8000:8000
```

If you turn on the Kodi HTTP API in Kodi, map the API port:
```bash
-p 8080:8080
```

Docker compose example:

```
version: "2"

services:
  kodi:
   image: fhriley/kodi-headless-vnc
   restart: always
   init: true
   ports:
     - "8000:8000/tcp"
     - "8080:8080/tcp"
   environment:
     KODI_DB_HOST: 192.168.1.246
     KODI_TV_SOURCE: nfs://nas/zfs/media/tv/
     KODI_MOVIES_SOURCE: nfs://nas/zfs/media/movies/
     KODI_UID: 2000
     KODI_GID: 2000
   volumes:
     - ./kodi_data:/data
```

Container environment variables:

* `KODI_DB_HOST` - MySQL database host address (default `mysql`)
* `KODI_DB_USER` - MySQL user for Kodi (default `kodi`)
* `KODI_DB_PASS` - MySQL password for Kodi user (default `kodi`)
* `KODI_DB_PORT` - MySQL remote port (default `3306`)
* `KODI_TV_SOURCE` - Path to the tv library (default `/data/tv`)
* `KODI_MOVIES_SOURCE` - Path to the movies library (default `/data/movies`)
* `KODI_UID` - The user ID to run all processes in the container under (default `2000`)
* `KODI_GID` - The group ID to run all processes in the container under (default `2000`)

You may also mount your own copy of `advancedsettings.xml` at `/data/.kodi/userdata/advancedsettings.xml` if you like to. The container startup will then skip any of the database configuration variables (KODI_DB*) and just use the supplied copy.

You may also mount your own copy of `sources.xml` at `/data/.kodi/userdata/sources.xml` if you like to. The container startup will then skip any of the source configuration variables (KODI_*_SOURCE) and just use the supplied copy.

__WARNING__: A misconfigured sources.xml can lead to the Kodi instance not finding any of your media which will result in emptying your database. Make a backup of your database and/or be double sure before enabling this feature!

# Credits

Thanks goes out to user [milaq](https://github.com/milaq/kodi-headless). This README is a modified version of his README.
