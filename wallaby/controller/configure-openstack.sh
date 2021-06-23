#! /bin/bash

echo "---> Configuring OpenStack"
set -e
set -x
. admin-openrc
openstack network create  --share --external --provider-physical-network provider --provider-network-type flat provider
openstack subnet create --network provider --allocation-pool start=203.0.113.101,end=203.0.113.250 --dns-nameserver 8.8.4.4 --gateway 203.0.113.1 --subnet-range 203.0.113.0/24 provider
openstack network create selfservice
openstack subnet create --network selfservice --dns-nameserver 8.8.4.4 --gateway 172.16.1.1 --subnet-range 172.16.1.0/24 selfservice
openstack router create router
openstack router add subnet router selfservice
openstack router set router --external-gateway provider
openstack flavor create --id 0 --vcpus 1 --ram 64 --disk 1 m1.nano
openstack security group rule create --proto icmp default
openstack security group rule create --proto tcp --dst-port 22 default
openstack volume type create lvm1
openstack volume type set lvm1 --property volume_backend_name=LVM-1
openstack volume type create lvm2
openstack volume type set lvm2 --property volume_backend_name=LVM-2
echo "---> OpenStack configured"
