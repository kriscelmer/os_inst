#! /bin/bash

set -x
set -e

DEBIAN_FRONTEND=noninteractive apt-get update -y > /dev/null
for script in os_inst/ussuri/controller/[2-9]-*
do
  bash $script
done
bash os_inst/ussuri/controller/10-heat.sh
bash os_inst/ussuri/controller/19-horizon.sh
bash os_inst/ussuri/controller/configure-openstack.sh
