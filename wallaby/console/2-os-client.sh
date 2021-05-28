#! /bin/bash

set -e
set -x
echo ---> Installing OpenStack Client"
apt install -y python3-openstackclient
cat << EOF > admin-openrc
export OS_USERNAME=admin
export OS_PASSWORD=openstack
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
EOF
