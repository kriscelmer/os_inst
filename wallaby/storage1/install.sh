#! /bin/bash

set -x
set -e
for script in os_inst/wallaby/storage1/[2-4]*
do
  bash $script
done
