#! /bin/bash

echo "---> Installing neutron on compute1"
set -e
set -x
apt install -y neutron-linuxbridge-agent > /dev/null
crudini --del /etc/neutron/neutron.conf database connection
crudini --set /etc/neutron/neutron.conf DEFAULT transport_url 'rabbit://openstack:openstack@controller:5672/'
crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone
crudini --set /etc/neutron/neutron.conf keystone_authtoken www_authenticate_uri http://controller:5000/v3
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_url http://controller:5000/v3
crudini --set /etc/neutron/neutron.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_type password
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_domain_name default
crudini --set /etc/neutron/neutron.conf keystone_authtoken user_domain_name default
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_name service
crudini --set /etc/neutron/neutron.conf keystone_authtoken username neutron
crudini --set /etc/neutron/neutron.conf keystone_authtoken password openstack
crudini --set /etc/neutron/neutron.conf oslo_concurrency lock_path /var/lib/neutron/tmp
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings provider:enp0s9
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan true
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan local_ip 10.0.0.31
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan l2_population true
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group true
crudini --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
crudini --set /etc/nova/nova.conf neutron auth_url http://controller:5000/v3
crudini --set /etc/nova/nova.conf neutron auth_type password
crudini --set /etc/nova/nova.conf neutron project_domain_name default
crudini --set /etc/nova/nova.conf neutron user_domain_name default
crudini --set /etc/nova/nova.conf neutron region_name RegionOne
crudini --set /etc/nova/nova.conf neutron project_name service
crudini --set /etc/nova/nova.conf neutron username neutron
crudini --set /etc/nova/nova.conf neutron password openstack
service nova-compute restart
service neutron-linuxbridge-agent restart
set +x 
echo "---> Neutron on compute1 installed"
