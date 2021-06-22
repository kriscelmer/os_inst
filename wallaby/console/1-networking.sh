#! /bin/bash

echo "---> Configuring Networking for OpenStack"
set -e
set -x
echo "openstack" | sudo -S sh -c "echo 'openstack ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"
sudo cp os_inst/wallaby/hosts /etc/hosts
ssh-keygen -t rsa -b 1024 -q -N ""
ssh-copy-id openstack@controller
ssh-copy-id openstack@compute1
ssh-copy-id openstack@compute2
ssh-copy-id openstack@storage1
ssh-copy-id openstack@storage2
echo "---> Configuring networking on controller..."
ssh openstack@controller git clone https://github.com/kriscelmer/os_inst
echo "openstack" | ssh openstack@controller sudo -S bash /home/openstack/os_inst/wallaby/controller/1-networking.sh
ssh openstack@controller sudo "shutdown -r +1"
echo "---> Configuring networking on compute1..."
ssh openstack@compute1 git clone https://github.com/kriscelmer/os_inst
echo "openstack" | ssh openstack@compute1 sudo -S bash /home/openstack/os_inst/wallaby/compute1/1-networking.sh
ssh openstack@compute1 sudo "shutdown -r +1"
echo "---> Configuring networking on compute2..."
ssh openstack@compute2 git clone https://github.com/kriscelmer/os_inst
echo "openstack" | ssh openstack@compute2 sudo -S bash /home/openstack/os_inst/wallaby/compute2/1-networking.sh
ssh openstack@compute2 sudo "shutdown -r +1"
echo "---> Configuring networking on storage1..."
ssh openstack@storage1 git clone https://github.com/kriscelmer/os_inst
echo "openstack" | ssh openstack@storage1 sudo -S bash /home/openstack/os_inst/wallaby/storage1/1-networking.sh
ssh openstack@storage1 sudo "shutdown -r +1"
echo "---> Configuring networking on storage2..."
ssh openstack@storage2 git clone https://github.com/kriscelmer/os_inst
echo "openstack" | ssh openstack@storage2 sudo -S bash /home/openstack/os_inst/wallaby/storage2/1-networking.sh
ssh openstack@storage2 sudo "shutdown -r +1"
echo "---> Configuring networking on console..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install ifupdown > /dev/null
sudo cp os_inst/wallaby/console/interfaces /etc/network/interfaces
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
reboot
