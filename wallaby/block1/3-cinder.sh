#! /bin/bash

echo "---> cinder on block1"
set -e
set -x
apt install -y lvm2 thin-provisioning-tools tgt crudini > /dev/null
pvcreate /dev/sdb
pvcreate /dev/sdc
vgcreate cinder-volumes /dev/sdb
vgcreate cinder-volumes-2 /dev/sdc
sed -i '/^devices/a \ \ \ \ \ \ \ \ filter = \[ \"a\/sdb\/"\, \"a\/sdc\/"\, \"r\/\.\*\/\"\]' /etc/lvm/lvm.conf
apt install -y cinder-volume > /dev/null
crudini --set /etc/cinder/cinder.conf database connection 'mysql+pymysql://cinder:openstack@controller/cinder'
crudini --set /etc/cinder/cinder.conf DEFAULT transport_url 'rabbit://openstack:openstack@controller:5672/'
crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
crudini --set /etc/cinder/cinder.conf DEFAULT my_ip 10.0.0.41
crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends lvm
crudini --set /etc/cinder/cinder.conf DEFAULT glance_api_servers http://controller:9292
crudini --set /etc/cinder/cinder.conf DEFAULT lock_path /var/lib/cinder/tmp
crudini --set /etc/cinder/cinder.conf DEFAULT default_volume_type lvm
crudini --set /etc/cinder/cinder.conf DEFAULT use_chap_auth False
crudini --set /etc/cinder/cinder.conf keystone_authtoken www_authenticate_uri http://controller:5000/v3
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://controller:5000/v3
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
crudini --set /etc/cinder/cinder.conf lvm volume_backend_name LVM
crudini --set /etc/cinder/cinder.conf lvm-2 volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver
crudini --set /etc/cinder/cinder.conf lvm-2 volume_group cinder-volumes-2
crudini --set /etc/cinder/cinder.conf lvm-2 target_protocol iscsi
crudini --set /etc/cinder/cinder.conf lvm-2 target_helper tgtadm
crudini --set /etc/cinder/cinder.conf lvm-2 volume_backend_name LVM-2
echo "include /var/lib/cinder/volumes/*" > /etc/tgt/conf.d/cinder.conf
service tgt restart
systemctl enable cinder-volume
service cinder-volume restart
set +x
echo "---> cinder on block1 installed"
