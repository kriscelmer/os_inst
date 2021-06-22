#! /bin/bash

echo "---> Configuring Networking for OpenStack"
set -e
set -x
cat << EOF > /tmp/hosts
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
sudo cp /tmp/hosts /etc/hosts
rm /tmp/hosts
ssh-keygen -t rsa -b 1024 -q -N ""
ssh-copy-id openstack@controller
ssh-copy-id openstack@compute1
ssh-copy-id openstack@compute2
ssh-copy-id openstack@block1
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
echo "---> Configuring networking on block1..."
ssh openstack@block1 git clone https://github.com/kriscelmer/os_inst
echo "openstack" | ssh openstack@block1 sudo -S bash /home/openstack/os_inst/wallaby/block1/1-networking.sh
ssh openstack@block1 sudo "shutdown -r +1"
echo "---> Configuring networking on console..."
echo "openstack" | sudo -S sh -c "echo 'openstack ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"
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
