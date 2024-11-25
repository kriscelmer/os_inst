echo "----> Installing OpenStack infrastructure services"
set -e
set -x
DEBIAN_FRONTEND=noninteractive apt-get install -y crudini > /dev/null
DEBIAN_FRONTEND=noninteractive apt-get install -y chrony > /dev/null
sed -i 's/^pool\ /#pool\ /g' /etc/chrony/chrony.conf
echo "server controller iburst" >> /etc/chrony/chrony.conf
service chrony restart
add-apt-repository -y cloud-archive:dalmatian > /dev/null
set +x
echo "---> Infra installed"
