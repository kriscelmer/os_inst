#! /bin/bash

echo "---> Installing cinder"
set -e
set -x
cat << EOF | mysql
CREATE DATABASE cinder;
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY 'openstack';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY 'openstack';
EOF

. admin-openrc
openstack user create --domain default --password openstack cinder
openstack role add --project service --user cinder admin
openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2
openstack service create --name cinderv3 --description "OpenStack Block Storage" volumev3
openstack endpoint create --region RegionOne volumev2 public http://controller:8776/v2
openstack endpoint create --region RegionOne volumev2 internal http://controller:8776/v2
openstack endpoint create --region RegionOne volumev2 admin http://controller:8776/v2
openstack endpoint create --region RegionOne volumev3 public http://controller:8776/v3
openstack endpoint create --region RegionOne volumev3 internal http://controller:8776/v3
openstack endpoint create --region RegionOne volumev3 admin http://controller:8776/v3
apt install -y cinder-api cinder-scheduler > /dev/null
crudini --set /etc/cinder/cinder.conf database connection 'mysql+pymysql://cinder:openstack@controller/cinder'
crudini --set /etc/cinder/cinder.conf DEFAULT transport_url 'rabbit://openstack:openstack@controller:5672/'
crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
crudini --set /etc/cinder/cinder.conf DEFAULT my_ip 10.0.0.11
crudini --set /etc/cinder/cinder.conf keystone_authtoken www_authenticate_uri http://controller:5000/v3
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://controller:5000/v3
crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type password
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name service
crudini --set /etc/cinder/cinder.conf keystone_authtoken username cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken password openstack
crudini --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp
su -s /bin/sh -c "cinder-manage db sync" cinder
crudini --set /etc/nova/nova.conf os_region_name RegionOne
service nova-api restart
service cinder-scheduler restart
systemctl enable cinder-scheduler
service apache2 restart
set +x
echo "---> Cinder on the controller is installed"
