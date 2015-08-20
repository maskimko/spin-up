#
# Cookbook Name:: app-cookbook
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
execute "dnf upgrade"
#package "apache2"
execute "rm -rf /var/www"
#link "/var/www" do
#to "/vagrant"
#end
