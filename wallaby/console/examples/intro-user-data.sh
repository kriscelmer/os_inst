#!/bin/sh

mkdir /home/cirros/web
cat << EOF > /home/cirros/web/webserver
while true
do
  echo "<h1>Hello world!</h1><p><i> webserver @ \`hostname\`</i>" | nc -l -p 80
done
EOF

chmod 755 /home/cirros/web/webserver

cat << EOF > /etc/rc.local
#!/bin/sh
nohup sh /home/cirros/web/webserver &
EOF

chmod 755 /etc/rc.local

cat << EOF >> /home/cirros/.profile
PS1="\u@\h:\w $ "
EOF
