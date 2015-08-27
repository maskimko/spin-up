#!/bin/bash 
: ${INSTALL_RVM:="false"}
echo -e "\e[0;32mStarting bash provisioning\e[0m"
echo -e "\e[0;32mPreparing environment\e[0m"
    . /vagrant/environment.sh
echo "Installing ruby gpg tar vim-enhanced net-tools"
    sudo dnf -y install ruby gnupg tar vim-enhanced net-tools
#Installing rvm ruby
if [ "$INSTALL_RVM" == "true" ]; then
    echo "Installing rvm"
    echo -e "\tImporting the key"
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
    echo -e "\tDownloading distribution"
    curl -sSL https://get.rvm.io | bash
echo "Installing Ruby version 1.9"
    source /etc/profile
    rvm install 1.9
echo "Using needed version"
    rvm use 1.9
else 
    echo -e "\e[0;31mI skip rvm installation, due to bash bootstrapping\e[0m"
fi
#Disable selinux
sudo setenforce 0
sudo sed -i 's/=enforcing/=permissive/' /etc/sysconfig/selinux 

echo -e "\e[0;32mInstalling and configuring MariaDB\e[0m"
    . /vagrant/mariadb.sh
echo -e "\e[0;32mInstalling and configuring Zabbix\e[0m"
    . /vagrant/zabbix.sh
echo -e "\e[0;32mInstalling Wildfly\e[0m"
    . /vagrant/wildfly.sh
echo -e "\e[0;32mInstalling Jmeter\e[0m"
    . /vagrant/jmeter.sh
echo -e "\e[0;33mEnd of provisioning script\e[0m"

