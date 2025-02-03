#!/bin/bash

# Text color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'  # Reset color to default

echo "hello, world!"

#File and Directory Operations
create_files(){

echo "creating files and directiories"
touch file1.txt file2.txt
echo "this is file1" >file1.txt
mkdir test_dir
echo "this is a directory" > test_dir/info.txt
}

#system info
gather_system_info(){
echo -e "${RED}Gathering system information.${RESET}"
echo "CPU info:"
lscpu
echo -e "${RED}Memory Usage:${RESET}"
free -h
echo -e "${RED}disc usage:${RESET}"
df -h
echo -e "${RED}system uptime${RESET}"
uptime
}
#==============User Management===============
create_user(){
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
}
#================Log Rotation====================

log_rotation(){
# Log Rotation
echo "Rotating log files..."
#find and remove all log file mtime>30 days
    sudo find /var/log/*.log -mtime +30  -exec echo -e "${RED}would delete${RESET}:" {} \;
# name log uniquely file and add all files to archive
sudo tar -czvf /var/log/logs_backup_$(date +%F).tar.gz -c /var/log/*.log
echo "log rotation and backup completed successfully!"
}
#===================Automated Backup==============
automated_backup(){
echo "Automating backup of directories..."
mkdir -p /home/user/data/
sudo chown -R $USER:$USER /home/user/data/
source_dir="/home/user/data"
backup_dir="/home/user/backups"
timestamp=$(date +%F)
sudo mkdir -p $backup_dir/$timestamp
cp -r $source_dir/* $backup_dir/$timestamp/
}
#===================System health alert============
system_health(){
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
}
#=====================Network monitoring=======================
network_monitoring(){

check_network_interface(){
echo -e "${GREEN}checking network interface${RESET}"
      ip a
}

#function to config a static IP address
configure_static_ip(){
echo "configuring static IP"
# Remove existing IP (if assigned)
  sudo ip addr del 192.168.1.100/24 dev eth0 2>/dev/null

# Assign the new static IP
sudo ip addr add 192.168.1.100/24 dev eth0
sudo ip link set eth0 up  || "failed to bring up interface"
}
#function to ping server
ping_server(){
echo "Pinging server $1...."
ping -c 4 $1
}
check_network_interface
configure_static_ip
ping_server 192.168.1.100
}
#main script execution
echo "choose an option:"
echo "1. Create files and directories"
echo "2. Gather system information"
echo "3. Create user"
echo "4. Log rotation"
echo "5. automated backup"
echo "6. system health"
echo "7. check network interface"
echo "8. Network monitoring"
read choice
case $choice in
1)
create_files
;;
2)
gather_system_info
;;
3)
create_user
;;
4)
log_rotation
;;
5)
#automated_backup
;;
6)
system_health
;;
7)
check_network_interface
;;
8)
network_monitoring
;;
*)
echo "invalig choice. exiting"
exit 1
;;
esac
