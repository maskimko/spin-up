#
# Cookbook Name:: zabbix-monitor
# Recipe:: default
#
# Copyright 2015, 4Finance
#
 
if node["platform"] == "fedora" then 

    remote_file node['zabbix']['file_path'] do
      source "#{node['zabbix']['zabbix_repo']}"
      not_if "rpm -qa | grep 'zabbix-release'"
      notifies :install, "rpm_package[zabbix-release]", :immediately
      retries 5 # We may be redirected to a FTP URL, CHEF-1031.
    end

    rpm_package "zabbix-release" do
      source node['zabbix']['file_path']
      only_if { ::File.exists?(node['zabbix']['file_path']) }
      action :nothing
    end

    file "zabbix-release-cleanup" do
      path node['zabbix']['file_path']
      action :delete
    end

    package 'zabbix-agent' if platform_family?("suse", "rhel", "debian")

    template node['zabbix']['zabbix_agent']['config_path'] do
      source "#{node['zabbix']['zabbix_agent']['config_template']}"
      mode '0640'
      variables({
                    :server_ip => "#{node['zabbix']['server_ip']}"
                })
    end
else
    puts "This cookbook does not support #{node["platform"]} OS. It is intended to be used on Fedora only."
end
