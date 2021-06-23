#! /bin/bash

for node in "controller compute1 compute2 storage1 storage2"
do
  ssh openstack@$node rm -rf os_inst
  ssh openstack@$node git clone https://github.com/kriscelmer/os_inst
done
rm -rf os_inst
git clone https://github.com/kriscelmer/os_inst
