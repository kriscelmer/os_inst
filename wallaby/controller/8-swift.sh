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
apt-get install -y swift swift-proxy python-swiftclient > /dev/null
mkdir /etc/swift
curl -o /etc/swift/proxy-server.conf https://opendev.org/openstack/swift/raw/branch/stable/wallaby/etc/proxy-server.conf-sample
crudini --set /etc/swift/proxy-server.conf DEFAULT bind_port 8080
crudini --set /etc/swift/proxy-server.conf DEFAULT user swift
crudini --set /etc/swift/proxy-server.conf DEFAULT swift_dir /etc/swift
crudini --set /etc/swift/proxy-server.conf pipeline:main pipeline 'catch_errors gatekeeper healthcheck proxy-logging cache container_sync bulk ratelimit authtoken keystoneauth container-quotas account-quotas slo dlo versioned_writes proxy-logging proxy-server'
