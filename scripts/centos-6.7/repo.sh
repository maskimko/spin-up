#!/bin/bash

set -e
set -x
sudo sed -i "1a nameserver 8.8.8.8" /etc/resolv.conf

sudo yum -y install https://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
sudo sed -i -e 's/^enabled=1/enabled=0/' /etc/yum.repos.d/epel.repo
