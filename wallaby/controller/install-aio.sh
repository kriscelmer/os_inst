#! /bin/bash

set -x
set -e

DEBIAN_FRONTEND=noninteractive apt-get update -y > /dev/null
for script in os_inst/wallaby/controller/[2-9]-*
do
  bash $script
done
bash os_inst/wallaby/controller/10-heat.sh
bash os_inst/wallaby/controller/19-horizon.sh
for script in os_inst/wallaby/controller/aio-[2-9]-*
do
  bash $script
done
bash os_inst/wallaby/controller/configure-openstack.sh

# Prepare 'demo' account to course exercises
cat << EOF > demo-openrc
export OS_USERNAME=demo
export OS_PASSWORD=openstack
export OS_PROJECT_NAME=demo
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://controller:5000/v3
export OS_IDENTITY_API_VERSION=3
EOF
. demo-openrc
openstack keypair create --public-key /home/openstack/.ssh/id_rsa.pub demo-keypair
openstack security group create demo-icmp-sg --description "Allow ICMP packets from any address"
openstack security group rule create --remote-group demo-icmp-sg --ingress --ethertype IPv4 demo-icmp-sg
openstack security group rule create --remote-ip 0.0.0.0/0 --protocol icmp --ingress --ethertype IPv4 demo-icmp-sg

# Copy example files to /home/openstack/examples
mkdir -p /home/openstack/examples
cp -r os_inst/xena/controller/examples/* /home/openstack/examples
chown -R openstack /home/openstack/examples

# Copy clouds.yaml for /home/openstack/.config/openstack
mkdir -p /home/openstack/.config/openstack
cp os_inst/xena/controller/clouds.yaml /home/openstack/.config/openstack
chown openstack /home/openstack/.config
chown -R /home/openstack/.config/openstack
