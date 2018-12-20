#!/usr/bin/env bash

timezone=$(echo "$1")

function info {
  echo " "
  echo "-> $1"
  echo " "
}

#== Provision script ==
info "Provision-script user: `whoami`"
info "Configure timezone"
timedatectl set-timezone ${timezone} --no-ask-password

info "Install additional software"
yum -y install epel-release
echo "Done!"

info "Install Mosquitto"
yum -y install mosquitto
systemctl enable mosquitto
echo "Done!"

info "Install MongoDB - Add to repositories"
cat << EOF > /etc/yum.repos.d/mongodb-org.repo
[mongodb-org-3.6]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/7/mongodb-org/3.6/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.6.asc
EOF
echo "Done!"

info "Install MongoDB"
yum repolist
yum install -y mongodb-org
echo "Done!"

info "Configure MongoDB DB and create MongoDB User"
# Enable connection to mongodb from anywhere - NOT SECURE FOR PRODUCTION
sed -i "s/bindIp.*/bindIp: 0.0.0.0/" /etc/mongod.conf
service mongod start
mongo --eval 'db.getSiblingDB("orion").createUser({user: "orion", pwd: "orion_pass", roles: [{role: "readWrite", db: "orion"}]})'
echo "Done!"


info "Install ContextBroker - Add to repositories"
cat << EOF > /etc/yum.repos.d/fiware-orion.repo
[fiware-release]
name=FIWARE release repository
baseurl=https://nexus.lab.fiware.org/repository/el/7/x86_64/release
enabled=1
protect=0
gpgcheck=0
metadata_expire=30s
autorefresh=1
type=rpm-md
EOF

info "Install ContextBroker"
yum clean all
yum repolist
yum install -y contextBroker

sed -i "s/BROKER_USER=.*/BROKER_USER=root/" /etc/sysconfig/contextBroker
sed -i "s/BROKER_PID_FILE=.*/BROKER_PID_FILE=\/var\/run\/contextBroker.pid/" /etc/sysconfig/contextBroker
sed -i "s/#BROKER_DATABASE_USER=.*/BROKER_DATABASE_USER=orion/" /etc/sysconfig/contextBroker
sed -i "s/#BROKER_DATABASE_PASSWORD=.*/BROKER_DATABASE_PASSWORD=orion_pass/" /etc/sysconfig/contextBroker

echo "Done!"
