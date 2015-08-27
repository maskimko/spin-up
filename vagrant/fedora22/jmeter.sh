#!/bin/bash
JMETER_VERSION="2.13"
JMETER_ARCHIVE="apache-jmeter-${JMETER_VERSION}.tgz"
PGP_LINK="https://www.apache.org/dist/jmeter/binaries/${JMETER_ARCHIVE}.asc"
MD5_LINK="https://www.apache.org/dist/jmeter/binaries/${JMETER_ARCHIVE}.md5"
TARBALL_LINK="http://apache.ip-connect.vn.ua//jmeter/binaries/${JMETER_ARCHIVE}"
INSTALL_PATH="/opt"
gpg --keyserver pgpkeys.mit.edu --recv-key 0612B399
curl $PGP_LINK -L -o ${JMETER_ARCHIVE}.asc
curl $MD5_LINK -L -o ${JMETER_ARCHIVE}.md5
curl $TARBALL_LINK -L -o $JMETER_ARCHIVE

if [ "$(md5sum ${JMETER_ARCHIVE} | cut -f 1 -d\  )" == "$(cat ${JMETER_ARCHIVE}.md5 | cut -f 1 -d\  )" ]; then 
        echo -e "\e[0;32mJmeter archive checksum has been successfully verified\e[0m"

        gpg --verify ${JMETER_ARCHIVE}.asc ${JMETER_ARCHIVE}
        if [ $? -eq 0 ]; then 
            echo -e "\e[0;32mJmeter archive sign has been successfully verified\e[0m"
            [ -d $INSTALL_PATH ] || sudo mkdir /opt/jmeter
            FULL_PATH=$(readlink -f $JMETER_ARCHIVE)
            pushd $INSTALL_PATH
            sudo tar -zxf $FULL_PATH
            sudo ln -s apache-jmeter-${JMETER_VERSION} jmeter
            ls -l $INSTALL_PATH
            popd
            rm -f ${JMETER_ARCHIVE}*
        else
            echo -e "\e[0;31mError: Cannot verify Jmeter archive\e[0m"
        fi
        if [ ! -d /vagrant/test-data ]; then 
           sudo mkdir /vagrant/test-data
        fi
        sudo chmod 1777 /vagrant/test-data
        JMETER_USER=$(whoami)
        echo "Changing jmeter owner to current user $JMETER_USER"
        sudo chown -HR $JMETER_USER /opt/jmeter

        echo "\e[0;32mLaunching jmeter stress test in $TIMEOUT seconds\e[0m"
        time /opt/jmeter/bin/jmeter -n -t /vagrant/WildflyResources.jmx 2>&1 | tee -a /vagrant/jmeter_exec_time.txt
        echo "\e[0;33mJmeter finish it's job\e[0m"
else 
    echo -e "\e[0;31mError: Wrong checksum of Jmeter archive\e[0m"
fi

