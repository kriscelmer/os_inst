#! /bin/bash

echo "---> Configuring Networking for OpenStack"
set -e
set -x
DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null
DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade > /dev/null
echo "openstack ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
DEBIAN_FRONTEND=noninteractive apt-get -y install ifupdown > /dev/null
cp os_inst/wallaby/compute1/interfaces /etc/network/interfaces
ifdown --force enp0s3 enp0s8 enp0s9 lo && ifup -a
systemctl unmask networking
systemctl enable networking
systemctl restart networking
systemctl stop systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
systemctl disable systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
systemctl mask systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
DEBIAN_FRONTEND=noninteractive apt-get -y --assume-yes purge nplan netplan.io > /dev/null
echo "DNS=8.8.8.8 8.8.4.4" >> /etc/systemd/resolved.conf
systemctl restart systemd-resolved
cat << EOF > /etc/hosts
127.0.0.1 localhost
10.0.0.2 console
10.0.0.11 controller
10.0.0.31 compute1
10.0.0.32 compute2
10.0.0.33 compute3
10.0.0.41 block1
10.0.0.42 block2
10.0.0.51 object1
10.0.0.52 object2
EOF
set +x
echo "---> Networking configured"
