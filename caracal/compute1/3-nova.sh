#! /bin/bash

echo "---> Installing nova on compute1"
set -e
set -x
DEBIAN_FRONTEND=noninteractive apt-get install -y nova-compute > /dev/null
crudini --set /etc/nova/nova.conf DEFAULT transport_url 'rabbit://openstack:openstack@controller'
crudini --set /etc/nova/nova.conf DEFAULT my_ip 10.0.0.31
crudini --set /etc/nova/nova.conf api auth_strategy keystone
crudini --set /etc/nova/nova.conf keystone_authtoken www_authenticate_uri http://controller:5000/
crudini --set /etc/nova/nova.conf keystone_authtoken auth_url http://controller:5000/
crudini --set /etc/nova/nova.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/nova/nova.conf keystone_authtoken auth_type password
crudini --set /etc/nova/nova.conf keystone_authtoken project_domain_name Default
crudini --set /etc/nova/nova.conf keystone_authtoken user_domain_name Default
crudini --set /etc/nova/nova.conf keystone_authtoken project_name service
crudini --set /etc/nova/nova.conf keystone_authtoken username nova
crudini --set /etc/nova/nova.conf keystone_authtoken password openstack
crudini --set /etc/nova/nova.conf service_user send_service_user_token true
crudini --set /etc/nova/nova.conf service_user auth_url 'https://controller/identity'
crudini --set /etc/nova/nova.conf service_user auth_strategy keystone
crudini --set /etc/nova/nova.conf service_user auth_type password
crudini --set /etc/nova/nova.conf service_user project_domain_name Default
crudini --set /etc/nova/nova.conf service_user project_name service
crudini --set /etc/nova/nova.conf service_user user_domain_name Default
crudini --set /etc/nova/nova.conf service_user username nova
crudini --set /etc/nova/nova.conf service_user password openstack
crudini --set /etc/nova/nova.conf vnc enabled true
crudini --set /etc/nova/nova.conf vnc server_listen 0.0.0.0
crudini --set /etc/nova/nova.conf vnc server_proxyclient_address '$my_ip'
crudini --set /etc/nova/nova.conf vnc novncproxy_base_url 'http://10.0.0.11:6080/vnc_auto.html'
crudini --set /etc/nova/nova.conf glance api_servers 'http://controller:9292'
crudini --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
crudini --set /etc/nova/nova.conf placement region_name RegionOne
crudini --set /etc/nova/nova.conf placement project_domain_name Default
crudini --set /etc/nova/nova.conf placement project_name service
crudini --set /etc/nova/nova.conf placement auth_type password
crudini --set /etc/nova/nova.conf placement user_domain_name Default
crudini --set /etc/nova/nova.conf placement auth_url http://controller:5000/v3
crudini --set /etc/nova/nova.conf placement username placement
crudini --set /etc/nova/nova.conf placement password openstack
crudini --set /etc/nova/nova.conf cinder os_region_name RegionOne
#crudini --del /etc/nova/nova.conf api_database connection
#crudini --del /etc/nova/nova.conf database connection
crudini --set /etc/nova/nova-compute.conf libvirt virt_type qemu
service nova-compute restart
set +x
echo "---> Nova installed on compute1"
