#! /bin/bash

set -e
echo "---> Finding and registering compute nodes"
set -x
. admin-openrc
openstack compute service list --service nova-compute
su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova
echo "---> Done"
