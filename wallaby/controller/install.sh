#! /bin/bash

set -x
set -e

for script in os_inst/wallaby/controller/[2-9]*
do
  bash $script
done
bash os_inst/wallaby/controller/configure-openstack.sh
