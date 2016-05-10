#!/bin/sh


echo "Start SSHD service"
systemctl enable sshd
systemctl start sshd

echo "Remove junky programs i hate"
dnf -y remove clipit asunder gnomebaker lxmusic gnumeric osmo pidgin xpad

echo "Upgrade system"
dnf -y upgrade

echo "Install rpm fussion repos"
dnf -y install http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm 
dnf -y install http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

echo "Install video player"
dnf -y install smplayer

echo "Install MPD server and client"
dnf -y install mpd lame ncmpc

echo "Install my favourite desctop programs"
dnf -y install rednotebook swift firefox screen mc system-config-users sqliteman libpng12 liferea sshfs keepassx seahorse gnupg gnupg2 scrot system-config-users

echo "Install foto editing tools"
dnf -y install shotwell rawstudio gimp

echo "Install and start Tor"
dnf -y install tor
systemctl enable tor
systemctl start tor

echo "Install nodejs of actual version and tools required"
dnf -y install gcc-c++ make dnf-plugins-core krb5-libs krb5-devel git
dnf -y copr enable nibbler/nodejs
dnf -y install nodejs nodejs-devel npm

echo "Install Go of actual version"
dnf -y install golang golang-godoc

echo "Install ruby for heroku toolchain"
dnf -y install ruby

echo "Install syncthing"
dnf -y copr enable decathorpe/syncthing
dnf -y install syncthing
systemctl enable syncthing@vodolaz095
systemctl start syncthing@vodolaz095

echo "Install databases"
dnf -y install mongodb mongodb-server redis
systemctl enable redis
systemctl enable mongod
systemctl start redis
systemctl start mongod

echo "Install hipchat"
echo "[atlassian-hipchat]
name=Atlassian Hipchat
baseurl=http://downloads.hipchat.com/linux/yum
enabled=1
gpgcheck=1
gpgkey=https://www.hipchat.com/keys/hipchat-linux.key
" > /etc/yum.repos.d/atlassian-hipchat.repo
dnf -y install hipchat

echo "Install steam"
#dnf config-manager --add-repo=http://negativo17.org/repos/fedora-steam.repo
dnf -y install steam

echo "Install docker"
dnf -y install docker

echo "Install JRE"
dnf -y install /home/shared/shared/soft/jre-8u66-linux-x64.rpm

echo "Install skype"
dnf -y install /home/shared/shared/soft/skype-4.3.0.37-fedora.i586.rpm

echo "Install viber"
dnf -y install /home/shared/shared/soft/viber.rpm

echo "Install upwork"
dnf -y copr enable red/libgcrypt.so.11
dnf -y install /home/shared/shared/soft/upwork_x86_64.rpm
