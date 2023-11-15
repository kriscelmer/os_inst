#! /bin/bash

echo "---> Configuring Networking for OpenStack"
set -e
set -x
DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null
DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade > /dev/null
echo "openstack ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
DEBIAN_FRONTEND=noninteractive apt-get -y install ifupdown > /dev/null
cp os_inst/antelope/storage1/interfaces /etc/network/interfaces
ifdown --force enp0s3 enp0s8 lo && ifup -a
systemctl unmask networking
systemctl enable networking
systemctl restart networking
systemctl stop systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
systemctl disable systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
systemctl mask systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
DEBIAN_FRONTEND=noninteractive apt-get -y --assume-yes purge nplan netplan.io > /dev/null
echo "DNS=8.8.8.8 8.8.4.4" >> /etc/systemd/resolved.conf
systemctl restart systemd-resolved
cp os_inst/antelope/hosts /etc/hosts
set +x
echo "---> Networking configured"
