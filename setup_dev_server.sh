#!/usr/bin/env bash
#
# Debian 12 Dev Server Bootstrap Script.
# Author: morteck
# Description: Sets up a complete development environment on a fresh Debian install.

set -e

# --- CONFIGURATION ---
NEW_USER="devuser"
USER_PASSWORD="changeme"
TIMEZONE="UTC"
INSTALL_DB="yes"   # yes/no
INSTALL_PHP="yes"  # yes/no

# --- COLORS ---
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

# --- LOGGING FUNCTIONS ---
log()   { echo -e "${GREEN}[+]${RESET} $1"; }
warn()  { echo -e "${YELLOW}[!]${RESET} $1"; }
error() { echo -e "${RED}[x]${RESET} $1" && exit 1; }

# --- ROOT CHECK ---
if [ "$EUID" -ne 0 ]; then
  error "Please run this script as root."
fi

# --- STEP 1: SYSTEM PREP ---
log "Updating system packages..." &&
apt update && apt upgrade -y &&
timedatectl set-timezone "$TIMEZONE"

# --- STEP 2: USER SETUP ---
if ! id "$NEW_USER" &>/dev/null; then
  log "Creating user: $NEW_USER" &&
  adduser --disabled-password --gecos "" "$NEW_USER" &&
  echo "$NEW_USER:$USER_PASSWORD" | chpasswd &&
  usermod -aG sudo "$NEW_USER"
else
  warn "User '$NEW_USER' already exists. Skipping creation."
fi

# --- STEP 3: FIREWALL ---
log "Configuring UFW..." &&
apt install -y ufw &&
ufw allow OpenSSH &&
ufw --force enable

# --- STEP 4: ESSENTIALS ---
log "Installing development essentials..." &&
apt install -y build-essential git curl wget nano unzip htop tmux jq tree net-tools \
ca-certificates apt-transport-https gnupg lsb-release software-properties-common

# --- STEP 5: DOCKER ---
log "Installing Docker & Docker Compose..." &&
apt install -y docker.io docker-compose &&
systemctl enable --now docker &&
usermod -aG docker "$NEW_USER"

# --- STEP 6: PYTHON ---
log "Installing Python..." &&
apt install -y python3 python3-pip python3-venv

# --- STEP 7: NODE.JS ---
log "Installing Node.js 20.x..." &&
curl -fsSL https://deb.nodesource.com/setup_20.x | bash - &&
apt install -y nodejs

# --- STEP 8: PHP (optional) ---
if [ "$INSTALL_PHP" = "yes" ]; then
  log "Installing PHP..." &&
  apt install -y php php-cli php-mbstring php-xml php-curl php-zip
else
  warn "Skipping PHP installation."
fi

# --- STEP 9: DATABASES (optional) ---
if [ "$INSTALL_DB" = "yes" ]; then
  log "Installing MariaDB & PostgreSQL..." &&
  apt install -y mariadb-server mariadb-client postgresql postgresql-contrib &&
  systemctl enable
