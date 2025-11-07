#!/bin/bash
# System Update Script
# --------------------
# This Bash script updates and upgrades all installed packages on a Debian-based system.
# It also removes obsolete dependencies and cleans up the local package cache.
# Designed for administrators who want a quick, reliable way to perform system maintenance.


# === Privilege Check ===
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run this script as root." >&2
    exit 1
fi

# === System Update & Maintenance ===
echo "=== Starting System Update ==="
apt update && apt upgrade -y

echo "=== Cleaning Up Unused Packages ==="
apt autoremove -y && apt clean

# === Completion Message ===
echo "✅ System updates completed successfully."
