#!/bin/bash
sudo mount -o remount,rw /
# Function to encode a string using Base64
encode_string() {
    local input="$1"
    echo -n "$input" | base64
}
# Main script
echo "Please enter your pi-star password (ie raspberry):"
read user_input

# Check if input is empty
if [ -z "$user_input" ]; then
    user_input=raspberry
     echo "Using raspberry"
fi

# Encrypt (encode) the string
echo "Encrypting '$user_input'..."
encrypted=$(encode_string "$user_input")
echo "$encrypted" > /etc/pspass
echo "Password Encrypted and Stored"
#echo "Encrypted (Base64 encoded): $encrypted"

