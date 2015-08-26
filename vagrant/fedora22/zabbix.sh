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
sudo sed  '/[# ]\+DBPassword *=/ s/^#\+ *//; /DBPassword/ s/DBPassword=.*$/DBPassword=zabbix/' /etc/zabbix_server.conf

cat > /etc/zabbix/web/zabbix.conf.php << EOF
<?php
// Zabbix GUI configuration file.
global \$DB;

\$DB['TYPE']     = 'MYSQL';
\$DB['SERVER']   = 'localhost';
\$DB['PORT']     = '3306';
\$DB['DATABASE'] = 'zabbix';
\$DB['USER']     = 'zabbix';
\$DB['PASSWORD'] = 'zabbix';

// Schema name. Used for IBM DB2 and PostgreSQL.
\$DB['SCHEMA'] = '';

\$ZBX_SERVER      = '0.0.0.0';
\$ZBX_SERVER_PORT = '10051';
\$ZBX_SERVER_NAME = 'zabbix-server';

\$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
?>
EOF
cat >> /etc/httpd/conf.d/zabbix.conf << EOF

php_value max_execution_time 300
php_value memory_limit 128M
php_value post_max_size 16M
php_value upload_max_filesize 2M
php_value max_input_time 300
php_value date.timezone Europe/Kiev
php_value always_populate_raw_post_data -1

EOF

echo -e "\e[0;33mDisabling selinux for zabbix server\e[0m"
sudo setenforce 0

echo -e "\e[0;33mEnabling zabbix-server\e[0m"
sudo systemctl enable zabbix-server.service
systemctl status zabbix-server.service
if [ $? -ne 0 ]; then 
    sudo systemctl start zabbix-server.service
    [ $? -eq 0 ] || echo -e "\e[0;31m\tERROR: cannot start zabbix-server\e[0m"
    systemctl status zabbix-server.service
else
    echo -e "\e[0;32m\tzabbix-server has been started before\e[0m"
fi

echo -e "\e[0;33mEnabling zabbix-agent\e[0m"
sudo systemctl enable zabbix-agent.service
systemctl status zabbix-agent.service
if [ $? -ne 0 ]; then 
    sudo systemctl start zabbix-agent.service
    [ $? -eq 0 ] || echo -e "\e[0;31m\tERROR: cannot start zabbix-agent\e[0m"
    systemctl status zabbix-agent.service
else
    echo -e "\e[0;32m\tzabbix-agent has been started before\e[0m"
fi

echo -e "\e[0;33mEnabling apache web server\e[0m"
sudo systemctl enable httpd.service
systemctl status httpd.service
if [ $? -ne 0 ]; then 
    sudo systemctl start httpd.service
    [ $? -eq 0 ] || echo -e "\e[0;31m\tERROR: cannot start zabbix-agent\e[0m"
    systemctl status httpd.service
else
    echo -e "\e[0;32m\tzabbix-agent has been started before\e[0m"
fi


echo -e "\e[0;33mEnabling zabbix server monitoring\e[0m"
mysql -uroot zabbix << EOF
 update hosts set status = 0 where hostid = (select hostid from hosts_groups where groupid =(select groupid from groups where name='Zabbix servers'));
EOF
[ $? -eq 0 ] || echo -e "\e[0;31mCannot execute MySQL update\e[0m"



