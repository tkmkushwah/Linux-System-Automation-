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


# Function for port scanning using ss
port_scan() {
  echo -e "${YELLOW}Scanning for open ports...${RESET}"
  ss -tuln  # Displays listening ports and services
}

# Function for traceroute to a remote server
traceroute_to_server() {
  echo -e "${YELLOW}Tracing route to $1...${RESET}"
   if command -v traceroute &> /dev/null; then
   traceroute $1
    else -e "${YELLOW}Error: tracerout command not found please install${RESET}"
   fi
}

# Function for DNS lookup
dns_lookup() {
  echo -e "${YELLOW}Performing DNS lookup for $1...${RESET}"
  if command -v nslookup &> /dev/null; then
  nslookup $1
else
  echo "Error: nslookup command not found. Please install dnsutils or bind-utils."
fi
}


check_network_interface(){
echo -e "${GREEN}checking network interface${RESET}"
      ip a
}

#function to config a static IP address
configure_static_ip(){
echo -e "${GREEN}configuring static IP${RESET}"
# Remove existing IP (if assigned)
  sudo ip addr del 192.168.1.100/24 dev eth0 2>/dev/null

# Assign the new static IP
sudo ip addr add 192.168.1.100/24 dev eth0
sudo ip link set eth0 up  || "failed to bring up interface"
}
#function to ping server
ping_server(){
echo -e "${GREEN}Pinging server $1....${RESET}"
ping -c 4 $1
}
check_network_interface
configure_static_ip
ping_server 192.168.1.100
port_scan
traceroute_to_server "google.com"
dns_lookup "gmail.com"
}

#=======================Managing firewall rules========================
managing_firewall(){

# Function to check firewall status
check_firewall_status() {
  echo -e "${YELLOW}Checking firewall status...${RESET}"
  sudo ufw status
}

# Function to allow a port (e.g., HTTP)
allow_http_port() {
  echo -e "${YELLOW}Allowing HTTP (Port 80)...${RESET}"
  sudo ufw allow 80/tcp      # Allow HTTP
  sudo ufw allow 443  # Allow HTTPS
}

# Function to deny a port (e.g., FTP)
deny_ftp_port() {
  echo -e "${YELLOW} Denying FTP (Port 21)...${RESET}"
  sudo ufw deny 21/tcp
}

# Main script execution
check_firewall_status
allow_http_port
deny_ftp_port
check_firewall_status
}


#=============================VPN Configuration====================
# Function to connect to VPN
connect_vpn() {
  echo "Connecting to VPN..."
 if command -v openvpn &> /dev/null; then
  sudo apt update && sudo apt install openvpn -y
  sudo openvpn --config /src/openvpn/config.ovpn &
  fi
}

# Function to check VPN status
check_vpn_status() {
  echo "Checking VPN status..."
#ps aux:
#This command lists all the processes currently running on the system
#The | (pipe) sends the output of ps aux to grep, which searches for the string "openvpn" in the process list
#> /dev/null:redirects the output of the grep command to /dev/null, which essentially discards it.  
if ps aux | grep "openvpn" > /dev/null; then
    echo "VPN is connected."
  else
    echo "VPN is not connected."
  fi
}

# Main script execution
connect_vpn
sleep 5  # Allow time for VPN connection
check_vpn_status

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
echo "9. Manage Firewall"
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
9)
managing_firewall
;;
*)
echo "invalig choice. exiting"
exit 1
;;
esac
