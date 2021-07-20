#! /bin/bash
echo "---> Installing Heat"
set -e
set -x
cat << EOF | mysql
CREATE DATABASE heat;
GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'localhost' IDENTIFIED BY 'openstack';
GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'%' IDENTIFIED BY 'openstack';
EOF
. admin-openrc
openstack user create --domain default --password openstack heat
openstack role add --project service --user heat admin
openstack service create --name heat --description "Orchestration" orchestration
openstack service create --name heat-cfn --description "Orchestration"  cloudformation
openstack endpoint create --region RegionOne orchestration public 'http://controller:8004/v1/%(tenant_id)s'
openstack endpoint create --region RegionOne orchestration internal 'http://controller:8004/v1/%(tenant_id)s'
openstack endpoint create --region RegionOne orchestration admin 'http://controller:8004/v1/%(tenant_id)s'
openstack endpoint create --region RegionOne cloudformation public http://controller:8000/v1
openstack endpoint create --region RegionOne cloudformation internal http://controller:8000/v1
openstack endpoint create --region RegionOne cloudformation admin http://controller:8000/v1
openstack domain create --description "Stack projects and users" heat
openstack user create --domain heat --password openstack heat_domain_admin
openstack role add --domain heat --user-domain heat --user heat_domain_admin admin
openstack role create heat_stack_owner
openstack role add --project demo --user demo heat_stack_owner
openstack role create heat_stack_user
DEBIAN_FRONTEND=noninteractive apt-get install -y heat-api heat-api-cfn heat-engine python3-vitrageclient python3-zunclient > /dev/null
crudini --set /etc/heat/heat.conf database connection 'mysql+pymysql://heat:openstack@controller/heat'
crudini --set /etc/heat/heat.conf DEFAULT transport_url 'rabbit://openstack:openstack@controller'
crudini --set /etc/heat/heat.conf keystone_authtoken www_authenticate_uri http://controller:5000/v3
crudini --set /etc/heat/heat.conf keystone_authtoken auth_url http://controller:5000/v3
crudini --set /etc/heat/heat.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/heat/heat.conf keystone_authtoken auth_type password
crudini --set /etc/heat/heat.conf keystone_authtoken project_domain_name default
crudini --set /etc/heat/heat.conf keystone_authtoken user_domain_name default
crudini --set /etc/heat/heat.conf keystone_authtoken project_name service
crudini --set /etc/heat/heat.conf keystone_authtoken username heat
crudini --set /etc/heat/heat.conf keystone_authtoken password openstack
crudini --set /etc/heat/heat.conf trustee auth_type password
crudini --set /etc/heat/heat.conf trustee auth_url http://controller:5000/v3
crudini --set /etc/heat/heat.conf trustee username heat
crudini --set /etc/heat/heat.conf trustee password openstack
crudini --set /etc/heat/heat.conf trustee user_domain_name default
crudini --set /etc/heat/heat.conf clients_keystone auth_uri http://controller:5000/v3
crudini --set /etc/heat/heat.conf DEFAULT heat_metadata_server_url http://controller:8000
crudini --set /etc/heat/heat.conf DEFAULT heat_waitcondition_server_url http://controller:8000/v1/waitcondition
crudini --set /etc/heat/heat.conf DEFAULT stack_domain_admin heat_domain_admin
crudini --set /etc/heat/heat.conf DEFAULT stack_domain_admin_password openstack
crudini --set /etc/heat/heat.conf DEFAULT stack_user_domain_name heat
su -s /bin/sh -c "heat-manage db_sync" heat
service heat-api restart
service heat-api-cfn restart
service heat-engine restart
set +x
echo "---> Heat installed"
