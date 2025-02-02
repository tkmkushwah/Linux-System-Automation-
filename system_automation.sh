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

