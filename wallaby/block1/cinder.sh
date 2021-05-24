#! /bin/bash

echo "---> cinder on block1"
set -e
set -x
apt install -y lvm2 thin-provisioning-tools tgt crudini > /dev/null
pvcreate /dev/sdb
vgcreate cinder-volumes /dev/sdb
