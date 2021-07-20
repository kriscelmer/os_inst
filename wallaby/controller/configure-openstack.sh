#! /bin/bash

echo "---> Configuring OpenStack"
set -e
set -x
# Global configuration
. admin-openrc
openstack network create  --share --external --provider-physical-network provider --provider-network-type flat external-network
openstack subnet create --network external-network --allocation-pool start=203.0.113.101,end=203.0.113.250 --dns-nameserver 8.8.4.4 --gateway 203.0.113.1 --subnet-range 203.0.113.0/24 external-subnet
openstack flavor create --id 0 --vcpus 1 --ram 64 --disk 1 m1.nano
openstack security group rule create --proto icmp default
openstack security group rule create --proto tcp --dst-port 22 default
openstack volume type create lvm1
openstack volume type set lvm1 --property volume_backend_name=LVM-1
openstack volume type create lvm2
openstack volume type set lvm2 --property volume_backend_name=LVM-2
openstack project create --domain default --description "Demo Project" demo
openstack user create --domain default --password openstack demo
openstack role add --project demo --user demo member
openstack role add --project demo --user demo heat_stack_owner
# Demo project configuration
# . demo-openrc
# openstack network create demo-network
# openstack subnet create --network demo-network --dns-nameserver 8.8.4.4 --gateway 172.16.1.1 --subnet-range 172.16.1.0/24 demo-subnet
# openstack router create demo-router
# openstack router set demo-router --external-gateway external-network
# openstack router add subnet demo-router demo-network
# openstack security group create demo-sg --description "Allow ICMP and SSH from any address"
# openstack security group rule create --remote-group demo-sg --ingress --ethertype IPv4 demo-sg
# openstack security group rule create --remote-ip 0.0.0.0/0 --protocol icmp --ingress --ethertype IPv4 demo-sg
# openstack security group rule create --remote-ip 0.0.0.0/0 --protocol tcp --dst-port 22 --ingress --ethertype IPv4 demo-sg
# openstack keypair create --public-key /home/openstack/.ssh/id_rsa.pub demo-key
echo "---> OpenStack configured"
