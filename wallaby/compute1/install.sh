#! /bin/bash

set -x
set -e

sudo DEBIAN_FRONTEND=noninteractive apt-get update -y > /dev/null
for script in os_inst/wallaby/compute1/[2-4]*
do
  bash $script
done
