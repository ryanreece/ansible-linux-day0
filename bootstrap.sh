#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

if [ ! -f /etc/os-release ]; then
    echo -e "${RED}Error: Unable to determine OS. /etc/os-release not found."
    exit 1
fi

. /etc/os-release
 
echo -e "${BLUE}Bootstrapping ansible-linux-day0...${NC}"

case $ID in
    ubuntu)
        sudo apt update
        sudo apt install software-properties-common
        sudo add-apt-repository --yes --update ppa:ansible/ansible
        sudo apt install --yes ansible
        ;;
    rocky)
        sudo dnf install ansible
        ;;
    *)
        echo -e "${RED}Error: ${ID} not supported..."
        exit 1
esac

ansible-galaxy install -r roles/requirements.yml

echo -e "\n${GREEN}ansible-linux-day0 bootstrap complete!"
echo -e "\n${NC}Use the following command to run on workstations:"
echo -e "${BLUE} ./install-workstation.sh\n\n"
