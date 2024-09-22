#!/bin/bash

echo -e "\nInitiating install-workstation.sh!"
echo -e "\nSystem will ask for BECOME password. This is your sudo password!\n"

ansible-playbook -i localhost, day0-workstation.yml --connection=local -K

echo "Ansible playbook day0-workstation.yml complete!"
echo -e "\n\nSystem will reboot in 30s..."
echo "Press Ctrl+c to abort!"

sleep 30s

sudo reboot
