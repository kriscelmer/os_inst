#! /bin/bash

set -x
set -e

DEBIAN_FRONTEND=noninteractive apt-get update -y > /dev/null
for script in os_inst/xena/storage1/[2-4]*
do
  bash $script
done
