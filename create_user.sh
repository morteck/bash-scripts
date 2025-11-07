#!/bin/bash
# User Creation Script
# --------------------
# This Bash script interactively creates a new system user. It prompts for the username,
# full name, and an optional initial group (defaults to the username if left blank).
# The script ensures it runs with root privileges, creates the user with a home directory,
# and prompts to set a password.

# === Privilege Check ===
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run this script as root." >&2
    exit 1
fi

# === Helper: Create a new user ===
create_user() {
    read -rp "Enter username: " username
    read -rp "Enter full name: " full_name
    read -rp "Enter initial group (leave blank for default): " initial_group

    # Default group = username if not specified
    if [ -z "$initial_group" ]; then
        initial_group="$username"
    fi

    # Create user
    if useradd -m -c "$full_name" -g "$initial_group" "$username" 2>/dev/null; then
        echo "✅ User '$username' created successfully."
    else
        echo "❌ Failed to create user '$username' (check if group or user already exists)." >&2
        return 1
    fi

    # Set user password
    passwd "$username"
}

# === Main Execution ===
echo "=== User Creation Script ==="
create_user
