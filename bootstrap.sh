#!/bin/bash

########################################################################
# First-run bootstrap script for Debian/Ubuntu VMs                     #
# Written by Mikael Todd                                               #
# Github: https://github.com/morteck                                   #
# Copyright 2025 Mikael Todd                                           #
# Licensed under the MIT License (https://opensource.org/licenses/MIT) #
########################################################################

set -euo pipefail

###############################################################################
# SANITY CHECKS
###############################################################################
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi

# Log output for debugging
exec > >(tee -i /var/log/bootstrap.log) 2>&1

###############################################################################
# CONFIG
# Edit the PASS with your own custom password
###############################################################################
USER="adminuser"
PASS="<your password here>"
SSH_KEY=""       # Optional: add your public key here
HOSTNAME=""      # Optional: set hostname here
PACKAGES=(tmux htop neofetch wget curl openssh-server apache2 ufw unattended-upgrades fail2ban)

###############################################################################
# HOSTNAME
###############################################################################
if [[ -n "$HOSTNAME" ]]; then
    echo "Setting hostname to $HOSTNAME"
    hostnamectl set-hostname "$HOSTNAME"
fi

###############################################################################
# SYSTEM UPDATE
###############################################################################
echo "Updating packages..."
apt update && apt -y upgrade && apt -y autoremove

###############################################################################
# INSTALL ESSENTIALS
###############################################################################
echo "Installing packages..."
apt -y install "${PACKAGES[@]}"

###############################################################################
# CREATE OR RESET ADMIN USER
###############################################################################
if ! id "$USER" &>/dev/null; then
    echo "Creating user $USER..."
    useradd -m -s /bin/bash "$USER"
    usermod -aG sudo,adm "$USER"
fi
echo "$USER:$PASS" | chpasswd
echo "Password for $USER set/reset"

###############################################################################
# SETUP SSH KEY FOR ADMIN USER (OPTIONAL)
###############################################################################
if [[ -n "$SSH_KEY" ]]; then
    echo "Adding SSH key for $USER"
    mkdir -p /home/$USER/.ssh
    echo "$SSH_KEY" >> /home/$USER/.ssh/authorized_keys
    chmod 700 /home/$USER/.ssh
    chmod 600 /home/$USER/.ssh/authorized_keys
    chown -R $USER:$USER /home/$USER/.ssh
fi

###############################################################################
# FIREWALL CONFIGURATION
###############################################################################
echo "Configuring UFW..."
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow http
ufw allow https
ufw --force enable

###############################################################################
# SECURITY UPDATES
###############################################################################
echo "Enabling unattended upgrades..."
dpkg-reconfigure --priority=low unattended-upgrades

###############################################################################
# FAIL2BAN
###############################################################################
echo "Starting Fail2Ban..."
systemctl enable --now fail2ban

###############################################################################
# NEOFETCH AT LOGIN
###############################################################################
grep -qxF "neofetch" /home/$USER/.bashrc || echo "neofetch" >> /home/$USER/.bashrc
chown $USER:$USER /home/$USER/.bashrc

###############################################################################
# FINAL MESSAGE
###############################################################################
echo "Bootstrap complete. Reboot recommended."
