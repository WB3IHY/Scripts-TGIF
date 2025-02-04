
#!/bin/bash
############################################################
#  This script will modify the Nextion Driver Log Level    #
#                                                          #
#  VE3RD                              Created 2025/02/01   #
############################################################
#set -o errexit
#set -o pipefail

if [ "$1" != "2" ] && [ "$1" != "4" ] ; then

echo "Invalid Parameters "
echo "syntax nslog.sh 2 or 4"
exit

fi


sudo mount -o remount,rw /
 sudo sed -i '/^\[/h;G;/NextionDriver/s/\(LogLevel=\).*/\1'"$1"'/m;P;d'  /etc/mmdvmhost
 nextiondriver.service restart
sudo mount -o remount,ro /

