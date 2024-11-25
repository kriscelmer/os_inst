#! /bin/bash

set -e
set -x
ssh-copy-id openstack@compute3
ssh openstack@compute3 rm -rf os_inst
ssh openstack@compute3 git clone https://github.com/kriscelmer/os_inst
ssh openstack@compute3 sudo bash os_inst/caracal/compute3/install.sh
