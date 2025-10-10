#!/usr/bin/env bash
#
# setup-dev-sbox.sh
# Debian 12 Dev Server Bootstrap Script
# Author: Morteck
# Description: Sets up a full development environment on a fresh Debian 12 install.

set -e

# === CONFIGURATION ===
NEW_USER="devuser"
USER_PASSWORD="changeme"
TIMEZONE="UTC"
INSTALL_DB="yes" # yes/no
INSTALL_PHP="yes" # yes/no

# === COLORS ===
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

log() {
  echo -e "${GREEN}[+]${RESET} $1"
}

warn() {
  echo -e "${YELLOW}[!]${RESET} $1"
}

error() {
  echo -e "${RED}[x]${RESET} $1"
  exit 1
}

# === STEP 1: System Prep ===
log "Updating system packages..."
sudo apt update && sudo apt upgrade -y

log "Setting timezone to $TIMEZONE..."
sudo timedatectl set-timezone "$TIMEZONE"

# === STEP 2: User Setup ===
if ! id "$NEW_USER" &>/dev/null; then
  log "Creating user: $NEW_USER"
  sudo adduser --disabled-password --gecos "" "$NEW_USER"
  echo "$NEW_USER:$USER_PASSWORD" | sudo chpasswd
  sudo usermod -aG sudo "$NEW_USER"
else
  warn "User '$NEW_USER' already exists. Skipping creation."
fi

# === STEP 3: Firewall ===
log "Configuring UFW..."
sudo apt install -y ufw
sudo ufw allow OpenSSH
sudo ufw --force enable

# === STEP 4: Essentials ===
log "Installing development essentials..."
sudo apt install -y build-essential git curl wget nano unzip htop tmux jq tree net-tools ca-certificates apt-transport-https gnupg lsb-release software-properties-common

# === STEP 5: Docker & Compose ===
log "Installing Docker & Docker Compose..."
sudo apt install -y docker.io docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker "$NEW_USER"

# === STEP 6: Python ===
log "Installing Python..."
sudo apt install -y python3 python3-pip python3-venv

# === STEP 7: Node.js ===
log "Installing Node.js 20.x..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# === STEP 8: PHP (optional) ===
if [ "$INSTALL_PHP" = "yes" ]; then
  log "Installing PHP..."
  sudo apt install -y php php-cli php-mbstring php-xml php-curl php-zip
else
  warn "Skipping PHP installation."
fi

# === STEP 9: Databases (optional) ===
if [ "$INSTALL_DB" = "yes" ]; then
  log "Installing MariaDB & PostgreSQL..."
  sudo apt install -y mariadb-server mariadb-client postgresql postgresql-contrib
  sudo systemctl enable --now mariadb postgresql
else
  warn "Skipping database setup."
fi

# === STEP 10: Directory Structure ===
log "Creating project directories..."
sudo -u "$NEW_USER" mkdir -p /home/"$NEW_USER"/projects/{web,api,services}
sudo chown -R "$NEW_USER":"$NEW_USER" /home/"$NEW_USER"/projects

# === STEP 11: Nginx (optional reverse proxy) ===
log "Installing Nginx..."
sudo apt install -y nginx
sudo systemctl enable --now nginx

# === STEP 12: Final Notes ===
log "Setup complete!"
echo -e "\n${GREEN}Dev Sandbox Setup Complete.${RESET}"
echo "User: $NEW_USER"
echo "Password: $USER_PASSWORD"
echo "Docker version: $(docker --version)"
echo "Node version: $(node -v)"
echo "Python version: $(python3 --version)"
echo "Projects directory: /home/$NEW_USER/projects"
echo -e "\n${YELLOW}Remember to:${RESET}"
echo "1. Run 'sudo visudo' to ensure your user has sudo privileges."
echo "2. Set up SSH key authentication for $NEW_USER."
echo "3. Change the default password immediately: 'passwd $NEW_USER'."
