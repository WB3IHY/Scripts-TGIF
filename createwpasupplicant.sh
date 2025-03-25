#!/bin/bash
#    ssid=\"$SSID\"

# Script to create a wpa_supplicant configuration file

# Define the output file location
#CONFIG_FILE="/etc/wpa_supplicant/wpa_supplicant.conf"
CONFIG_FILE="/home/pi-star/wpa_supplicant.conf"
#
# Check if script is running with sudo/root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo or as root"
    exit 1
fi

# Prompt for network details
echo "Creating a new WPA Supplicant configuration file"
echo "---------------------------------------------"
read -p "Enter WiFi SSID: " SSID
read -s -p "Enter WiFi Password: " PASSWORD
echo "" # New line after password input

# Create the configuration file content
ctrl_interface="DIR=/var/run/wpa_supplicant GROUP=netdev/
update_config=1
ap_scan=1
fast_reauth=1
country=US

network={
    ssid='${SSID}'
    psk='${PASSWORD}'
    key_mgmt=WPA-PSK
    }
"

# Write to the configuration file
echo "$CONFIG_CONTENT" > "$CONFIG_FILE"

# Set appropriate permissions
chmod 600 "$CONFIG_FILE"

if [ "$1" == "install" ]; then
	cp /home/pi-star/wpa_supplicant.conf /etc/wpa_supplicant/
	echo "wpa_supplicant copied to /etc/wpa_supplicant/" 
fi

echo "---------------------------------------------"
echo "WPA Supplicant configuration file created at $CONFIG_FILE"
echo "To install copy to /etc/wpa_supplicant/"
echo "or"
echo "Re-run this scripts with the parameter install "
echo "./createwpasupplicant install"
