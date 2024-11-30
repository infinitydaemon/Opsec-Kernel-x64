#!/bin/bash

# Variables
BRAND_NAME="ZerOS"
MOTD_URL="https://raw.githubusercontent.com/infinitydaemon/Opsec-Kernel-x64/refs/heads/main/update-motd.sh"
ASCII_LOGO="
 ZZZZZ   EEEEE   RRRR     OOO    SSSS
    Z    E       R   R   O   O  S
   Z     EEEE    RRRR    O   O   SSS
  Z      E       R  R    O   O      S
 ZZZZZ   EEEEE   R   R    OOO    SSSS
"

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root."
    exit 1
fi

echo "Starting branding for $BRAND_NAME..."

# Step 1: Customize MOTD
echo "Customizing the MOTD..."
MOTD_FILE="/etc/motd"
if curl -fsSL "$MOTD_URL" -o "$MOTD_FILE"; then
    chmod 644 "$MOTD_FILE"
    echo "MOTD updated from $MOTD_URL."
else
    echo "Failed to download MOTD. Using default branding."
    echo "$ASCII_LOGO" > "$MOTD_FILE"
fi

# Step 2: Customize GRUB Bootloader
GRUB_CFG="/boot/grub/grub.cfg"
echo "Customizing GRUB bootloader..."
if [ -f "$GRUB_CFG" ]; then
    cp "$GRUB_CFG" "${GRUB_CFG}.bak" # Backup
    sed -i "/### BEGIN \/etc\/grub.d\/00_header ###/a \
# Custom ASCII Logo\n\
cat <<EOF\n\
$ASCII_LOGO\n\
EOF\n" "$GRUB_CFG"
    echo "GRUB branding applied. Backup saved as grub.cfg.bak."
else
    echo "GRUB configuration not found. Skipping GRUB branding."
fi

# Step 3: Update /etc/issue for SSH Welcome Message
echo "Customizing SSH login banner..."
echo "$ASCII_LOGO" > /etc/issue
echo "$BRAND_NAME Server - Unauthorized access is prohibited." >> /etc/issue

# Step 4: Create a Branded Login Shell Profile
PROFILE_FILE="/etc/profile.d/brand.sh"
echo "Creating branded shell profile..."
cat <<EOF > "$PROFILE_FILE"
#!/bin/bash
echo "$ASCII_LOGO"
echo "Welcome to $BRAND_NAME Server!"
EOF
chmod +x "$PROFILE_FILE"

# Step 5: Set a Custom Hostname
echo "Setting custom hostname..."
hostnamectl set-hostname "${BRAND_NAME,,}-server"
echo "127.0.1.1 ${BRAND_NAME,,}-server" >> /etc/hosts

# Step 6: Update the TTY Splash Screen
SPLASH_FILE="/etc/issue.net"
echo "Customizing TTY splash screen..."
echo "$ASCII_LOGO" > "$SPLASH_FILE"
echo "$BRAND_NAME Server" >> "$SPLASH_FILE"

# Step 7: Finalizing
echo "Updating system configurations..."
sudo update-grub >/dev/null 2>&1 || echo "GRUB update skipped."

echo "Branding completed successfully for $BRAND_NAME!"
echo "Please reboot the server to apply all changes."
