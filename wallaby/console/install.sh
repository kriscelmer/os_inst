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
ssh openstack@controller sudo bash os_inst/wallaby/controller/install.sh
ssh openstack@storage1 sudo bash os_inst/wallaby/storage1/install.sh
ssh openstack@storage2 sudo bash os_inst/wallaby/storage2/install.sh
ssh openstack@compute1 sudo bash os_inst/wallaby/compute1/install.sh
ssh openstack@compute2 sudo bash os_inst/wallaby/compute2/install.sh
ssh openstack@controller sudo bash os_inst/wallaby/controller/register-computes.sh

# Prepare 'demo' account to course exercises
. demo-openrc
openstack keypair create --public-key /home/openstack/.ssh/id_rsa.pub demo-keypair
openstack security group create demo-icmp-sg --description "Allow ICMP packets from any address"
openstack security group rule create --remote-group demo-icmp-sg --ingress --ethertype IPv4 demo-icmp-sg
openstack security group rule create --remote-ip 0.0.0.0/0 --protocol icmp --ingress --ethertype IPv4 demo-icmp-sg

# Copy example files to /home/openstack/examples
mkdir -p /home/openstack/examples
cp -r os_inst/wallaby/console/examples/* /home/openstack/examples
chown -R openstack /home/openstack/examples
