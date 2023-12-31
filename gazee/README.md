undefined[![linuxserver.io](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/linuxserver_medium.png)](https://linuxserver.io)

The [LinuxServer.io](https://linuxserver.io) team brings you another container release featuring :-

 * regular and timely application updates
 * easy user mappings (PGID, PUID)
 * custom base image with s6 overlay
 * weekly base OS updates with common layers across the entire LinuxServer.io ecosystem to minimise space usage, down time and bandwidth
 * regular security updates

Find us at:
* [Discord](https://discord.gg/YWrKVTn) - realtime support / chat with the community and the team.
* [IRC](https://irc.linuxserver.io) - on freenode at `#linuxserver.io`. Our primary support channel is Discord.
* [Blog](https://blog.linuxserver.io) - all the things you can do with our containers including How-To guides, opinions and much more!

# [linuxserver/gazee](https://github.com/linuxserver/docker-gazee)
[![](https://img.shields.io/discord/354974912613449730.svg?logo=discord&label=LSIO%20Discord&style=flat-square)](https://discord.gg/YWrKVTn)
[![](https://images.microbadger.com/badges/version/linuxserver/gazee.svg)](https://microbadger.com/images/linuxserver/gazee "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/linuxserver/gazee.svg)](https://microbadger.com/images/linuxserver/gazee "Get your own version badge on microbadger.com")
![Docker Pulls](https://img.shields.io/docker/pulls/linuxserver/gazee.svg)
![Docker Stars](https://img.shields.io/docker/stars/linuxserver/gazee.svg)
[![Build Status](https://ci.linuxserver.io/buildStatus/icon?job=Docker-Pipeline-Builders/docker-gazee/master)](https://ci.linuxserver.io/job/Docker-Pipeline-Builders/job/docker-gazee/job/master/)
[![](https://lsio-ci.ams3.digitaloceanspaces.com/linuxserver/gazee/latest/badge.svg)](https://lsio-ci.ams3.digitaloceanspaces.com/linuxserver/gazee/latest/index.html)

THIS IMAGE IS DEPRECATED, IT WILL NO LONGER RECEIVE UPDATES. [Gazee](https://github.com/hubbcaps/gazee) is a WebApp Comic Reader for your favorite digital comics. Reach and read your comic library from any web connected device with a modern web browser.

[![gazee](https://raw.githubusercontent.com/hubbcaps/gazee/master/public/images/logos/red/logo-red-yellow.png)](https://github.com/hubbcaps/gazee)

## Supported Architectures

Our images support multiple architectures such as `x86-64`, `arm64` and `armhf`. We utilise the docker manifest for multi-platform awareness. More information is available from docker [here](https://github.com/docker/distribution/blob/master/docs/spec/manifest-v2-2.md#manifest-list) and our announcement [here](https://blog.linuxserver.io/2019/02/21/the-lsio-pipeline-project/). 

Simply pulling `linuxserver/gazee` should retrieve the correct image for your arch, but you can also pull specific arch images via tags.

The architectures supported by this image are:

| Architecture | Tag |
| :----: | --- |
| x86-64 | amd64-latest |
| arm64 | arm64v8-latest |
| armhf | arm32v6-latest |


## Usage

Here are some example snippets to help you get started creating a container.

### docker

```
docker create \
  --name=gazee \
  -e PUID=1000 \
  -e PGID=1000 \
  -p 4242:4242 \
  -v /path/to/appdata/config:/config \
  -v path to comics:/comics \
  -v path to mylar data:/mylar \
  -v path to SSL certs:/certs \
  --restart unless-stopped \
  linuxserver/gazee
```


### docker-compose

Compatible with docker-compose v2 schemas.

```
---
version: "2"
services:
  gazee:
    image: linuxserver/gazee
    container_name: gazee
    environment:
      - PUID=1000
      - PGID=1000
    volumes:
      - /path/to/appdata/config:/config
      - path to comics:/comics
      - path to mylar data:/mylar
      - path to SSL certs:/certs
    ports:
      - 4242:4242
    restart: unless-stopped
```

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `external:internal` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 4242` | WebUI |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-v /config` | Where Gazee should store config files. |
| `-v /comics` | Path to comics folder. |
| `-v /mylar` | Path to Mylar DB. |
| `-v /certs` | Where SSL certs should be stored. |

## User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id user` as below:

```
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```


&nbsp;
## Application Setup

Webui can be found at `your-ip:4242`

  Default username and password for the web interface:

  * **Username:** `admin`
  * **Password:** `gazee`

Click the gear icon to go to the settings page.

Change the default admin password or add a new admin and remove the admin user altogether.

Comic path should be set to `/comics`

*Optional* Mylar DB path should be set to `/mylar`

*Optional* path for certificates and keys should be set to `/certs`

After you update the settings, Gazee will restart and begin an intial scan of your comic library.

Happy Reading!



## Support Info

* Shell access whilst the container is running: `docker exec -it gazee /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f gazee`
* container version number 
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' gazee`
* image version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' linuxserver/gazee`

## Updating Info

Most of our images are static, versioned, and require an image update and container recreation to update the app inside. With some exceptions (ie. nextcloud, plex), we do not recommend or support updating apps inside the container. Please consult the [Application Setup](#application-setup) section above to see if it is recommended for the image.  
  
Below are the instructions for updating containers:  
  
### Via Docker Run/Create
* Update the image: `docker pull linuxserver/gazee`
* Stop the running container: `docker stop gazee`
* Delete the container: `docker rm gazee`
* Recreate a new container with the same docker create parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* Start the new container: `docker start gazee`
* You can also remove the old dangling images: `docker image prune`

### Via Docker Compose
* Update all images: `docker-compose pull`
  * or update a single image: `docker-compose pull gazee`
* Let compose update all containers as necessary: `docker-compose up -d`
  * or update a single container: `docker-compose up -d gazee`
* You can also remove the old dangling images: `docker image prune`

### Via Watchtower auto-updater (especially useful if you don't remember the original parameters)
* Pull the latest image at its tag and replace it with the same env variables in one run:
  ```
  docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  --run-once gazee
  ```
* You can also remove the old dangling images: `docker image prune`

## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic: 
```
git clone https://github.com/linuxserver/docker-gazee.git
cd docker-gazee
docker build \
  --no-cache \
  --pull \
  -t linuxserver/gazee:latest .
```

The ARM variants can be built on x86_64 hardware using `multiarch/qemu-user-static`
```
docker run --rm --privileged multiarch/qemu-user-static:register --reset
```

Once registered you can define the dockerfile to use with `-f Dockerfile.aarch64`.

## Versions

* **27.03.19:** - Deprecate image and get in semi working state.
* **11.02.19:** - Add pipeline logic and multi arch.
* **17.08.18:** - Rebase to alpine 3.8.
* **30.12.17:** - Ensure version 11 of cherrypy.
* **07.12.17:** - Initial Release.
