#!/bin/bash
# This script is part of the Bash-Scripts project.
# Licensed under the GNU GPLv3. See LICENSE file for details.


# Check if the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

# Function to create a user
create_user() {
  read -p "Enter username: " username
  read -p "Enter full name: " full_name
  read -p "Enter initial group (leave blank for default): " initial_group

  # Set the initial group to the username if left blank
  if [ -z "$initial_group" ]; then
    initial_group="$username"
  fi

  # Create the user with useradd
  useradd -m -c "$full_name" -g "$initial_group" "$username"

  # Check if useradd was successful
  if [ $? -eq 0 ]; then
    echo "User $username created successfully."
  else
    echo "Failed to create user $username."
  fi

  # Set a password for the user
  passwd "$username"
}

# Main script
echo "User Creation Script"
create_user
