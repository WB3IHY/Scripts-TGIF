#!/bin/bash
############################################################
#  This script will restart MMDVM                          #
#                                                          #
#  VE3RD                                      2025/01/18   #
############################################################
set -o errexit
set -o pipefail

sudo mount -o remount,rw /
sudo systemctl restart mmdvmhost.service
sudo mount -o remount,ro /

