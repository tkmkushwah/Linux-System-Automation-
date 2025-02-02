#!/bin/bash

# Text color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'  # Reset color to default

echo "hello, world!"

#File and Directory Operations
echo "creating files and directiories"
touch file1.txt file2.txt
echo "this is file1" >file1.txt
mkdir test_dir
echo "this is a directory" > test_dir/info.txt

#system info 
echo -e "${RED}Gathering system information.${RESET}"
echo "CPU info:"
lscpu
echo -e "${RED}Memory Usage:${RESET}"
free -h
echo -e "${RED}disc usage:${RESET}"
df -h
echo -e "${RED}system uptime${RESET}"
uptime

#==============User Management===============
echo -e "${GREEN}enter username to create a new user:${RESET}"
read username
# check if user already exist
if id "$username" &>/dev/null; then
    echo "User $username already exists!"
else
    sudo useradd $username
    sudo passwd  $username

    #check if group already exists
    if getent group "${username}_group" &>/dev/null; then
      echo "Group ${username}_group already exsists"
    else
    #create group
    sudo groupadd ${username}_group
    fi

sudo usermod -a -G ${username}_group $username
echo "User $username created and added to group ${username}_group."

fi
