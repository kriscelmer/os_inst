#! /bin/bash

echo "---> Installing glance"
set -e
set -x
cat << EOF | mysql
CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'openstack';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'openstack';
EOF
. admin-openrc
openstack user create --domain default --password openstack glance
openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image" image
openstack endpoint create --region RegionOne image public http://controller:9292
openstack endpoint create --region RegionOne image internal http://controller:9292
openstack endpoint create --region RegionOne image admin http://controller:9292
apt install -y glance > /dev/null
crudini --set  /etc/glance/glance-api.conf database 'mysql+pymysql://glance:openstack@controller/glance'
crudini --set  /etc/glance/glance-api.conf keystone_authtoken www_authenticate_uri 'http://controller:5000'
crudini --set  /etc/glance/glance-api.conf keystone_authtoken auth_url 'http://controller:5000'
crudini --set  /etc/glance/glance-api.conf keystone_authtoken memcached_servers 'controller:11211'
crudini --set  /etc/glance/glance-api.conf keystone_authtoken auth_type password
crudini --set  /etc/glance/glance-api.conf keystone_authtoken project_domain_name Default
crudini --set  /etc/glance/glance-api.conf keystone_authtoken user_domain_name Default
crudini --set  /etc/glance/glance-api.conf keystone_authtoken project_name service
crudini --set  /etc/glance/glance-api.conf keystone_authtoken username glance
crudini --set  /etc/glance/glance-api.conf keystone_authtoken password openstack
crudini --set  /etc/glance/glance-api.conf paste_deploy flavor keystone
crudini --set  /etc/glance/glance-api.conf glance_store stores 'file,http'
crudini --set  /etc/glance/glance-api.conf glance_store default_store file
crudini --set  /etc/glance/glance-api.conf glance_store filesystem_store_datadir /var/lib/glance/images/
su -s /bin/sh -c "glance-manage db_sync" glance
service glance-api restart
wget http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img
glance image-create --name "cirros" --file cirros-0.4.0-x86_64-disk.img --disk-format qcow2 --container-format bare --visibility=public
openstack image list
set +x
echo "---> Glance installed and configured"
