#!/bin/bash
WILDFLY_VERSION="9.0.1.Final"
WILDFLY_FILENAME="wildfly-$WILDFLY_VERSION.tar.gz"
WILDFLY_NATIVE="false"

if [ "$WILDFLY_NATIVE" == "true" ]; then 
    echo "Not supported yet"
else 
    echo -e "\e[1;31mI know this is not good... I do not install wildfly from repository, like\n\e[0;36m# sudo dnf install -y wildfly\n\e[1;31mbecause it requires\nmore than \e[4;31m400Mb\e[0m\e[1;31m of dependencies. Which is IMHO a little bit to much\e[0m"
    #Downloading java
    sudo dnf -y install java-1.8.0-openjdk-headless
    #sudo dnf -y install java-1.8.0-openjdk-devel

    #Downloading wildfly
    curl http://download.jboss.org/wildfly/$WILDFLY_VERSION/$WILDFLY_FILENAME -o $WILDFLY_FILENAME -L
    WILDFLY_LOCATION=$(readlink -f $WILDFLY_FILENAME)


    pushd /opt
    sudo tar -zxf $WILDFLY_LOCATION
    sudo ln -s /opt/wildfly-$WILDFLY_VERSION /opt/wildfly 
    pushd /opt/wildfly

    sudo /opt/wildfly/bin/add-user.sh  --user admin --password wildfly
    popd
    popd
    echo "Cleaning up wildfly"
    sudo rm -rf $WILDFLY_LOCATION
    echo -e "\e[0;32mAdding wilfdfly user $WILDFLYUSER \e[0m"
    sudo sed -i '22a #Added by wildfly.sh; 23a '$WILDFLYUSER'='$WILDFLYPASSWORDHASH';' /opt/wildfly/standalone/configuration/mgmt-users.properties

    echo "Configuring wildfly unit"
cat > /usr/lib/systemd/system/wildfly.service << EOF
[Unit]
Description=The WildFly Application Server
After=syslog.target network.target
Before=httpd.service

[Service]
Environment=LAUNCH_JBOSS_IN_BACKGROUND=1
EnvironmentFile=-/etc/sysconfig/wildfly
User=wildfly
LimitNOFILE=102642
PIDFile=/var/run/wildfly/wildfly.pid
ExecStart=/opt/wildfly/bin/launch.sh \$WILDFLY_MODE \$WILDFLY_CONFIG \$WILDFLY_BIND \$WILDFLY_MANAGEMENT_BIND 
#StandardOutput=null

[Install]
WantedBy=multi-user.target

EOF

cat > /opt/wildfly/bin/launch.sh << EOF
#!/bin/sh

if [ "x\$WILDFLY_HOME" = "x" ]; then
    WILDFLY_HOME="/opt/wildfly"
fi
if [ \$# -eq 4 ]; then 
    if [[ "\$1" == "domain" ]]; then
        \$WILDFLY_HOME/bin/domain.sh -c \$2 -b \$3 -bmanagement \$4
    else
        \$WILDFLY_HOME/bin/standalone.sh -c \$2 -b \$3 -bmanagement \$4
    fi

else 
    if [[ "\$1" == "domain" ]]; then
        \$WILDFLY_HOME/bin/domain.sh -c \$2 -b \$3
    else
        \$WILDFLY_HOME/bin/standalone.sh -c \$2 -b \$3
    fi
fi

EOF

sudo chmod 0755 /opt/wildfly/bin/launch.sh

cat > /etc/sysconfig/wildfly << EOF
# The configuration you want to run
#
WILDFLY_CONFIG=standalone.xml

# The mode you want to run
WILDFLY_MODE=standalone

# The address to bind to
#
WILDFLY_BIND=0.0.0.0
WILDFLY_MANAGEMENT_BIND=0.0.0.0

EOF

echo -e "\e[0;32mAdding wildfly user\e[0m"
sudo groupadd -g 185 wildfly
sudo useradd -d /opt/wildfly -s /sbin/nologin -c "The WildFly Application Server user" -g 185 -u 185 -r wildfly


echo -e "\e[0;32mUpdating permissions \e[0m"
sudo chown -HR wildfly:wildfly /opt/wildfly

echo -e "\e[0;32mEnabling and starting wildfly service\e[0m"
sudo systemctl daemon-reload
sudo systemctl enable wildfly.service
sudo systemctl start wildfly.service

#sudo cp /vagrant/Greeter-0.3.war /opt/wildfly/standalone/deployments/
sudo dnf -y install maven git

echo -e "\e[0;32mCloning the greater git repo\e[0m"
git clone https://github.com/maskimko/Greeter.git
pushd Greeter
echo -e "\e[0;32mDeploying the greater\e[0m"
mvn package
popd

echo -e "\e[0;32mConfiguring apache welcome\e[0m"
sudo  sed -i '/<body>/ a <script type="text/javascript">\nvar ip = location.host;\nwindow.location.replace("http://"+ip+":8080/Greeter-0.3");\n</script>' /usr/share/httpd/noindex/index.html

fi
