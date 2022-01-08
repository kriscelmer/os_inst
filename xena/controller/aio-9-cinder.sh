#! /bin/bash

echo "---> Installing Cinder storage node part"
set -e
set -x
DEBIAN_FRONTEND=noninteractive apt-get install -y lvm2 thin-provisioning-tools tgt nvme-cli > /dev/null
pvcreate /dev/sdb1
vgcreate cinder-volumes1 /dev/sdb1
pvcreate /dev/sdb2
vgcreate cinder-volumes2 /dev/sdb2
sed -i '/^devices/a \ \ \ \ \ \ \ \ filter = \[ \"a\/sdb\/"\, \"r\/\.\*\/\"\]' /etc/lvm/lvm.conf
DEBIAN_FRONTEND=noninteractive apt-get install -y cinder-volume > /dev/null
crudini --set /etc/cinder/cinder.conf DEFAULT enabled_backends lvm1,lvm2
crudini --set /etc/cinder/cinder.conf DEFAULT glance_api_servers http://controller:9292
crudini --set /etc/cinder/cinder.conf DEFAULT lock_path /var/lib/cinder/tmp
#crudini --set /etc/cinder/cinder.conf DEFAULT default_volume_type lvm
crudini --set /etc/cinder/cinder.conf lvm1 volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver
crudini --set /etc/cinder/cinder.conf lvm1 volume_group cinder-volumes1
crudini --set /etc/cinder/cinder.conf lvm1 target_protocol iscsi
crudini --set /etc/cinder/cinder.conf lvm1 target_helper tgtadm
crudini --set /etc/cinder/cinder.conf lvm1 volume_backend_name LVM-1
crudini --set /etc/cinder/cinder.conf lvm2 volume_driver cinder.volume.drivers.lvm.LVMVolumeDriver
crudini --set /etc/cinder/cinder.conf lvm2 volume_group cinder-volumes2
crudini --set /etc/cinder/cinder.conf lvm2 target_protocol iscsi
crudini --set /etc/cinder/cinder.conf lvm2 target_helper tgtadm
crudini --set /etc/cinder/cinder.conf lvm2 volume_backend_name LVM-2
echo "include /var/lib/cinder/volumes/*" > /etc/tgt/conf.d/cinder.conf
service tgt restart
systemctl enable cinder-volume
service cinder-volume restart
DEBIAN_FRONTEND=noninteractive apt-get install -y cinder-backup > /dev/null
crudini --set /etc/cinder/cinder.conf DEFAULT backup_driver cinder.backup.drivers.swift.SwiftBackupDriver
#crudini --set /etc/cinder/cinder.conf DEFAULT backup_swift_url http://controller:8080/v1/AUTH_
#crudini --set /etc/cinder/cinder.conf DEFAULT backup_swift_auth per_user
#crudini --set /etc/cinder/cinder.conf DEFAULT backup_swift_auth_url http://controller:5000/v3
systemctl enable cinder-backup
service cinder-backup restart
set +x
echo "---> cinder on storage1 installed"
