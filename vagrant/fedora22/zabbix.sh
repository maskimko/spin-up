#!/bin/bash
echo -e "\e[0;32mInstalling Zabbix\e[0m"
sudo dnf -y install zabbix zabbix-server zabbix-server-mysql zabbix-agent zabbix-web zabbix-web-mysql

echo "Creating database for zabbix"
mysql -u root << EOF
create database zabbix character set utf8 collate utf8_bin;
grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';
exit
EOF

pushd /usr/share/zabbix-mysql
 mysql -uroot zabbix < schema.sql
 mysql -uroot zabbix < images.sql
 mysql -uroot zabbix < data.sql
popd
sudo sed -i '/DBPassword/ s/^# *//; s/=.*$/=zabbix/'   /etc/zabbix/zabbix_server.conf 

