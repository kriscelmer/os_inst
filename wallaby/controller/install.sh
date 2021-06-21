#! /bin/bash

set -x
set -e

for script in os_inst/wallaby/controller/[2-7]-*
do
  bash $script
done
bash os_inst/wallaby/controller/9-cinder.sh
#bash os_inst/wallaby/controller/10-heat.sh
bash os_inst/wallaby/controller/11-designate.sh
bash os_inst/wallaby/controller/19-horizon.sh
bash os_inst/wallaby/controller/configure-openstack.sh
echo "Heat not installed!!!"
