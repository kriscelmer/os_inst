echo "----> Installing OpenStack infrastructure services"
set -e
set -x
apt install -y chrony > /dev/null
echo "allow 10.0.0.0/24" >> /etc/chrony/chrony.conf
service chrony restart
add-apt-repository -y cloud-archive:wallaby > /dev/null
set +x
echo "---> Infra installed"
