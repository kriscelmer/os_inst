#! /bin/bash
echo "---> Installing Keystone"
set -e
set -x
cat << EOF | mysql
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'openstack';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'openstack';
EOF
DEBIAN_FRONTEND=noninteractive apt-get install -y keystone > /dev/null
crudini --set /etc/keystone/keystone.conf database connection "mysql+pymysql://keystone:openstack@10.0.0.11/keystone"
crudini --set /etc/keystone/keystone.conf token provider fernet
su -s /bin/sh -c "keystone-manage db_sync" keystone
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
keystone-manage bootstrap --bootstrap-password openstack --bootstrap-admin-url http://10.0.0.11:5000/v3/ --bootstrap-internal-url http://10.0.0.11:5000/v3/ --bootstrap-public-url http://10.0.0.11:5000/v3/ --bootstrap-region-id RegionOne
echo "ServerName 10.0.0.11" >> /etc/apache2/apache2.conf
service apache2 restart
cat << EOF > admin-openrc
export OS_USERNAME=admin
export OS_PASSWORD=openstack
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://10.0.0.11:5000/v3
export OS_IDENTITY_API_VERSION=3
EOF
set +x
echo "---> Keystone installed"
echo "---> Configuring domains, users and projects"
set -x
. admin-openrc
# openstack domain create --description "An Example Domain" example
openstack project create --domain default --description "Service Project" service
set +x
echo "Keystone configured"
