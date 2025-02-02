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
#================Log Rotation====================
# Log Rotation
echo "Rotating log files..."
#find and remove all log file mtime>30 days
    sudo find /var/log/*.log -mtime +30  -exec echo -e "${RED}would delete${RESET}:" {} \;
# name log uniquely file and add all files to archive
sudo tar -czvf /var/log/logs_backup_$(date +%F).tar.gz -c /var/log/*.log
echo "log rotation and backup completed successfully!"

#===================Automated Backup==============
echo "Automating backup of directories..."
mkdir -p /home/user/data/
sudo chown -R $USER:$USER /home/user/data/
source_dir="/home/user/data"
backup_dir="/home/user/backups"
timestamp=$(date +%F)
sudo mkdir -p $backup_dir/$timestamp
cp -r $source_dir/* $backup_dir/$timestamp/

#===================System health alert============
# Health Monitoring
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
DISK_USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')

if [ $(echo "$CPU_USAGE > 2" | bc) -eq 1 ]; then
    echo "CPU Usage is above 80%" 
fi
if [ $(echo "$MEMORY_USAGE > 1" | bc) -eq 1 ]; then
    echo "Memory Usage is above 80%"
fi
if [ $DISK_USAGE -gt 9 ]; then
    echo "Disk Usage is above 90%"
fi
