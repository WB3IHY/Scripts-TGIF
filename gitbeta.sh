#!/bin/bash
#################################################################
#  Nextion TFT Support for the  Nextion 3.5 Inch Screen		#
#  Gets all Scripts and support files from github       	#
#  and copies them into the Nextion_Support directory   	#
#  and copies the NX??? tft file into /usr/local/etc    	#
#  and returns a script duration time to the Screen 		#
#  as a script completion flag. VE3ZRD Version			#
#								#
#  VE3RD                                     2025-03-11  	#
#################################################################
# Use screen model from command $1
# Valid Screen Names for VE3ZRD - NX3224K024, NX4832K935
sudo /home/pi-star/Scripts/gitcopy.sh NX4832K035 Beta



