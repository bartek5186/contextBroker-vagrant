#!/usr/bin/env bash

function info {
  echo " "
  echo "--> $1"
  echo " "
}

info "Restart apps"
sudo systemctl restart mosquitto
echo "Mosquitto... Done!"

service mongod restart
echo "MongoDB restart... Done!"
/etc/init.d/contextBroker restart
echo "ContextBroker... Done!"
service iotaul restart
echo "IoT Agent... Done!"

info "Main - Hello Dev - You probably can try do something now"
echo "Provision-script user: `whoami`"
echo "IP: 192.168.66.66"
