#!/bin/bash
if [ -z "$(rpm -qa | grep mariadb-server)" ]; then 
    echo -e "\e[0;32m\tInstalling mariadb-server\e[0m"
    dnf -y install mariadb mariadb-server mariadb-config
else 
    echo -e "\e[0;32m\tmariadb-server has been installed before\e[0m"
fi

sudo systemctl enable mariadb.service
systemctl status mariadb.service
if [ $? -ne 0 ]; then 
    sudo systemctl start mariadb.service
    [ $? -eq 0 ] || echo -e "\e[0;31m\tERROR: cannot start mariadb-server\e[0m"
else
    echo -e "\e[0;32m\tmariadb-server has been started before\e[0m"
fi

