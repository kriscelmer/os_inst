#! /bin/bash

set -x
set -e
echo "---> Installing OpenStack Client"
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3-openstackclient python3-heatclient > /dev/null
cat << EOF > admin-openrc
export OS_USERNAME=admin
export OS_PASSWORD=openstack
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
EOF
cat << EOF > demo-openrc
export OS_USERNAME=demo
export OS_PASSWORD=openstack
export OS_PROJECT_NAME=demo
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
EOF
