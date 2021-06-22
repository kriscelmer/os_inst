#! /bin/bash

set -x
set -e
for script in os_inst/wallaby/block1/[2-3]*
do
  bash $script
done
