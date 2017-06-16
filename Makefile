export MYUID=$(shell id -u)
export SUPPORTED_FEDORA_RELEASE=25
export FEDORA_RELEASE=$(shell rpm -E %fedora)

isFedora:
	@if [ -a /etc/fedora-release ]; then echo "We have fedora linux!"; else  echo "Wrong distribution!";exit 1;fi;
ifeq ($(FEDORA_RELEASE),$(SUPPORTED_FEDORA_RELEASE))
	@echo "Running on supported Fedora $(FEDORA_RELEASE)..."
else
	@echo "Running on unsupported Fedora $(FEDORA_RELEASE)! We need the Fedora $(SUPPORTED_FEDORA_RELEASE)"
	@exit 1
endif


isRoot: isFedora
ifeq ($(MYUID),0)
	@echo "Running as root..."
else
	@echo "Running as ordinary user! Please, change to root!"
	@exit 1
endif

isNotRoot: isFedora
ifneq ($(MYUID),0)
	@echo "Running as ordinary user..."
else
	@echo "Running as root! Please, change to ordinary user!"
	@exit 1
endif


clean: isRoot
	@echo "Remove junky programs i hate..."
	dnf -y4 remove asunder gnomebaker lxmusic osmo pidgin xpad

clear: clean

rpmfusion: isRoot
	@echo "Install rpm fussion repos..."
	dnf -y4 install http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(FEDORA_RELEASE).noarch.rpm 
	dnf -y4 install http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(FEDORA_RELEASE).noarch.rpm

upgrade: isRoot
	@echo "Upgrading system!..."
	dnf clean all
	dnf -y4 upgrade

console: upgrade
	@echo "Installing console tools..."
	dnf -y4 install screen mc sshfs gnupg gnupg2 acpi git dnf-plugins-core make wget curl telegram-cli elinks lynx avahi firewalld wavemon zip unzip chkrootkit
	systemctl enable sshd
	systemctl start sshd
	systemctl start firewalld
	cp contrib/avahi/services/* /etc/avahi/services/
	chown root:root /etc/avahi/services -Rv
	restorecon -Rv /etc/avahi/services

gui: console
	@echo "Installing desktop applications..."
	dnf -y4 install rednotebook swift firefox system-config-users sqliteman libpng12 liferea keepassx seahorse scrot system-config-firewall setroubleshoot gparted mediawriter xsel xclip puddletag audacity

music: console rpmfusion
	@echo "Installing music related applications..."
	dnf -y4 install mpd lame ncmpc ffmpeg

video: gui rpmfusion
	@echo "Installing video related tools..."
	dnf -y4 install smplayer camorama

redis: console
	@echo "Installing redis database..."
	dnf -y4 install redis
	systemctl start redis
	systemctl enable redis

exposeRedis: redis
	@echo "Making redis listen on 0.0.0.0:6379"
	cp contrib/firewalld/services/redis.xml /etc/firewalld/services/redis.xml
	restorecon -Rv /etc/firewalld/services
	firewall-cmd --reload

	@echo "Enabling firewalld config for home zone..."
	firewall-cmd --add-service=redis --permanent --zone=home

	@echo "Enabling firewalld config for work zone..."
	firewall-cmd --add-service=redis --permanent --zone=work

	@echo "Enabling firewalld config for public zone..."
	firewall-cmd --add-service=redis --permanent --zone=public
	firewall-cmd --reload


mongo: console
	@echo "Installing mongo database..."
	dnf -y4 install mongodb mongodb-server
	systemctl start mongod
	systemctl enable mongod

exposeMongo: mongo
	@echo "Making mongo database listen on 0.0.0.0:27017..."
	cp contrib/firewalld/services/mongod.xml /etc/firewalld/services/mongod.xml
	restorecon -Rv /etc/firewalld/services
	firewall-cmd --reload

	@echo "Enabling firewalld config for home zone..."
	firewall-cmd --add-service=mongod --permanent --zone=home

	@echo "Enabling firewalld config for work zone..."
	firewall-cmd --add-service=mongod --permanent --zone=work

	@echo "Enabling firewalld config for public zone..."
	firewall-cmd --add-service=mongod --permanent --zone=public
	firewall-cmd --reload

mariadb: console
	@echo "Installing MariaDB database..."
	dnf -y4 install mariadb mariadb-server mycli
	systemctl start mariadb
	systemctl stop mariadb
	cp -f contrib/my.cnf /etc/my.cnf
	chown root:root /etc/my.cnf
	systemctl start mariadb
	systemctl enable mariadb
	#mysql_secure_installation -u root -p

exposeMariadb: mariadb
	@echo "Making MariaDB database listen on 0.0.0.0:3306..."

	@echo "Enabling firewalld config for home zone..."
	firewall-cmd --add-service=mysql --permanent --zone=home

	@echo "Enabling firewalld config for work zone..."
	firewall-cmd --add-service=mysql --permanent --zone=work

	@echo "Enabling firewalld config for public zone..."
	firewall-cmd --add-service=mysql --permanent --zone=public
	firewall-cmd --reload


mysql_workbench: isRoot
	dnf install -y https://dev.mysql.com/get/mysql57-community-release-fc$(FEDORA_RELEASE)-9.noarch.rpm
	dnf install -y mysql-workbench-community

golang: console
	@echo "Installing golang toolchain"
	dnf -y4 install golang golang-godoc

env: isNotRoot
	@echo "Setting environment for current user"
	@rm -f $(HOME)/.bash_profile
	@cat contrib/skel/.bash_profile > $(HOME)/.bash_profile
	@mkdir -p $(HOME)/go
	@mkdir -p $(HOME)/bin

nodejs: console
	@echo "Install nodejs of actual version and tools required"
	dnf -y install gcc-c++ krb5-libs krb5-devel nodejs nodejs-devel npm
	node -v
	npm -v

tor: console
	@echo "Install and start Tor"
	dnf -y4 install tor
	systemctl enable tor
	systemctl start tor

foto: gui
	@echo "Install foto editing tools"
	dnf -y install shotwell rawstudio gimp

syncthing: console
	@echo "Installing Syncthing application"
	dnf -y copr enable decathorpe/syncthing
	dnf -y install syncthing
	cp contrib/firewalld/services/syncthing.xml /etc/firewalld/services/syncthing.xml
	restorecon -Rv /etc/firewalld/services
	firewall-cmd --reload

	@echo "Enabling firewalld config for home zone..."
	firewall-cmd --add-service=syncthing --permanent --zone=home

	@echo "Enabling firewalld config for work zone..."
	firewall-cmd --add-service=syncthing --permanent --zone=work

	@echo "Enabling firewalld config for public zone..."
	firewall-cmd --add-service=syncthing --permanent --zone=public
	firewall-cmd --reload

aws: console
	dnf -y4 install awscli

heroku: console
	@echo "Installing Heroku toolchain"
	rm -rf /usr/local/heroku
	mkdir -p /usr/local/heroku
	mkdir -p /tmp/heroku/heroku-client
	curl https://cli-assets.heroku.com/branches/stable/heroku-linux-amd64.tar.gz  >> /tmp/heroku-client.tar.gz
	tar -zxvf /tmp/heroku-client.tar.gz --directory /tmp/heroku/
	mv /tmp/heroku/heroku-client /usr/local/heroku/
	rm -rf /tmp/heroku/
	rm -f /tmp/heroku-client.tar.gz
	ln -s /usr/local/heroku/bin/heroku /usr/bin/heroku

micro: console
	@echo "Installing Micro text editor"
	wget https://github.com/zyedidia/micro/releases/download/v1.1.4/micro-1.1.4-linux64.tar.gz -O /tmp/micro.tar.gz
	mkdir -p /tmp/micro/
	tar -zxvf /tmp/micro.tar.gz --directory /tmp/micro/
	mv /tmp/micro/micro-1.1.4/micro /usr/bin/micro
	chown root:root /usr/bin/micro
	rm -rf /tmp/micro/
	rm -f /tmp/micro.tar.gz

hipchat: gui
	@echo "Installing hipchat"
	rm -f /etc/yum.repos.d/atlassian-hipchat.repo
	@echo "[atlassian-hipchat]" >> /etc/yum.repos.d/atlassian-hipchat.repo
	@echo "name=Atlassian Hipchat" >> /etc/yum.repos.d/atlassian-hipchat.repo
	@echo "baseurl=http://downloads.hipchat.com/linux/yum" >> /etc/yum.repos.d/atlassian-hipchat.repo
	@echo "enabled=1" >> /etc/yum.repos.d/atlassian-hipchat.repo
	@echo "gpgcheck=1" >> /etc/yum.repos.d/atlassian-hipchat.repo
	@echo "gpgkey=https://www.hipchat.com/keys/hipchat-linux.key" >> /etc/yum.repos.d/atlassian-hipchat.repo
	dnf -y install hipchat

steam: rpmfusion gui
	@echo "Installing steam"
	dnf -y install steam

flux: gui
	@echo "Installing flux..."
	mkdir -p /tmp/xflux
	curl  https://justgetflux.com/linux/xflux64.tgz >> /tmp/xflux/xflux64.tgz
	tar -zxvf /tmp/xflux/xflux64.tgz --directory /tmp/xflux/
	mv /tmp/xflux/xflux /usr/bin/xflux
	chown root:root /usr/bin/xflux
	rm -rf /tmp/xflux/

docker: console
	@echo "Installing docker"
	dnf -y install docker docker-compose
	systemctl start docker
	systemctl enable docker

nginx: console
	@echo "Installing nginx. Web root will be in /srv/www/{domain_name}!"
	#http://blog.frag-gustav.de/2013/07/21/nginx-selinux-me-mad/
	dnf -y install nginx certbot
	mkdir -p /srv/www/
	chown nginx:root /srv/www/ -Rv
	chcon -Rt httpd_sys_content_t /srv/www/
	setsebool -P httpd_can_network_connect 1
	systemctl start nginx
	systemctl enable nginx

exposeNginx: nginx
	@echo "Making nginx listen on 80 and 443 ports"
	@echo "Enabling firewalld config for home zone..."
	firewall-cmd --add-service=http --permanent --zone=home
	firewall-cmd --add-service=https --permanent --zone=home
	@echo "Enabling firewalld config for work zone..."
	firewall-cmd --add-service=http --permanent --zone=work
	firewall-cmd --add-service=https --permanent --zone=work
	@echo "Enabling firewalld config for public zone..."
	firewall-cmd --add-service=http --permanent --zone=public
	firewall-cmd --add-service=https --permanent --zone=public
	firewall-cmd --reload

telegram: isNotRoot
	@echo "Installing Telegram messenger..."
	@mkdir -p /tmp/telegram/output/
	@mkdir -p $(HOME)/bin
	wget https://telegram.org/dl/desktop/linux -O /tmp/telegram/telegram.tar.xz
	@tar xpvf /tmp/telegram/telegram.tar.xz -C /tmp/telegram/output/
	@cp /tmp/telegram/output/Telegram/Telegram $(HOME)/bin/Telegram
	@cp /tmp/telegram/output/Telegram/Updater $(HOME)/bin/Updater
	@rm -rf /tmp/telegram

gitolite: isRoot
	dnf install -y git openssh perl
	systemctl restart sshd
	systemctl enable sshd
	useradd -m git
	passwd -l git
	rm -rf /home/git/.ssh/*
	rm -rf /home/git/gitolite
	rm -rf /home/git/repositories
	mkdir -p /home/git/bin
	cp /home/vodolaz095/.ssh/id_rsa.pub /home/git/admin.pub
	cp contrib/gitolite-install.sh /home/git/
	chown git:git /home/git -Rv
	su -l git -c '/home/git/gitolite-install.sh'

rethinkdb: isRoot console
	mv contrib/yum.repos.d/rethinkdb.repo /etc/yum.repos.d/rethinkdb.repo
	restorecon -Rv /etc/yum.repos.d/rethinkdb.repo
	dnf install -y rethinkdb
	cp contrib/firewalld/services/rethinkdb_cluster.xml /etc/firewalld/services/
	cp contrib/firewalld/services/rethinkdb_server.xml  /etc/firewalld/services/
	restorecon -Rv /etc/firewalld/services
	firewall-cmd --reload
	#https://www.rethinkdb.com/docs/start-on-startup/
	systemctl start rethinkdb
	systemctl enable rethinkdb
	
exposeRethinkDBServer: rethinkdb
	@echo "Making rethinkdb listen on 28015(server)"
	cp contrib/firewalld/services/redis.xml /etc/firewalld/services/redis.xml
	restorecon -Rv /etc/firewalld/services
	firewall-cmd --reload


	@echo "Enabling firewalld config for home zone..."
	firewall-cmd --add-service=rethinkdb_server --permanent --zone=home
	firewall-cmd --add-service=rethinkdb_server --permanent --zone=home

	@echo "Enabling firewalld config for work zone..."
	firewall-cmd --add-service=rethinkdb_server --permanent --zone=work
	firewall-cmd --add-service=rethinkdb_server --permanent --zone=work

	@echo "Enabling firewalld config for public zone..."
	firewall-cmd --add-service=rethinkdb_server --permanent --zone=public
	firewall-cmd --add-service=rethinkdb_server --permanent --zone=public
	firewall-cmd --reload

exposeRethinkDBServerCluster: exposeRethinkDBServer
	@echo "Making rethinkdb listen on 28015(server) and 29015(cluster)"
	@echo "Enabling firewalld config for home zone..."
	firewall-cmd --add-service=rethinkdb_server --permanent --zone=home
	firewall-cmd --add-service=rethinkdb_server --permanent --zone=home
	firewall-cmd --add-service=rethinkdb_cluster --permanent --zone=home
	firewall-cmd --add-service=rethinkdb_cluster --permanent --zone=home

	@echo "Enabling firewalld config for work zone..."
	firewall-cmd --add-service=rethinkdb_server --permanent --zone=work
	firewall-cmd --add-service=rethinkdb_server --permanent --zone=work
	firewall-cmd --add-service=rethinkdb_cluster --permanent --zone=work
	firewall-cmd --add-service=rethinkdb_cluster --permanent --zone=work

	@echo "Enabling firewalld config for public zone..."
	firewall-cmd --add-service=rethinkdb_server --permanent --zone=public
	firewall-cmd --add-service=rethinkdb_server --permanent --zone=public
	firewall-cmd --add-service=rethinkdb_cluster --permanent --zone=public
	firewall-cmd --add-service=rethinkdb_cluster --permanent --zone=public

	firewall-cmd --reload


all: clean gui docker golang nodejs video music syncthing redis mariadb flux micro telegram

desctop: all

server: clean docker golang nodejs syncthing micro exposeNginx exposeMariadb exposeRedis gitolite
