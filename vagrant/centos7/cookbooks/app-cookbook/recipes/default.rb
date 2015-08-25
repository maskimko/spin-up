#
# Cookbook Name:: app-cookbook
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
puts "Hello chef recipe"
puts "Installing ruby"
package "ruby"
puts "Installing gpg"
package "gpg"
puts "Installing tar"
package "tar"
puts "Installing vim-enhanced"
package "vim-enahnced"
puts "Installing rvm"
puts "\tImporting the key"
execute "gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3"
puts "\tDownloading distribution"
execute "curl -sSL https://get.rvm.io | bash"
puts "\tInstalling ruby version 1.9 for Chef"
execute "source /etc/profile; rvm install 1.9"
puts "\tSwitching to the ruby version 1.9"
execute "rvm use 1.9"
#puts "Upgrading the system"
#execute "sudo yum -y upgrade"
#package "apache2"
#execute "rm -rf /var/www"
#link "/var/www" do
#to "/vagrant"
#end
