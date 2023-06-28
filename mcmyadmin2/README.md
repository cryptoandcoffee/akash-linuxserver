[linuxserverurl]: https://linuxserver.io
[forumurl]: https://forum.linuxserver.io
[ircurl]: https://www.linuxserver.io/irc/
[podcasturl]: https://www.linuxserver.io/podcast/
[appurl]: https://www.mcmyadmin.com/
[hub]: https://hub.docker.com/r/linuxserver/mcmyadmin2/

THIS IMAGE IS DEPRECATED. We will no longer be making updates or rebuilding this image. The Dockerhub endpoint will stay online with the current tags for this software.

[![linuxserver.io](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/linuxserver_medium.png)][linuxserverurl]

The [LinuxServer.io][linuxserverurl] team brings you another container release featuring easy user mapping and community support. Find us for support at:
* [forum.linuxserver.io][forumurl]
* [IRC][ircurl] on freenode at `#linuxserver.io`
* [Podcast][podcasturl] covers everything to do with getting the most from your Linux Server plus a focus on all things Docker and containerisation!

# linuxserver/mcmyadmin2
[![](https://images.microbadger.com/badges/version/linuxserver/mcmyadmin2.svg)](https://microbadger.com/images/linuxserver/mcmyadmin2 "Get your own version badge on microbadger.com")[![](https://images.microbadger.com/badges/image/linuxserver/mcmyadmin2.svg)](https://microbadger.com/images/linuxserver/mcmyadmin2 "Get your own image badge on microbadger.com")[![Docker Pulls](https://img.shields.io/docker/pulls/linuxserver/mcmyadmin2.svg)][hub][![Docker Stars](https://img.shields.io/docker/stars/linuxserver/mcmyadmin2.svg)][hub][![Build Status](https://ci.linuxserver.io/buildStatus/icon?job=Docker-Builders/x86-64/x86-64-mcmyadmin2)](https://ci.linuxserver.io/job/Docker-Builders/job/x86-64/job/x86-64-mcmyadmin2/)

[McMyAdmin][appurl] combines minecraft with a web control panel and admin console so can take a little while to start up.

[![mcmyadmin](https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/mcmyadmin-banner.png)][appurl]

## Usage

```
 docker create --name=mcmyadmin \
 -v <path to data>:/minecraft \
 -e PGID=<gid> -e PUID=<uid> \
 -p 8080:8080 -p 25565:25565 \
 linuxserver/mcmyadmin2

```

## Parameters

`The parameters are split into two halves, separated by a colon, the left hand side representing the host and the right the container side. 
For example with a port -p external:internal - what this shows is the port mapping from internal to external of the container.
So -p 8080:80 would expose port 80 from inside the container to be accessible from the host's IP on port 8080
http://192.168.x.x:8080 would show you what's running INSIDE the container on port 80.`



* `-p 8080:8080` - Mcmyadmin webui port. 
* `-p 25565:25565` -  Minecraft game server port.
* `-v <path to data>:/minecraft` - The location to store all your permanent files server jars\maps