#! /bin/bash

echo "---> Installing Nova compute node part"
set -e
set -x
DEBIAN_FRONTEND=noninteractive apt-get install -y nova-compute > /dev/null
crudini --set /etc/nova/nova.conf cinder os_region_name RegionOne
crudini --set /etc/nova/nova.conf vnc novncproxy_base_url http://10.0.0.11:6080/vnc_auto.html
crudini --set /etc/nova/nova-compute.conf libvirt virt_type qemu
service nova-compute restart
set +x
echo "---> Nova installed on compute1"
