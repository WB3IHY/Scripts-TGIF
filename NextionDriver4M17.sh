#!/bin/bash
sudo mount -o remount,rw /

old=SendUserDataMask=0b00
new=SendUserDataMask=0b01

sed -i 's/'"${old}"'/'"${new}"'/g' /etc/mmdvmhost


systemctl stop nextiondriver.service &> /dev/null
systemctl stop mmdvmhost.service &> /dev/null

cp  /home/pi-star/Scripts/NextionDriver /usr/local/bin/

systemctl start mmdvmhost.service &> /dev/null
systemctl start nextiondriver.service &> /dev/null

echo "Nextion Driver Replaced"
echo "SendUserDataMask Updated for M17"
sleep 3


