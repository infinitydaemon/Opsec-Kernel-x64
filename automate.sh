#!/bin/bash

# Label for the automation process
echo "=== ZerOS Automated build and setup for hosted VPS ==="

# Run build-server.sh to download and build The Crawling Serpent Kernel
echo "Running build-server.sh: Building and installing The Crawling Serpent Kernel..."
./build-server.sh

# Check for errors in the previous step
if [ $? -ne 0 ]; then
    echo "Error in build-server.sh. Exiting..."
    exit 1
fi

# Run stage2-hardening.sh to harden the TCP/IP stack and apply security settings
echo "Running stage2-hardening.sh: Hardening TCP/IP stack and applying security settings..."
./stage2-hardening.sh

# Check for errors in the previous step
if [ $? -ne 0 ]; then
    echo "Error in stage2-hardening.sh. Exiting..."
    exit 1
fi

# Run update-issue.sh to enable ZerOS branding and update files
echo "Running update-issue.sh: Enabling ZerOS branding and updating files..."
./update-issue.sh

# Check for errors in the previous step
if [ $? -ne 0 ]; then
    echo "Error in update-issue.sh. Exiting..."
    exit 1
fi

# Run update-motd.sh to update the motd file
echo "Running update-motd.sh: Updating motd file..."
./update-motd.sh

# Check for errors in the previous step
if [ $? -ne 0 ]; then
    echo "Error in update-motd.sh. Exiting..."
    exit 1
fi

# Completion message
echo "=== ZerOS Automated build and setup completed successfully ==="
