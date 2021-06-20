#! /bin/bash

set -x
set -e

for script in os_inst/wallaby/controller/[2-7]-*
do
  bash $script
done
bash os_inst/wallaby/controller/9-cinder.sh
bash os_inst/wallaby/controller/10-heat.sh
bash os_inst/wallaby/controller/11-horizon.sh
bash os_inst/wallaby/controller/configure-openstack.sh
