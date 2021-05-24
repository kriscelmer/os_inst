echo "----> Installing OpenStack infrastructure services"
set -e
set -x
apt install -y chrony > /dev/null
sed -i 's/^pool\ /#pool\ /g' /etc/chrony/chrony.conf
echo "server controller iburst" >> /etc/chrony/chrony.conf
service chrony restart
add-apt-repository -y cloud-archive:wallaby > /dev/null
set +x
echo "---> Infra installed"
