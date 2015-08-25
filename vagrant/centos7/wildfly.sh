#!/bin/bash
WILDFLY_FILENAME="wildfly-9.0.1.Final.tar.gz"

#Downloading java
#sudo dnf -y install java-1.8.0-openjdk-headless
sudo dnf -y install java-1.8.0-openjdk-devel

#Downloading wildfly
curl http://download.jboss.org/wildfly/9.0.1.Final/$WILDFLY_FILENAME -o $WILDFLY_FILENAME -L
WILDFLY_LOCATION=$(readlink -f $WILDFLY_FILENAME)
sudo mkdir /opt/wildfly 

pushd /opt/wildfly
sudo tar -zxf $WILDFLY_LOCATION

