#! /bin/bash

echo "---> cinder on storage1"
set -e
set -x
DEBIAN_FRONTEND=noninteractive apt-get install -y lvm2 thin-provisioning-tools tgt nvme-cli > /dev/null
pvcreate /dev/sdb1
vgcreate cinder-volumes /dev/sdb1
sed -i '/^devices/a \ \ \ \ \ \ \ \ filter = \[ \"a\/sdb\/"\, \"r\/\.\*\/\"\]' /etc/lvm/lvm.conf
DEBIAN_FRONTEND=noninteractive apt-get install -y cinder-volume > /dev/null
crudini --set /etc/cinder/cinder.conf database connection 'mysql+pymysql://cinder:openstack@controller/cinder'
crudini --set /etc/cinder/cinder.conf DEFAULT transport_url 'rabbit://openstack:openstack@controller:5672/'
crudini --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
crudini --set /etc/cinder/cinder.conf DEFAULT my_ip 10.0.0.41
crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends lvm1
crudini --set /etc/cinder/cinder.conf DEFAULT glance_api_servers http://controller:9292
crudini --set /etc/cinder/cinder.conf DEFAULT lock_path /var/lib/cinder/tmp
#crudini --set /etc/cinder/cinder.conf DEFAULT default_volume_type lvm
crudini --set /etc/cinder/cinder.conf keystone_authtoken www_authenticate_uri http://controller:5000/v3
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://controller:5000/v3
crudini --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/cinder/cinder.conf keystone_authtoken auth_type password
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name default
crudini --set /etc/cinder/cinder.conf keystone_authtoken project_name service
crudini --set /etc/cinder/cinder.conf keystone_authtoken username cinder
crudini --set /etc/cinder/cinder.conf keystone_authtoken password openstack
crudini --set /etc/cinder/cinder.conf lvm1 volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver
crudini --set /etc/cinder/cinder.conf lvm1 volume_group cinder-volumes
crudini --set /etc/cinder/cinder.conf lvm1 target_protocol iscsi
crudini --set /etc/cinder/cinder.conf lvm1 target_helper tgtadm
crudini --set /etc/cinder/cinder.conf lvm1 volume_backend_name LVM-1
echo "include /var/lib/cinder/volumes/*" > /etc/tgt/conf.d/cinder.conf
service tgt restart
systemctl enable cinder-volume
service cinder-volume restart
DEBIAN_FRONTEND=noninteractive apt-get install -y cinder-backup > /dev/null
crudini --set /etc/cinder/cinder.conf DEFAULT backup_driver cinder.backup.drivers.swift.SwiftBackupDriver
#crudini --set /etc/cinder/cinder.conf DEFAULT backup_swift_url http://controller:8080/v1/AUTH_
#crudini --set /etc/cinder/cinder.conf DEFAULT backup_swift_auth per_user
#crudini --set /etc/cinder/cinder.conf DEFAULT backup_swift_auth_url http://controller:5000/v3
service cinder-backup restart
set +x
echo "---> cinder on storage1 installed"
