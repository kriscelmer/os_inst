#! /bin/bash

echo "---> Installing Swift storage node part"
set -e
set -x
DEBIAN_FRONTEND=noninteractive apt-get install -y xfsprogs > /dev/null
mkfs.xfs /dev/sdb3
mkfs.xfs /dev/sdb4
mkdir -p /srv/node/sdb3
mkdir -p /srv/node/sdb4
uuid3=$(blkid -o value -s UUID /dev/sdb3)
uuid4=$(blkid -o value -s UUID /dev/sdb4)
echo "UUID=$uuid3 /srv/node/sdb3 xfs noatime 0 2" >> /etc/fstab
echo "UUID=$uuid4 /srv/node/sdb4 xfs noatime 0 2" >> /etc/fstab
mount /srv/node/sdb3
mount /srv/node/sdb4

DEBIAN_FRONTEND=noninteractive apt-get install -y swift-account swift-container swift-object > /dev/null
curl -o /etc/swift/account-server.conf https://opendev.org/openstack/swift/raw/branch/master/etc/account-server.conf-sample
curl -o /etc/swift/container-server.conf https://opendev.org/openstack/swift/raw/branch/master/etc/container-server.conf-sample
curl -o /etc/swift/object-server.conf https://opendev.org/openstack/swift/raw/branch/master/etc/object-server.conf-sample
curl -o /etc/swift/internal-client.conf https://opendev.org/openstack/swift/raw/branch/master/etc/internal-client.conf-sample
crudini --set /etc/swift/account-server.conf DEFAULT bind_ip 10.0.0.11
crudini --set /etc/swift/account-server.conf DEFAULT bind_port 6202
crudini --set /etc/swift/account-server.conf DEFAULT user swift
crudini --set /etc/swift/account-server.conf DEFAULT swift_dir /etc/swift
crudini --set /etc/swift/account-server.conf DEFAULT devices /srv/node
crudini --set /etc/swift/account-server.conf DEFAULT mount_check True
crudini --set /etc/swift/account-server.conf pipeline:main pipeline "healthcheck recon account-server"
crudini --set /etc/swift/account-server.conf filter:recon use "egg:swift#recon"
crudini --set /etc/swift/account-server.conf filter:recon recon_cache_path /var/cache/swift
crudini --set /etc/swift/container-server.conf DEFAULT bind_ip 10.0.0.11
crudini --set /etc/swift/container-server.conf DEFAULT bind_port 6201
crudini --set /etc/swift/container-server.conf DEFAULT user swift
crudini --set /etc/swift/container-server.conf DEFAULT swift_dir /etc/swift
crudini --set /etc/swift/container-server.conf DEFAULT devices /srv/node
crudini --set /etc/swift/container-server.conf DEFAULT mount_check True
crudini --set /etc/swift/container-server.conf pipeline:main pipeline "healthcheck recon container-server"
crudini --set /etc/swift/container-server.conf filter:recon use "egg:swift#recon"
crudini --set /etc/swift/container-server.conf filter:recon recon_cache_path /var/cache/swift
crudini --set /etc/swift/object-server.conf DEFAULT bind_ip 10.0.0.11
crudini --set /etc/swift/object-server.conf DEFAULT bind_port 6200
crudini --set /etc/swift/object-server.conf DEFAULT user swift
crudini --set /etc/swift/object-server.conf DEFAULT swift_dir /etc/swift
crudini --set /etc/swift/object-server.conf DEFAULT devices /srv/node
crudini --set /etc/swift/object-server.conf DEFAULT mount_check True
crudini --set /etc/swift/object-server.conf pipeline:main pipeline "healthcheck recon object-server"
crudini --set /etc/swift/object-server.conf filter:recon use "egg:swift#recon"
crudini --set /etc/swift/object-server.conf filter:recon recon_cache_path /var/cache/swift
crudini --set /etc/swift/object-server.conf filter:recon recon_lock_path /var/lock
chown -R swift:swift /srv/node
mkdir -p /var/cache/swift
chown -R root:swift /var/cache/swift
chmod -R 775 /var/cache/swift

service swift-proxy stop
swift-init all start
