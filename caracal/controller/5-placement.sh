#! /bin/bash

echo "---> Installing placement"
set -e
set -x
cat << EOF | mysql
CREATE DATABASE placement;
GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'localhost' IDENTIFIED BY 'openstack';
GRANT ALL PRIVILEGES ON placement.* TO 'placement'@'%' IDENTIFIED BY 'openstack';
EOF
. admin-openrc
openstack user create --domain default --password openstack placement
openstack role add --project service --user placement admin
openstack service create --name placement --description "Placement API" placement
openstack endpoint create --region RegionOne placement public http://10.0.0.11:8778
openstack endpoint create --region RegionOne placement internal http://10.0.0.11:8778
openstack endpoint create --region RegionOne placement admin http://10.0.0.11:8778
DEBIAN_FRONTEND=noninteractive apt-get install -y placement-api > /dev/null
crudini --set /etc/placement/placement.conf placement_database connection 'mysql+pymysql://placement:openstack@controller/placement'
crudini --set /etc/placement/placement.conf api auth_strategy keystone
crudini --set /etc/placement/placement.conf keystone_authtoken auth_url http://controller:5000/v3
crudini --set /etc/placement/placement.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/placement/placement.conf keystone_authtoken auth_type password
crudini --set /etc/placement/placement.conf keystone_authtoken project_domain_name Default
crudini --set /etc/placement/placement.conf keystone_authtoken user_domain_name Default
crudini --set /etc/placement/placement.conf keystone_authtoken project_name service
crudini --set /etc/placement/placement.conf keystone_authtoken username placement
crudini --set /etc/placement/placement.conf keystone_authtoken password openstack
su -s /bin/sh -c "placement-manage db sync" placement
service apache2 restart
openstack --os-placement-api-version 1.2 resource class list --sort-column name
openstack --os-placement-api-version 1.6 trait list --sort-column name
set +x
echo "---> Placement installed"
