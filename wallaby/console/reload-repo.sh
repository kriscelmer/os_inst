#! /bin/bash

set -x
set -e

for node in "controller" "compute1" "compute2" "storage1" "storage2"
do
  echo "---> reloding os_inst repo on $node"
  ssh openstack@$node rm -rf os_inst
  ssh openstack@$node git clone https://github.com/kriscelmer/os_inst
done
echo "--> reloading os_inst repo on console"
rm -rf os_inst
git clone https://github.com/kriscelmer/os_inst
