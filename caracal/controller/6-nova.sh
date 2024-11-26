#! /bin/bash

echo "---> Installing nova on controller"
set -e
set -x
cat << EOF | mysql
CREATE DATABASE nova_api;
CREATE DATABASE nova;
CREATE DATABASE nova_cell0;
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY 'openstack';
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'openstack';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'openstack';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'openstack';
GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY 'openstack';
GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY 'openstack';
EOF
. admin-openrc
openstack user create --domain default --password openstack nova
openstack role add --project service --user nova admin
openstack service create --name nova --description "OpenStack Compute" compute
openstack endpoint create --region RegionOne compute public http://10.0.0.11:8774/v2.1
openstack endpoint create --region RegionOne compute internal http://10.0.0.11:8774/v2.1
openstack endpoint create --region RegionOne compute admin http://10.0.0.11:8774/v2.1
DEBIAN_FRONTEND=noninteractive apt-get install -y nova-api nova-conductor nova-novncproxy nova-scheduler > /dev/null
crudini --set /etc/nova/nova.conf api_database connection 'mysql+pymysql://nova:openstack@controller/nova_api'
crudini --set /etc/nova/nova.conf database connection 'mysql+pymysql://nova:openstack@controller/nova'
crudini --set /etc/nova/nova.conf DEFAULT transport_url 'rabbit://openstack:openstack@controller:5672/'
crudini --del /etc/nova/nova.conf DEFAULT log_dir
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
crudini --set /etc/nova/nova.conf service_user auth_url https://controller/identity
crudini --set /etc/nova/nova.conf service_user auth_strategy keystone
crudini --set /etc/nova/nova.conf service_user auth_type password
crudini --set /etc/nova/nova.conf service_user project_domain_name Default
crudini --set /etc/nova/nova.conf service_user project_name service
crudini --set /etc/nova/nova.conf service_user user_domain_name Default
crudini --set /etc/nova/nova.conf service_user username nova
crudini --set /etc/nova/nova.conf service_user password openstack
crudini --set /etc/nova/nova.conf DEFAULT my_ip 10.0.0.11
crudini --set /etc/nova/nova.conf vnc enabled true
crudini --set /etc/nova/nova.conf vnc server_listen '$my_ip'
crudini --set /etc/nova/nova.conf vnc server_proxyclient_address '$my_ip'
crudini --set /etc/nova/nova.conf glance api_servers http://controller:9292
crudini --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
crudini --set /etc/nova/nova.conf placement region_name RegionOne
crudini --set /etc/nova/nova.conf placement project_domain_name Default
crudini --set /etc/nova/nova.conf placement project_name service
crudini --set /etc/nova/nova.conf placement auth_type password
crudini --set /etc/nova/nova.conf placement user_domain_name Default
crudini --set /etc/nova/nova.conf placement auth_url http://controller:5000/v3
crudini --set /etc/nova/nova.conf placement username placement
crudini --set /etc/nova/nova.conf placement password openstack
su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
su -s /bin/sh -c "nova-manage db sync" nova
su -s /bin/sh -c "nova-manage cell_v2 list_cells" nova
service nova-api restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart
sleep 15
openstack compute service list
openstack catalog list
openstack image list
nova-status upgrade check
set +x
echo "---> Nova on controller installed"
