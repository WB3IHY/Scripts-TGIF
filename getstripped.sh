#!/bin/bash
############################################################
#  Get User ID Database from radioid.net                   #
#  Save it to /usr/local/etc/stripped.csv                  #
#  Convert 'United States' to 'USA'                        #
#  					                   #
#  VE3RD                                      2022-01-12   #
############################################################
set -o errexit
set -o pipefail
sudo mount -o remount,rw /

sudo wget https://database.radioid.net/static/user.csv -O /usr/local/etc/stripped.csv
sudo sed -i 's/United States/USA/g' /usr/local/etc/stripped.csv
sudo sed -i 's/Australia/Aus/g' /usr/local/etc/stripped.csv
sudo sed -i 's/Canada/Can/g' /usr/local/etc/stripped.csv
#sudo sed -i 's/North Carolina/NC/g' /usr/local/etc/stripped.csv
#sudo sed -i 's/South Carolina/SC/g' /usr/local/etc/stripped.csv
sudo sed -i 's/DMR Mental Ward/TGIF Mothership/g' /usr/local/etc/groups.txt
sudo sed -i 's/DMR Campfire/TGIF Mothership/g' /usr/local/etc/groups.txt
cp /usr/local/etc/stripped.csv /usr/local/etc/users.csv
sudo mount -o remount,ro /

