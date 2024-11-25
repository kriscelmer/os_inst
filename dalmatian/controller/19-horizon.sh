#! /bin/bash

echo "---> Installing horizon"
set -e
set -x
DEBIAN_FRONTEND=noninteractive apt-get install -y openstack-dashboard python3-heat-dashboard > /dev/null
sed -i '/^OPENSTACK_KEYSTONE_URL/c\OPENSTACK_KEYSTONE_URL="http://controller:5000/v3"' /etc/openstack-dashboard/local_settings.py
sed -i 's/127.0.0.1/controller/g' /etc/openstack-dashboard/local_settings.py
cat << EOF >> /etc/openstack-dashboard/local_settings.py
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True
OPENSTACK_API_VERSIONS = {
    "identity": 3,
    "image": 2,
    "volume": 3,
}
OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = "Default"
OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"
OPENSTACK_CINDER_FEATURES = {'enable_backup': True}
EOF
systemctl reload apache2.service
set +x
echo "---> horizon installed"
