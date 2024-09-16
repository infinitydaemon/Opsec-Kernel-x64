#!/bin/bash

# CWD Kernel Build Script Rev 2
# 
# Important Notice:
#
# 1. Use at Your Own Risk:
#    This script is provided "as-is," without any express or implied warranties
#    or guarantees. Use it at your own risk. The author(s) are not responsible
#    for any damage, data loss, or other issues that may arise from the use of
#    this script.
#
# 2. No Warranty:
#    This script is provided without any warranty of any kind, either express or
#    implied, including but not limited to the implied warranties of
#    merchantability, fitness for a particular purpose, or non-infringement. The
#    entire risk as to the quality and performance of the script is with you.
#
# 3. Backup Your Data:
#    Before running this script, ensure you have backed up all important data.
#    The use of this script may result in data loss or corruption, and the
#    author(s) will not be held responsible for any such incidents.
#
# 4. Compatibility and Testing:
#    This script may not be compatible with all systems or configurations. Test
#    thoroughly in a safe environment before using it on a production system.

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to prompt the user
function prompt_user() {
    echo -e "${YELLOW}Are you sure you want to run the CWD build script for 0KN Server? (yes/no)${NC}"
    read -r response
    if [[ "$response" != "yes" ]]; then
        echo -e "${RED}Aborting.${NC}"
        exit 1
    fi
}

# Run the prompt
prompt_user

# Update and install necessary packages
echo -e "${BLUE}Installing necessary packages...${NC}"
sudo apt update
sudo apt install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev fakeroot dwarves

# Clone the repository
echo -e "${BLUE}Cloning the kernel repository...${NC}"
git clone https://github.com/infinitydaemon/OpSec-Kernel-x64.git

# Change directory to the cloned repository
echo -e "${BLUE}Changing directory to OpSec-Kernel-x64...${NC}"
cd OpSec-Kernel-x64 || { echo -e "${RED}Failed to change directory! Exiting.${NC}"; exit 1; }

# Configure the kernel
# echo -e "${BLUE}Configuring the kernel...${NC}"
# yes '' | make localmodconfig
#
# This step is only required if a new kernel configuration needs to be generated. 

# Disable SYSTEM_TRUSTED_KEYS and SYSTEM_REVOCATION_KEYS
echo -e "${BLUE}Disabling SYSTEM_TRUSTED_KEYS and SYSTEM_REVOCATION_KEYS...${NC}"
scripts/config --disable SYSTEM_TRUSTED_KEYS
scripts/config --disable SYSTEM_REVOCATION_KEYS
scripts/config --set-str CONFIG_SYSTEM_TRUSTED_KEYS ""
scripts/config --set-str CONFIG_SYSTEM_REVOCATION_KEYS ""

# Download the kernel config
echo -e "${GREEN}Downloading kernel config...${NC}"
curl -o .config https://raw.githubusercontent.com/infinitydaemon/OpSec-Kernel-x64/main/config/config-6.10.11-CWDSYSTEMS_0KN-Server

# Set a static build time stamp based on our last kernel source and build configuration.
# Use hexdump -C /path/to/kernel/vmlinuz | grep "2024-09-09" to verify the time stamp.
# Static time stamp will be updated when kernel source gets update.
export KBUILD_BUILD_TIMESTAMP="2024-09-09"

# Compile the kernel with 2 threads. Only exceed this if your system bus is strong and fast.
# Running more than 2 threads on a busy system bus will cause build failure due to write and fetch.
# Adjust the number of threads to meet your specs if you are building on a VPS
echo -e "${RED}Compiling the kernel...${NC}"
yes '' | fakeroot make -j2

# Install the kernel modules and kernel
echo -e "${RED}Installing kernel modules...${NC}"
sudo make modules_install
echo -e "${RED}Installing the kernel...${NC}"
sudo make install

# Prompt for reboot
echo -e "${YELLOW}Do you want to reboot the system to activate The Crawling Serpent for 0KN Server? (yes/no)${NC}"
read -r reboot_response
if [[ "$reboot_response" == "yes" ]]; then
    echo -e "${GREEN}Rebooting the system...${NC}"
    sudo reboot
else
    echo -e "${GREEN}You can reboot the system later to activate The Crawling Serpent.${NC}"
fi
