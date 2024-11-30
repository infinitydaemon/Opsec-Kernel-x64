#!/bin/bash

# Variables
MOTD_FILE="/etc/motd"
GITHUB_URL="https://raw.githubusercontent.com/infinitydaemon/Opsec-Kernel-x64/refs/heads/main/config/motd"
MOTD_DIR="/etc/update-motd.d"

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi

# Remove all update-motd scripts
if [ -d "$MOTD_DIR" ]; then
    echo "Removing all existing update-motd scripts..."
    rm -rf ${MOTD_DIR}/*
    echo "All update-motd scripts removed."
fi

# Download the new MOTD content from GitHub
echo "Downloading new MOTD content from $GITHUB_URL..."
if curl -fsSL "$GITHUB_URL" -o "$MOTD_FILE"; then
    echo "New MOTD content downloaded and applied successfully to $MOTD_FILE."
else
    echo "Failed to download the MOTD from GitHub."
    exit 1
fi

# Set proper permissions
chmod 644 "$MOTD_FILE"
echo "Permissions set to 644 for $MOTD_FILE."

echo "MOTD has been updated. Changes will be visible upon the next login."

exit 0
