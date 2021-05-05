#! /bin/bash
set -x
git clone https://opendev.org/openstack/openstack-ansible /opt/openstack-ansible && \
cd /opt/openstack-ansible && \
git checkout stable/victoria && \
scripts/bootstrap-ansible.sh && \
export SCENARIO="aio_lxc_barbican_octavia" && \
scripts/bootstrap-aio.sh && \
cd playbooks && \
openstack-ansible setup-hosts.yml && \
openstack-ansible setup-infrastructure.yml && \
openstack-ansible setup-openstack.yml && \
echo "Password for admin:" && \
grep keystone_auth_admin_password /etc/openstack_deploy/user_secrets.yml
