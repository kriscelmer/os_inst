#! /bin/bash

echo "---> Configuring Networking for OpenStack"
set -e
set -x
ssh-keygen -t rsa -b 256 -q -N ""
echo "openstack" | ssh-copy-id openstack@10.0.0.11
echo "openstack" | ssh-copy-id openstack@10.0.0.31
echo "openstack" | ssh-copy-id openstack@10.0.0.32
echo "openstack" | ssh-copy-id openstack@10.0.0.41
ssh openstack@10.0.0.11 git clone https://github.com/kriscelmer/os_inst
echo "openstack" | ssh openstack@10.0.0.11 sudo -S bash /home/openstack/os_inst/wallaby/controller/1-networking.sh
ssh openstack@10.0.0.11 sudo reboot
echo "Press Enter to continue..."
read
apt update > /dev/null
apt -y dist-upgrade > /dev/null
echo "openstack ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
apt -y install ifupdown > /dev/null
cp os_inst/wallaby/controller/interfaces /etc/network/interfaces
ifdown --force enp0s3 enp0s8 enp0s9 lo && ifup -a
systemctl unmask networking
systemctl enable networking
systemctl restart networking
systemctl stop systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
systemctl disable systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
systemctl mask systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online
apt -y --assume-yes purge nplan netplan.io > /dev/null
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
