#! /bin/bash

set -x
set -e
ssh openstack@controller sudo bash os_inst/wallaby/controller/install.sh
ssh openstack@storage1 sudo bash os_inst/wallaby/block1/install.sh
ssh openstack@storage2 sudo bash os_inst/wallaby/block2/install.sh
ssh openstack@compute1 sudo bash os_inst/wallaby/compute1/install.sh
ssh openstack@compute2 sudo bash os_inst/wallaby/compute2/install.sh
ssh openstack@controller sudo bash os_inst/wallaby/controller/register-computes.sh
