#! /bin/bash
echo "---> Installing Swift"
set -e
set -x
. admin-openrc
openstack user create --domain default --password openstack swift
openstack role add --project service --user swift admin
openstack service create --name swift --description "OpenStack Object Storage" object-store
openstack endpoint create --region RegionOne object-store public 'http://controller:8080/v1/AUTH_%(tenant_id)s'
openstack endpoint create --region RegionOne object-store internal 'http://controller:8080/v1/AUTH_%(tenant_id)s'
openstack endpoint create --region RegionOne object-store admin 'http://controller:8080/v1'
DEBIAN_FRONTEND=noninteractive apt-get install -y swift swift-proxy python3-swiftclient  python3-keystoneclient python3-keystonemiddleware > /dev/null
curl -o /etc/swift/proxy-server.conf https://opendev.org/openstack/swift/raw/branch/stable/wallaby/etc/proxy-server.conf-sample
crudini --set /etc/swift/proxy-server.conf DEFAULT bind_port 8080
crudini --set /etc/swift/proxy-server.conf DEFAULT user swift
crudini --set /etc/swift/proxy-server.conf DEFAULT swift_dir /etc/swift
crudini --set /etc/swift/proxy-server.conf pipeline:main pipeline 'catch_errors gatekeeper healthcheck proxy-logging cache container_sync bulk ratelimit authtoken keystoneauth container-quotas account-quotas slo dlo versioned_writes proxy-logging proxy-server'
crudini --set /etc/swift/proxy-server.conf app:proxy-server use 'egg:swift#proxy'
crudini --set /etc/swift/proxy-server.conf app:proxy-server account_autocreate True
crudini --set /etc/swift/proxy-server.conf filter:keystoneauth use 'egg:swift#keystoneauth'
crudini --set /etc/swift/proxy-server.conf filter:keystoneauth operator_roles 'admin,member'
crudini --set /etc/swift/proxy-server.conf filter:authtoken paste.filter_factory keystonemiddleware.auth_token:filter_factory
crudini --set /etc/swift/proxy-server.conf filter:authtoken auth_uri http://controller:5000/v3
crudini --set /etc/swift/proxy-server.conf filter:authtoken auth_url http://controller:5000/v3
crudini --set /etc/swift/proxy-server.conf filter:authtoken memcached_servers controller:11211
crudini --set /etc/swift/proxy-server.conf filter:authtoken auth_plugin password
crudini --set /etc/swift/proxy-server.conf filter:authtoken project_domain_name default
crudini --set /etc/swift/proxy-server.conf filter:authtoken user_domain_name default
crudini --set /etc/swift/proxy-server.conf filter:authtoken project_name service
crudini --set /etc/swift/proxy-server.conf filter:authtoken username swift
crudini --set /etc/swift/proxy-server.conf filter:authtoken password openstack
crudini --set /etc/swift/proxy-server.conf filter:authtoken delay_auth_decision True
crudini --set /etc/swift/proxy-server.conf filter:authtoken cache swift.cache
crudini --set /etc/swift/proxy-server.conf filter:authtoken include_service_catalog False
crudini --set /etc/swift/proxy-server.conf filter:cache use 'egg:swift#memcache'
crudini --set /etc/swift/proxy-server.conf filter:cache memcache_servers controller:11211
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
service memcached restart
service swift-proxy restart

set +x
echo "---> Swift installed on controller"
