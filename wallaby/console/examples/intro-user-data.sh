#!/bin/sh

mkdir /home/cirros/web
echo "while true ; do nc -l -p 80 < /home/cirros/web/index.html ; done" > /home/cirros/web/webserver
chmod 755 /home/cirros/web/webserver

HOST=`hostname`
echo "<h1>Hello world!</h1><i>webserver @ $HOST</i>" > /home/cirros/web/index.html

cat << EOF > /etc/rc.local
#!/bin/sh
nohup sh /home/cirros/web/webserver &
EOF

chmod 755 /etc/rc.local

cat << EOF >> /home/cirros/.profile
PS1="\u@\h:\w $ "
EOF
