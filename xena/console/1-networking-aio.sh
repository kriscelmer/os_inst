#! /bin/bash

echo "---> Configuring Networking for OpenStack"
set -e
set -x
echo "openstack" | sudo -S sh -c "echo 'openstack ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"
sudo cp os_inst/xena/hosts /etc/hosts
echo "---> Configuring networking on console..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install ifupdown > /dev/null
sudo cp os_inst/xena/console/interfaces /etc/network/interfaces
sudo sh -c "ifdown --force enp0s3 enp0s8 enp0s9 lo && ifup -a"
sudo systemctl unmask networking
sudo systemctl enable networking
sudo systemctl restart networking
sudo systemctl stop systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
sudo systemctl disable systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
sudo systemctl mask systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
sudo DEBIAN_FRONTEND=noninteractive apt-get -y --assume-yes purge nplan netplan.io > /dev/null
sudo sh -c 'echo "DNS=8.8.8.8 8.8.4.4" >> /etc/systemd/resolved.conf'
sudo systemctl restart systemd-resolved
set +x
echo "---> Networking configured"
sudo reboot
