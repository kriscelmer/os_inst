#! /bin/bash
echo "---> Installing Designate"
set -e
set -x
. admin-openrc
openstack user create --domain default --password openstack designate
openstack role add --project service --user designate admin
openstack service create --name designate --description "DNS" dns
openstack endpoint create --region RegionOne dns public http://controller:9001/
apt-get install -y designate > /dev/null
cat << EOF | mysql
CREATE DATABASE designate CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON designate.* TO 'designate'@'localhost' IDENTIFIED BY 'openstack';
GRANT ALL PRIVILEGES ON designate.* TO 'designate'@'%' IDENTIFIED BY 'openstack';
EOF
apt-get install -y bind9 bind9utils bind9-doc > /dev/null
rndc-confgen -a -k designate -c /etc/designate/rndc.key -r /dev/urandom
echo "Continue with manual config, press any key to continue..."
read
