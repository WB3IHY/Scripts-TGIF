#!/bin/bash
#################################################################
#  Nextion TFT Support for Nextion 2.4 and 3.5 inch Screen	#
#  Gets all Scripts and support files from github       	#
#  and copies them into the Nextion_Support directory   	#
#  and copies the NX??? tft file into /usr/local/etc    	#
#  and returns a script duration time to the Screen 		#
#  as a script completion flag					#
#								#
#  VE3RD                               2025-03-21        	#
#################################################################
# Use screen model from command $1
# Valid Screen Names for EA7KDO - NX3224K024, NX4832K935
if [ -z "$1" ]; then
	echo "Syntax copydata Colors     // to copy ColorThemes.ini to /eytc/"
	echo "Syntax copydata Profiles    // to copy Profiles.ini to /etc/"
	echo "Syntax copydata WiFi	// to copy wifiprofiles.ini to /etc"
exit
fi


function copycolors
{
		# Send ColorThemes.ini to /etc if required
			cp /home/pi-star/Nextion_Temp/ColorThemes.ini /etc/

}
function copyprofiles
{
		# Send profiles.ini to /etc/ if required.
			cp /home/pi-star/Nextion_Temp/profiles.ini /etc/
}
function copywifiprofiles
{
		# Send wifiprofiles.ini to /etc/ if required.
			cp /home/pi-star/Nextion_Temp/wifiprofiles.ini /etc/
}

#### Start of Main Code

sudo mount -o remount,rw /
if [ "$1" == "Colors" ]; then
copycolors
fi

if [ "$1" == "Profiles" ]; then
copyprofiles
fi

if [ "$1" == "WiFi" ]; then
copywifiprofiles
fi





