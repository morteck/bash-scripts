#!/bin/bash
#
# Automates connecting to a remote SSH server and optionally executes a command.

set -e

# --- CONFIGURATION ---
SERVER_IP="your_server_ip"
SSH_PORT="your_ssh_port"
SSH_USER="your_ssh_username"
PRIVATE_KEY="path/to/your/private/key"
REMOTE_COMMAND="echo 'Hello, SSH automation!'"

# --- COLORS ---
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

# --- LOGGING FUNCTIONS ---
log()   { echo -e "${GREEN}[+]${RESET} $1"; }
error() { echo -e "${RED}[x]${RESET} $1" && exit 1; }

# --- CHECKS ---
if [ ! -f "$PRIVATE_KEY" ]; then
  error "Private key not found at: $PRIVATE_KEY"
fi

if [ -z "$SERVER_IP" ] || [ -z "$SSH_PORT" ] || [ -z "$SSH_USER" ]; then
  error "Missing SSH configuration. Please verify all variables are set."
fi

# --- SSH CONNECTION ---
log "Connecting to $SSH_USER@$SERVER_IP on port $SSH_PORT..."
ssh -i "$PRIVATE_KEY" -p "$SSH_PORT" "$SSH_USER@$SERVER_IP" "$REMOTE_COMMAND"
log "SSH session complete."
