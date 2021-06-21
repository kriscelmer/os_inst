#! /bin/bash

echo "---> Configuring Networking for OpenStack"
set -e
set -x
ssh-keygen -t rsa -b 1024 -q -N ""
ssh-copy-id openstack@10.0.0.11
ssh-copy-id openstack@10.0.0.31
ssh-copy-id openstack@10.0.0.32
ssh-copy-id openstack@10.0.0.41
echo "---> Configuring networking on controller..."
ssh openstack@10.0.0.11 git clone https://github.com/kriscelmer/os_inst
echo "openstack" | ssh openstack@10.0.0.11 sudo -S bash /home/openstack/os_inst/wallaby/controller/1-networking.sh
ssh openstack@10.0.0.11 sudo "shutdown -r +1"
echo "---> Configuring networking on compute1..."
ssh openstack@10.0.0.31 git clone https://github.com/kriscelmer/os_inst
echo "openstack" | ssh openstack@10.0.0.31 sudo -S bash /home/openstack/os_inst/wallaby/compute1/1-networking.sh
ssh openstack@10.0.0.31 sudo "shutdown -r +1"
echo "---> Configuring networking on compute2..."
ssh openstack@10.0.0.32 git clone https://github.com/kriscelmer/os_inst
echo "openstack" | ssh openstack@10.0.0.32 sudo -S bash /home/openstack/os_inst/wallaby/compute2/1-networking.sh
ssh openstack@10.0.0.32 sudo "shutdown -r +1"
echo "---> Configuring networking on block1..."
ssh openstack@10.0.0.41 git clone https://github.com/kriscelmer/os_inst
echo "openstack" | ssh openstack@10.0.0.41 sudo -S bash /home/openstack/os_inst/wallaby/block1/1-networking.sh
ssh openstack@10.0.0.41 sudo "shutdown -r +1"
echo "---> Configuring networking on console..."
echo "openstack ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
sudo DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade > /dev/null
sudo DEBIAN_FRONTEND=noninteractive apt-get -y install ifupdown > /dev/null
sudo cp os_inst/wallaby/controller/interfaces /etc/network/interfaces
sudo ifdown --force enp0s3 enp0s8 enp0s9 lo && ifup -a
sudo systemctl unmask networking
sudo systemctl enable networking
sudo systemctl restart networking
sudo systemctl stop systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
sudo systemctl disable systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
sudo systemctl mask systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
sudo DEBIAN_FRONTEND=noninteractive apt-get -y --assume-yes purge nplan netplan.io > /dev/null
sudo echo "DNS=8.8.8.8 8.8.4.4" >> /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved
sudo cat << EOF > /etc/hosts
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
