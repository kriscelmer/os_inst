#! /bin/bash

set -x
set -e
echo "---> Installing OpenStack Client"
sudo apt install -y python3-openstackclient > /dev/null
cat << EOF > admin-openrc
export OS_USERNAME=admin
export OS_PASSWORD=openstack
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
EOF
ssh openstack@controller sudo bash os_inst/wallaby/controller/install.sh
ssh openstack@storage1 sudo bash os_inst/wallaby/storage1/install.sh
ssh openstack@storage2 sudo bash os_inst/wallaby/storage2/install.sh
ssh openstack@compute1 sudo bash os_inst/wallaby/compute1/install.sh
ssh openstack@compute2 sudo bash os_inst/wallaby/compute2/install.sh
ssh openstack@controller sudo bash os_inst/wallaby/controller/register-computes.sh
