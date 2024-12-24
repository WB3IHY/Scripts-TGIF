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
# Valid Screen Names for VE3ZRD NX4024K032

#if [[ $EUID -ne 0 ]]; then
#	clear
#	echo ""
 #  	echo "This script must be run as root"
#	echo "Setting root user"
#	echo "Re-Start Script"
#	echo ""
#	sudo su
  # 	exit 1
#fi
p1=$(pwd) ; cd .. ; homedir=$(pwd) ; cd "$p1"

who=$(whoami)
echo "This script is running as $who user"
sleep 2

run=""

errtext="This is a test"


parm1="$1"
parm2="$2"
ver="20240121"
declare -i tst

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

if [ -z "$1" ]; then
	clear
fi

function UpdateNextionDriver
{
/home/pi-star/Scripts/NextionDriver4M17.sh
}

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
	tst=0
#	echo "Function VE3ZRD"
	calltxt="VE3ZRD"

if [ -d "$homedir"/Nextion_Temp ]; then
  	sudo rm -R "$homedir"/Nextion_Temp
fi

    	if [ "$scn" == "NX4024K032" ]; then
#	  	sudo git clone --depth 1 https://github.com/TGIF-Network/NX4024K032 "$homedir"/Nextion_Temp
	  	sudo git clone --depth 1 https://github.com/TGIF-Network/N4024K032 "$homedir"/Nextion_Temp
		# https://github.com/TGIF-Network/N4024K032
		tst=1
		echo "Getting Github repository: https://github.com/TGIF-Network/NX4024K032"
	fi     

	
}

function getcall
{
#Set Screen Author
calltxt="VE3ZRD"
}

#### Start of Main Code

## Select User Screens
getcall
S1=""
S2=""
if [ -f "/usr/local/etc/NX4024K032.tft" ]; then
   S1="NX4024K032"
   S1A=" Available     "
else 
   S1="NX4014K032"
   S1A=" Not Available - But will Download it "
fi


scn="NX4024K032"

echo "$scn $calltxt"


#echo " End Processing Parameters  - $scn $calltxt"

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


#Test for "$homedir"/Nextion_Temp and remove it, if it exists

if [ -d "$homedir"/Nextion_Temp ]; then
  	sudo rm -R "$homedir"/Nextion_Temp
fi

  # Get Nextion Screen/Scripts and support files from github
  # Get EA7KDO File Set

	echo "getting Screens for $calltxt"
	getve3zrd
 

if [ ! -d /usr/local/etc/Nextion_Support ]; then
	sudo mkdir /usr/local/etc/Nextion_Support
else
       sudo rm -R /usr/local/etc/Nextion_Support
	sudo mkdir /usr/local/etc/Nextion_Support
fi

sudo chmod +x "$homedir"/Nextion_Temp/*.sh
sudo rsync -avqru "$homedir"/Nextion_Temp/* /usr/local/etc/Nextion_Support/ --exclude=NX* --exclude=profiles.txt

sudo rsync -avqru "$homedir"/Scripts/stripped2.csv  /usr/local/etc/
sudo mount -o remount,rw / 
sudo wget https://database.radioid.net/static/user.csv -O /usr/local/etc/stripped.csv

if [ -f "$homedir"/Nextion_Temp/profiles.txt ]; then
	if [ ! -f /usr/local/etc/Nextion_Support/profiles.txt ]; then
        	if [ "$fb" ]; then
			txtn= "Replacing Missing Profiles.txt"
			txt="$txt\n""$txtn"
        	fi
        	sudo cp  "$homedir"/Nextion_Temp/profiles.txt /usr/local/etc/Nextion_Support/
	fi
fi

model="$scn"
    echo "Remove Existing $model$tft and copy in the new one"
txtn="Remove Existing $model$tft and copy in the new one"
txt="$txt""$txtn"

if [ -f /usr/local/etc/"$model$tft" ]; then
	sudo rm /usr/local/etc/NX*K*.tft
fi
sudo cp "$homedir"/Nextion_Temp/"$model$tft" /usr/local/etc/

if [ ! -f "/etc/Colors.ini" ]; then
  cp /home/pi-star/Nextion_Support/Colors.ini /etc/
fi

 FILE=/usr/local/etc/"$model$tft"
 if [ ! -f "$FILE" ]; then
        # Copy failed
      	echo "No TFT File Available to Flash - Try Again"
	errtext="Missing tft File Parameter"
	exitcode
 fi

sudo systemctl start cron.service  > /dev/null

UpdateNextionDriver

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
