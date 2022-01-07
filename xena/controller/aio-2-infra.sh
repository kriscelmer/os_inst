echo "----> Configuring OpenStack infrastructure for AIO"
set -e
set -x
cat << EOF | sfdisk /dev/sdb
/dev/sdb1: size=60GB, type=8e
/dev/sdb2: size=40GBm type=8e
/dev/sdb3: size=10GB, type=83
/dev/sdb4: size=10GB, type=83
write
EOF
set +x
echo "---> Infra installed"
