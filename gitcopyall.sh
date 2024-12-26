#!/bin/bash
#################################################################
#  Nextion TFT Support for Nextion All TGIF Nextion Screens 	#
#  Gets all Scripts and support files from github      		#
#  and copies them into the Nextion_Support directory   	#
#  and copies the NX??? tft files into /usr/local/etc/    	#
#  and returns a script duration time to the Screen 		#
#  as a script completion flag					#
#								#
#  KF6S/VE3RD                               2020-05-12  	#
#################################################################

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

ghName=""
repo=""
scrn=""

who=$(whoami)
echo "This script is running as $who user"
sleep 2

run=""

errtext="This is a test"


ver="20220124"
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
ver=$(/usr/local/bin/NextionDriver -V | tr '\n' " " | cut -d " " -f4)
if [ "$ver" == "1.26" ] || [ "$ver" == "1.25A" ]; then
	 echo "Found Current NextionDriver Version $ver"
else
	echo "NextionDriver $ver Replaced with Version 1.25A Patched for M17"
	/home/pi-star/Scripts/NextionDriver4M17.sh
fi
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

function getfromgithub()
{
if [ -d "$homedir"/Nextion_Temp ]; then
  	sudo rm -R "$homedir"/Nextion_Temp
fi

 sudo git clone --depth 1 https://github.com/"$repo"/"$ghName" "$homedir"/Nextion_Temp

if [ -d "$homedir"/Nextion_Temp ]; then
        echo "$homedir"/Nextion_Temp/"$ghName" Downloaded
	echo "Download from Github Succesful!"
else
	echo "Download NOT Succesful!   Script Aborted!"
	exit
fi

}


#### Start of Main Code

## Select User Screens

result=(dialog --backtitle "Screen Selector - $calltxt" --ascii-lines --menu "Choose Your $calltxt Nextion Screen Model" 22 76 16)

options=(1 "3.5 Inch Nextion Screen - EA7KDO"
         2 "2.4 Inch Nextion Screen - EA7KDO"

	 3 "3.5 Inch Nextion Screen - VE3ZRD"
	 4 "3.2 Inch Nextion Screen - VE3ZRD"
	 5 "2.4 Inch Nextion Screen - VE3RD"

         6 " Abort - Exit Script")

choices=$("${result[@]}" "${options[@]}" 2>&1 >/dev/tty)

#errt="$?"
clear
echo "Choice = $choices"

if [ -z "$choices" ]; then
#if [ "$choices" != "1" ] || [ "$choices" != "2" ] || [ "$choices" != "3" ]; then
  errtext="Cancel Button Pressed"
  exitcode
fi

for choice in $choices
do
    case $choice in
        1)
            echo "EA7KDO 3.5 Inch Nextion Screen Selected"
		scn="NX4832K035"
		repo="TGIF-Network"
		ghName="NX4832K035-KDO"

            ;;
        2)
            echo "EA7KDO 2.4 Inch Nextion Screen Selected"
		scn="NX3224K024"
		repo="TGIF-Network"
		ghName="NX3224K024-KDO"
            ;;
        3)
            echo "VE3ZRD 3.5 Inch Nextion Screen Selected"
		scn="NX4832K035"
		repo="TGIF-Network"
		ghName="NX4832K035-ZRD"
            ;;
        4)
            echo "VE3ZRD 3.2 Inch Nextion Screen Selected"
		scn="NX4024K032"
		repo="TGIF-Network"
 		ghName="NX4024K032"
            ;;
        5)
            echo "VE3RD 2.4 Inch Nextion Screen Selected"
		scn="NX3224K024"
		repo="TGIF-Network"
 		ghName="NX3224K024-ZRD"
            ;;

        6)
            echo "Abort - Exit Script"
		errtext="Abort Selected"
		exitcode
            ;;
    esac
done


echo " End Processing Parameters  - $scn $calltxt"

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

  # Get Nextion Screen/Scripts and support files from github
  # Get EA7KDO File Set

if [ ! -d /usr/local/etc/Nextion_Support ]; then
	sudo mkdir /usr/local/etc/Nextion_Support
else
       sudo rm -R /usr/local/etc/Nextion_Support
	sudo mkdir /usr/local/etc/Nextion_Support
fi


getfromgithub

sleep 3

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

sleep 3

model="$scn"
    echo "Remove Existing $model$tft and copy in the new one"
txtn="Remove Existing $model$tft and copy in the new one"
txt="$txt""$txtn"


files=(/usr/local/etc/*.tft)

if [ -e "${files[0]}" ];
then
	sudo rm /usr/local/etc/*.tft
fi

sudo cp "$homedir"/Nextion_Temp/"$model$tft" /usr/local/etc/


 FILE=/usr/local/etc/"$model$tft"
 if [ ! -f "$FILE" ]; then
        # Copy failed
      	echo "No TFT File Available to Flash - Try Again"
	errtext="Missing tft File Parameter"
	exitcode
 fi

sleep 3

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
