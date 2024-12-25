#!/bin/bash
#########################################################
#  Nextion TFT Support for Nextion 3.2" 		#
#  Gets all Scripts and support files from github       #
#  and copies them into the Nextion_Support directory   "
#  and copies the NX??? tft file into /usr/local/etc    #
#  and returns a script duration time to the Screen 	#
#  as a script completion flag				#
#							#
#  KF6S/VE3RD                               2024-12-21  #
#########################################################
p1=$(pwd) ; cd .. ; homedir=$(pwd) ; cd "$p1"

who=$(whoami)
echo "This script is running as $who user"
sleep 2

run=""

errtext="This is a test"

export NCURSES_NO_UTF8_ACS=1
export LANG=en_US.UTF-8

if [ ! -f ~/.dialog ]; then
# j=1
# else
 sudo dialog --create-rc ~/.dialogrc
fi

sudo sed -i '/use_colors = /c\use_colors = ON' ~/.dialogrc
sudo sed -i '/screen_color = /c\screen_color = (WHITE,BLUE,ON)' ~/.dialogrc
sudo sed -i '/title_color = /c\title_color = (YELLOW,RED,ON)' ~/.dialogrc
echo -e '\e[1;44m'


function exitcode
{
txt='Abort Function\n\n
This Script will Now Stop'"\n$errtext"

dialog --title "  Programmed Exit  " --ascii-lines --msgbox "$txt" 8 78

clear
echo -e '\e[1;40m'
run="Done"
exit

}



# VE3ZRD Script Function
function getve3zrd
{

	if [ -d /home/pi-star/Nextion_Temp ]; then
  		sudo rm -R /home/pi-star/Nextion_Temp
	fi
	if [ -d /usr/local/etc/Nextion_Support ]; then
  		sudo rm  /usr/local/etc/Nextion_Support/*
	else
		sudo mkdir /usr/local/etc/Nextion_Support
	fi

	if [ -f /usr/local/etc/*.tft ]; then
  		sudo rm /usr/local/etc/*.tft
	fi
       
	sudo git clone --depth 1 https://github.com/TGIF-Network/NX4024K032 /home/pi-star/Nextion_Temp
	rsync /home/pi-star/Nextion_Temp/* /usr/local/etc/Nextion_Support/* 
	cp /home/pi-star/Nextion_Temp/NX* /usr/local/etc/

		echo "Getting Github repository: https://github.com/TGIF-Network/NX4024K032"

	
}


#### Start of Main Code

## Select User Screens

#Start Duration Timer
start=$(date +%s.%N)

model="$scn"
tft='.tft' 
#gz='.gz'
#Put Pi-Star file system in RW mode
sudo mount -o remount,rw / > /dev/null
sleep 1s

#Stop the cron service
sudo systemctl stop cron.service  > /dev/null
sudo chmod +x "$homedir"/Nextion_Temp/*.sh

sudo rsync -avqru "$homedir"/Scripts/stripped2.csv  /usr/local/etc/
sudo mount -o remount,rw / 
sudo wget https://database.radioid.net/static/user.csv -O /usr/local/etc/stripped.csv

if [ ! -f "/etc/Colors.ini" ]; then
  cp /home/pi-star/Nextion_Support/Colors.ini /etc/
fi

 FILE="/usr/local/etc/*.tft"
 if [ ! -f /usr/local/etc/*.tft ]; then
        # Copy failed
      	echo "No TFT File Available to Flash - Try Again"
	errtext="Missing tft File Parameter"
	exitcode
 fi

sudo systemctl start cron.service  > /dev/null

duration=$(echo "$(date +%s.%N) - $start" | bc)
execution_time=`printf "%.2f seconds" $duration`


txt="$calltxt Scripts Loaded: $execution_time"
#whiptail --title "$title" --msgbox "$txt" 8 90
dialog --title "  $title  " --ascii-lines --msgbox "$txt" 8 78

echo -e '\e[1;40m'

if [ -z "$1" ]; then
	clear
fi

sudo mount -o remount,ro /
