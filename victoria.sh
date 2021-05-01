#! /bin/bash
set -x
git clone https://opendev.org/openstack/openstack-ansible /opt/openstack-ansible && \
cd /opt/openstack-ansible && \
git checkout stable/victoria && \
scripts/bootstrap-ansible.sh && \
scripts/bootstrap-aio.sh && \
cd playbooks && \
openstack-ansible setup-hosts.yml && \
openstack-ansible setup-infrastructure.yml && \
openstack-ansible setup-openstack.yml
