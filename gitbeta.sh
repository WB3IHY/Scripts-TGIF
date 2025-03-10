#!/bin/bash
#################################################################
#  Nextion TFT Support for VE3ZTD Nextion 3.5 Inch Screen	#
#  Gets all Scripts and support files from github       	#
#  and copies them into the Nextion_Support directory   	#
#  and copies the NX??? tft file into /usr/local/etc    	#
#  and returns a script duration time to the Screen 		#
#  as a script completion flag. VE3ZRD Version			#
#								#
#  KF6S/VE3RD                               2024-12-18  	#
#################################################################
# Use screen model from command $1
# Valid Screen Names for VE3ZRD - NX3224K024, NX4832K935
declare -i tst

if [ -z "$1" ]; then
	clear
	echo "           "
	echo "  No Screen Name Provided"
	echo
        echo "	 Valid Screens - VE3ZRD - NX3224K024, NX4024K032, NX4832K035"
	echo "    " 
	echo " 	Syntax: gitbeta.sh NX????K???   // Will copy VE3ZRD Files - Default for Screen"
	echo " 	Adding a second parameter(anything) will provide feedback as the script runs (Commandline)"
	echo "   "
	exit
fi
scn="$1"

errtext="Error! - Aborting"

## Strip off .tft - Take only the first 10 characters
scn=$(echo "$1" | tr [:lower:] [:upper:])
#tr [:lower:] [:upper:]
scn="${scn:0:10}"

#Feed back is off by default - Turn it on with anything as parameter  2
fb="$2"
#Set Call to VE3ZRD
repo="TGIF-Network"


## Programmed Shutdown
function exitcode
{
	echo "Script Execution Failed "
	echo "$scn"
	echo "$errtext"
	exit

}

function cleandirs()
{
if [ -d /usr/local/etc/Nextion_Support ]; then
    sudo rm -R /usr/local/etc/Nextion_Support
fi
if [ -d /home/pi-star/Nextion_Temp ]; then
    sudo rm -R /home/pi-star/Nextion_Temp
fi
if [ -f /usr/local/etc/"$model$tft" ]; then
	sudo rm /usr/local/etc/NX*.tft
fi
if [ "$fb" ]; then
    echo "Removed /usr/local/etc/Nextion_Support Directory"
    echo "Removed /home/pi-star/Nextion_Temp Directory"
    echo "Removed Existing $model$tft"
fi

}

# VE3ZRD Script Function
function getVE3ZRD
{
	tst=0
#	echo "Function VE3ZRD"
	repo="VE3ZRD"

 #      echo "Screen = $scn"

	if [ "$scn" == "NX4832K035" ]; then
		cleandirs
	  	sudo git clone --depth 1 https://github.com/TGIF-Network/NX4832K035-ZRD /home/pi-star/Nextion_Temp
		sudo chmod +x /home/pi-star/Nextion_Temp/*.sh
		mkdir /usr/local/etc/Nextion_Support
		sudo rsync -avqru /home/pi-star/Nextion_Temp/* /usr/local/etc/Nextion_Support/ --exclude=NX*  --exclude=profiles.ini
		sudo cp /home/pi-star/Nextion_Temp/"$model$tft" /usr/local/etc/
		if [ "$fb" ]; then
		    	echo "Downloaded new Screen package for $model$tft"
			echo "Copied new tft to /usr/local/etc/"	
		fi
		tst=2	
     	fi
	if [ "$scn" == "NX4024K032" ]; then
 		cleandirs
                sudo git clone --depth 1 https://github.com/TGIF-Network/NX4024K032-ZRD /home/pi-star/Nextion_Temp
                sudo chmod +x /home/pi-star/Nextion_Temp/*.sh
                mkdir /usr/local/etc/Nextion_Support
                sudo rsync -avqru /home/pi-star/Nextion_Temp/* /usr/local/etc/Nextion_Support/ --exclude=NX*
                sudo cp /home/pi-star/Nextion_Temp/"$model$tft" /usr/local/etc/
                if [ "$fb" ]; then
                        echo "Downloaded new Screen package for $model$tft"
                        echo "Copied new tft to /usr/local/etc/"
                fi
		tst=2
	fi

	if [ "$scn" == "NX3224K024" ]; then
 		cleandirs
                sudo git clone --depth 1 https://github.com/TGIF-Network/NX3224K024-ZRD /home/pi-star/Nextion_Temp
                sudo chmod +x /home/pi-star/Nextion_Temp/*.sh
                mkdir /usr/local/etc/Nextion_Support
                sudo rsync -avqru /home/pi-star/Nextion_Temp/* /usr/local/etc/Nextion_Support/ --exclude=NX*
                sudo cp /home/pi-star/Nextion_Temp/"$model$tft" /usr/local/etc/
                if [ "$fb" ]; then
                        echo "Downloaded new Screen package for $model$tft"
                        echo "Copied new tft to /usr/local/etc/"
                fi
		tst=2
	fi


	if [ "$tst" == 0 ]; then
		errtext="Invalid VE3ZRD Screen Name $scn"	
		exitcode 
	fi
}


#### Start of Main Code
s1="NX4832K035"
s2="NX4024K032"
s3="NX3224K024"

#echo "$scn - $s1"
if [ ! "$scn" == "$s1" ] && [ ! "$scn" == "$s2" ] && [ ! "$scn" == "$s3 "]; then
	if [ "$fb" ]; then
        	echo "VE3ZRD Screen Name MUST be NX3224K024, NX4024K032 or NX4832K035"
         	errtext="Invalid VE3ZRD Screen Name"
      		exitcode
	fi
else
	if [ "$fb" ]; then
		echo "Loading VE3ZRD $scn Screen Package"
	fi        
fi


#echo " End Processing Parameters  - $scn $call"

#Start Duration Timer
start=$(date +%s.%N)

#Disable all command feedback
if [ ! "$fb" ]; then
	exec 3>&2
	exec 2> /dev/null 
fi

model="$scn"
tft='.tft' 
#gz='.gz'
#Put Pi-Star file system in RW mode
sudo mount -o remount,rw /

#Stop the cron service
sudo systemctl stop cron.service  > /dev/null

getVE3ZRD
 
model="$scn"

 FILE=/usr/local/etc/"$model$tft"
 if [ ! -f "$FILE" ]; then
        # Copy failed
      echo "No TFT File Available to Flash - Try Again"
	errtext="Missing tft File Parameter"
	exitcode
 fi

sudo systemctl start cron.service  > /dev/null

duration=$(echo "$(date +%s.%N) - $start" | bc)
execution_time=`printf "%.2f secs" $duration`

if [ ! "$fb" ]; then
 exec 2>&3
fi 

if [ ! -f "/etc/Colors.ini" ]; then
	cp /home/pi-star/Nextion_Temp/Colors.ini /etc/
	if [ ! "$fb" ]; then
 		echo "Copying Colors.ini /etc/"
	fi 

fi
if [ ! -f "/etc/profiles.ini" ]; then
	cp /home/pi-star/Nextion_Temp/profiles.ini /etc/
	if [ ! "$fb" ]; then
 		echo "Copying Copying profiles.ini.ini to /etc/"
	fi 

fi
# echo "$scn Ready  $execution_time"
echo "$scn Ready to Flash! \r Time=$execution_time"



