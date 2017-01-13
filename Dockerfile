FROM fedora:24
MAINTAINER https://github.com/vodolaz095/makefedora/issues

RUN dnf upgrade -y && dnf install -y make && dnf clean all

ADD Makefile /root
ADD contrib/ /root/
