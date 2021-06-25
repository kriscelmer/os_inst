#! /bin/bash

set -x
set -e

for script in os_inst/wallaby/compute3/[2-4]*
do
  bash $script
done
