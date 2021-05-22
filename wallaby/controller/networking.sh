#! /bin/bash

echo "---> Connfiguring Networking for OpenStack"
set +x
apt install -y ifupdown && \
cp os_inst/wallaby/controller/interfaces /etc/network/interfaces && \
ifdown --force enp0s3 enp0s8 enp0s9 lo && ifup -a && \
systemctl unmask networking && \
systemctl enable networking && \
systemctl restart networking && \
systemctl stop systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online && \
systemctl disable systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online && \
systemctl mask systemd-networkd.socket systemd-networkd networkd-dispatcher systemd-networkd-wait-online && \
apt-get --assume-yes purge nplan netplan.io && \
echo "DNS=8.8.8.8 8.8.4.4" >> /etc/systemd/resolved.conf && \
systemctl restart systemd-resolved && \
set -x
echo "---> Networking configured"