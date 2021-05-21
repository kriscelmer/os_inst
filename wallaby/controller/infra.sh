#! /bin/bash
set +x
echo "----> Installing OpenStack infrastructure services"
apt install -y chrony && \
echo "allow 10.0.0.0/24" >> /etc/chrony/chrony.conf && \
service chrony restart && \
add-apt-repository -y cloud-archive:wallaby && \
apt install -y python3-openstackclient && \
apt install -y mariadb-server python3-pymysql && \
cat << EOF >  /etc/mysql/mariadb.conf.d/99-openstack.cnf
[mysqld]
bind-address = 10.0.0.11
default-storage-engine = innodb
innodb_file_per_table = on
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
EOF
service mysql restart && \
cat << EOF | mysql_secure_installation

openstack
openstack
y
y
y
y
EOF
apt install -y rabbitmq-server && \
rabbitmqctl add_user openstack openstack && \
rabbitmqctl set_permissions openstack ".*" ".*" ".*" && \
apt install -y memcached python-memcached && \
sed -i 's/-l 127.0.0.1/-l 10.0.0.11/' /etc/memcached.conf && \
service memcached restart && \
apt install -y etcd && \
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
systemctl enable etcd && \
systemctl restart etcd && \
echo "---> Completed Infrastructure services"
