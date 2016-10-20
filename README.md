Make Fedora
====================================
Very opinionated Makefile to help you install all things required on Fedora 24 linux more easily.


Usage
====================================

```shell

	$ curl -o /root/Makefile https://raw.githubusercontent.com/vodolaz095/makefedora/master/Makefile
	$ sudo make upgrade

```

List of available recipes
====================================
Majority of commands requires root access. The ones, that require ordinary user access,
are marked with `*`

- `clean`,`clear` - remove standard Fedora linux distribution programs i dislike 

###Console###
This commands installs packages aimed to be used on headless server with remote access, no X server required

- `console` - install many usefull console commands and enable `SSHD` server for remote access.

- `docker` - install [http://docker.io/](Docker)  (with stack settings), enable and start it

- `golang` - install [https://golang.org/](Golang) compiler
- `golangEnv` `*` - set Golang environment for current user like they say in [https://golang.org/doc/code.html#Workspaces]

- `nginx` - install [http://nginx.org/](nginx) web server (with stack settings), enable and start it. With some showel dancing around selinux.
- `exposeNginx` - use firewalld to allow nginx listen on 80 and 443

- `redis` - install [http://redis.io/](redis) server (with stack settings), enable and start it 
- `exposeRedis` - make redis listening on 0.0.0.0:6379 and tune firewalld accordingly. `TODO` - you need to test password on it

- `music` - install music related applications - [https://www.musicpd.org/](mpd), mp3 codecs and so on from [http://rpmfusion.org/](RPMFusion) repositories

- `mongo`  - install [https://www.mongodb.com/](mongo) server (with stack settings), enable and start it
- `exposeMongo` - make mongodb listening on 0.0.0.0:27017 and tune firewalld accordingly. `TODO` - you need to set password for it!

- `syncthing` - install [https://syncthing.net/](Syncthing) open source file synchronization system via [https://copr.fedoraproject.org/coprs/decathorpe/syncthing/](COPR) repo

- `tor` - install [http://torproject.org/](tor) proxy server (with stack settings), enable and start it 

- `mariadb` - install [https://mariadb.org/](MariaDB) relational database and use sligh changed stack settings for it suitable for development (supports INNODB, use <64 MB of memory)         
- `exposeMariadb` - make `mariadb` listen on 0.0.0.0:3306 and tune `firewalld` accordingly   

- `nodejs` - install most recent [http://nodejs.org/](Nodejs) from [https://copr.fedoraproject.org/coprs/nibbler/nodejs/](Nibbler's repo)
- `heroku` - install [http://heroku.com/](Heroku) hosting provider [http://toolchain.heroku.com/](toolbelt)
- `aws` - install [http://aws.amazon.com/cli](Amazon Webservices Console)

###GUI commands###
This commands aimed to be executed on computer with X server enabled

- `gui` - install basic gui tools i like      
- `viber` - install [http://viber.com/](viber) client
- `hipchat` - install [http://hipchat.com/](hipchat) client
- `foto` - install foto editing tools - [http://yorba.org/shotwell](Shotwell) [https://rawstudio.org/](Rawstudio) and [https://www.gimp.org/](Gimp)           
- `video` - install [http://smplayer.sourceforge.net/](smplayer) for playing videos alongside with [https://github.com/alessio/camorama](Camorama) to play with webcam
- `steam` - install [http://store.steampowered.com/](Steam) client to play games
- `skype` - install [https://www.skype.com/](Skype) to chat
- `xflux` - install [https://justgetflux.com/linux.html](xflux) to make your eyes healthier

### Profile commands ###

- `env` - set user environment.

### Misc commands###

- `upgrade` - upgrade system  
- `rpmfusion` - enable [http://rpmfusion.org/](RPMFusion) repositories  

