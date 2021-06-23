#! /bin/bash

echo "---> Installing Swift on storage2 node"
set -e
set -x
DEBIAN_FRONTEND=noninteractive apt-get install -y xfsprogs rsync > /dev/null
mkfs.xfs /dev/sdb
mkfs.xfs /dev/sdc
mkdir -p /srv/node/sdb2
mkdir -p /srv/node/sdb3
cat << EOF >> /etc/fstab
/dev/sdb2 /srv/node/sdb2 xfs noatime,nodiratime,nobarrier,logbufs=8 0 2
/dev/sdb3 /srv/node/sdb3 xfs noatime,nodiratime,nobarrier,logbufs=8 0 2
EOF
mount /srv/node/sdb2
mount /srv/node/sdb3
cat << EOF > /etc/rsyncd.conf
uid = swift
gid = swift
log file = /var/log/rsyncd.log
pid file = /var/run/rsyncd.pid
address = 10.0.0.42

[account]
max connections = 2
path = /srv/node/
read only = False
lock file = /var/lock/account.lock

[container]
max connections = 2
path = /srv/node/
read only = False
lock file = /var/lock/container.lock

[object]
max connections = 2
path = /srv/node/
read only = False
lock file = /var/lock/object.lock
EOF
sed -i '/^RSYNC_ENABLE/s/false/true/' /etc/default/rsync
service rsync start

DEBIAN_FRONTEND=noninteractive apt-get install -y swift swift-account swift-container swift-object > /dev/null
curl -o /etc/swift/account-server.conf https://opendev.org/openstack/swift/raw/branch/master/etc/account-server.conf-sample
curl -o /etc/swift/container-server.conf https://opendev.org/openstack/swift/raw/branch/master/etc/container-server.conf-sample
curl -o /etc/swift/object-server.conf https://opendev.org/openstack/swift/raw/branch/master/etc/object-server.conf-sample
crudini --set /etc/swift/account-server.conf DEFAULT bind_ip 10.0.0.42
crudini --set /etc/swift/account-server.conf DEFAULT bind_port 6202
crudini --set /etc/swift/account-server.conf DEFAULT user swift
crudini --set /etc/swift/account-server.conf DEFAULT swift_dir /etc/swift
crudini --set /etc/swift/account-server.conf DEFAULT devices /srv/node
crudini --set /etc/swift/account-server.conf DEFAULT mount_check True
crudini --set /etc/swift/account-server.conf pipeline:main pipeline "healthcheck recon account-server"
crudini --set /etc/swift/account-server.conf filter:recon use "egg:swift#recon"
crudini --set /etc/swift/account-server.conf filter:recon recon_cache_path /var/cache/swift
crudini --set /etc/swift/container-server.conf DEFAULT bind_ip 10.0.0.42
crudini --set /etc/swift/container-server.conf DEFAULT bind_port 6201
crudini --set /etc/swift/container-server.conf DEFAULT user swift
crudini --set /etc/swift/container-server.conf DEFAULT swift_dir /etc/swift
crudini --set /etc/swift/container-server.conf DEFAULT devices /srv/node
crudini --set /etc/swift/container-server.conf DEFAULT mount_check True
crudini --set /etc/swift/container-server.conf pipeline:main pipeline "healthcheck recon container-server"
crudini --set /etc/swift/container-server.conf filter:recon use "egg:swift#recon"
crudini --set /etc/swift/container-server.conf filter:recon recon_cache_path /var/cache/swift
crudini --set /etc/swift/object-server.conf DEFAULT bind_ip 10.0.0.42
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
cd /etc/swift
swift-ring-builder account.builder create 10 3 1
swift-ring-builder account.builder add --region 1 --zone 1 --ip 10.0.0.41 --port 6202 --device sdb2 --weight 100
swift-ring-builder account.builder add --region 1 --zone 1 --ip 10.0.0.41 --port 6202 --device sdb3 --weight 100
swift-ring-builder account.builder add --region 1 --zone 1 --ip 10.0.0.42 --port 6202 --device sdb2 --weight 100
swift-ring-builder account.builder add --region 1 --zone 1 --ip 10.0.0.42 --port 6202 --device sdb3 --weight 100
swift-ring-builder account.builder rebalance
swift-ring-builder container.builder create 10 3 1
swift-ring-builder container.builder add --region 1 --zone 1 --ip 10.0.0.41 --port 6201 --device sdb2 --weight 100
swift-ring-builder container.builder add --region 1 --zone 1 --ip 10.0.0.41 --port 6201 --device sdb3 --weight 100
swift-ring-builder container.builder add --region 1 --zone 1 --ip 10.0.0.42 --port 6201 --device sdb2 --weight 100
swift-ring-builder container.builder add --region 1 --zone 1 --ip 10.0.0.42 --port 6201 --device sdb3 --weight 100
swift-ring-builder container.builder rebalance
swift-ring-builder object.builder create 10 3 1
swift-ring-builder object.builder add --region 1 --zone 1 --ip 10.0.0.41 --port 6200 --device sdb2 --weight 100
swift-ring-builder object.builder add --region 1 --zone 1 --ip 10.0.0.41 --port 6200 --device sdb3 --weight 100
swift-ring-builder object.builder add --region 1 --zone 1 --ip 10.0.0.42 --port 6200 --device sdb2 --weight 100
swift-ring-builder object.builder add --region 1 --zone 1 --ip 10.0.0.42 --port 6200 --device sdb3 --weight 100
swift-ring-builder object.builder rebalance
curl -o /etc/swift/swift.conf https://opendev.org/openstack/swift/raw/branch/stable/wallaby/etc/swift.conf-sample
crudini --set /etc/swift/swift.conf swift-hash swift_hash_path_suffix open
crudini --set /etc/swift/swift.conf swift-hash swift_hash_path_prefix stack
crudini --set /etc/swift/swift.conf storage-policy:0 name Policy-0
crudini --set /etc/swift/swift.conf storage-policy:0 default yes
chown -R root:swift /etc/swift

swift-init all start
