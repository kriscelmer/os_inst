#! /bin/bash

echo "---> cinder on block1"
set -e
set -x
add-apt-repository -y cloud-archive:wallaby
apt install -y lvm2 thin-provisioning-tools tgt crudini > /dev/null
pvcreate /dev/sdb
vgcreate cinder-volumes /dev/sdb
sed -i '/^devices/a \ \ \ \ \ \ \ \ filter = \[ \"a\/sdb\/"\, \"r\/\.\*\/\"\]' /etc/lvm/lvm.conf
apt install -y cinder-volume > /dev/null
crudini --set /etc/cinder/cinder.conf database connection 'mysql+pymysql://cinder:openstack@controller/cinder'
crudini --set /etc/cinder/cinder.conf DEFAULT transport_url 'rabbit://openstack:openstack@controller'
crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
crudini --set /etc/cinder/cinder.conf DEFAULT my_ip 10.0.0.51
crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends lvm
crudini --set /etc/cinder/cinder.conf DEFAULT glance_api_servers http://controller:9292
crudini --set /etc/cinder/cinder.conf DEFAULT lock_path /var/lib/cinder/tmp
crudini --set /etc/cinder/cinder.conf keystone_authtoken www_authenticate_uri http://controller:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://controller:5000
crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type password
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name service
crudini --set /etc/cinder/cinder.conf keystone_authtoken username cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken password openstack
crudini --set /etc/cinder/cinder.conf lvm volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver
crudini --set /etc/cinder/cinder.conf lvm volume_group cinder-volumes
crudini --set /etc/cinder/cinder.conf lvm target_protocol iscsi
crudini --set /etc/cinder/cinder.conf lvm target_helper tgtadm
service tgt restart
service cinder-volume restart
set +x
echo "---> cinder on block1 installed"
