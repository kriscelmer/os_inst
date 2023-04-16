#! /bin/bash

echo "----> Installing OpenStack infrastructure services"
set -e
set -x
DEBIAN_FRONTEND=noninteractive apt-get install -y crudini > /dev/null
DEBIAN_FRONTEND=noninteractive apt-get install -y chrony > /dev/null
echo "allow 10.0.0.0/24" >> /etc/chrony/chrony.conf
service chrony restart
DEBIAN_FRONTEND=noninteractive add-apt-repository -y cloud-archive:ussuri > /dev/null
DEBIAN_FRONTEND=noninteractive apt-get install -y python3-openstackclient > /dev/null
DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server python3-pymysql > /dev/null
cat << EOF >  /etc/mysql/mariadb.conf.d/99-openstack.cnf
[mysqld]
bind-address = 10.0.0.11
default-storage-engine = innodb
innodb_file_per_table = on
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
EOF
service mysql restart
cat << EOF | mysql_secure_installation

openstack
openstack
y
y
y
y
EOF
DEBIAN_FRONTEND=noninteractive apt-get install -y rabbitmq-server > /dev/null
rabbitmqctl add_user openstack openstack
rabbitmqctl set_permissions openstack ".*" ".*" ".*"
DEBIAN_FRONTEND=noninteractive apt-get install -y memcached python3-memcache > /dev/null
sed -i 's/-l 127.0.0.1/-l 10.0.0.11/' /etc/memcached.conf
service memcached restart
DEBIAN_FRONTEND=noninteractive apt-get install -y etcd > /dev/null
cat << EOF >>  /etc/default/etcd
ETCD_NAME="controller"
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_INITIAL_CLUSTER_STATE="new"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-01"
ETCD_INITIAL_CLUSTER="controller=http://10.0.0.11:2380"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://10.0.0.11:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://10.0.0.11:2379"
ETCD_LISTEN_PEER_URLS="http://0.0.0.0:2380"
ETCD_LISTEN_CLIENT_URLS="http://10.0.0.11:2379"
EOF
systemctl enable etcd
systemctl restart etcd
echo "---> Completed Infrastructure services"
