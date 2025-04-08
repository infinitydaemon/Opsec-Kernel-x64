#!/bin/bash
chmod +x *.sh
# Install Dialog dependency first
sudo apt install dialog
# Function to detect Linux distribution
detect_distribution() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    else
        DISTRO="unknown"
    fi
}

# Function to show a message with the detected distribution. This function will change once other distribtuons such as Fedora, Gentoo or Slackware get supported.
# At current, its Debian and Ubuntu distributions.
show_distribution() {
    dialog --title "CWD SYSTEMS Automated Build System" \
           --msgbox "Detected Linux Distribution: $PRETTY_NAME" 10 50
}

# Function to run the build-server.sh script
run_build_server() {
    clear
    dialog --title "CWD SYSTEMS Automated Build System" \
           --infobox "Building and installing The Crawling Serpent Kernel...\nPlease do not reboot after this stage.\nIt is safe to reboot after completion of all stages." 10 50
    sleep 3
    ./build-server.sh
    if [ $? -ne 0 ]; then
        dialog --title "CWD SYSTEMS Automated Build System" \
               --msgbox "Error in build-server.sh. Exiting..." 10 50
        exit 1
    fi
}

# Function to run the stage2-hardening.sh script
run_stage2_hardening() {
    clear
    dialog --title "CWD SYSTEMS Automated Build System" \
           --infobox "Hardening TCP/IP stack and applying security settings..." 10 50
    sleep 2
    sudo ./stage2-hardening.sh
    if [ $? -ne 0 ]; then
        dialog --title "CWD SYSTEMS Automated Build System" \
               --msgbox "Error in stage2-hardening.sh. Exiting..." 10 50
        exit 1
    fi
}

# Function to run the update-issue.sh script
run_update_issue() {
    clear
    dialog --title "CWD SYSTEMS Automated Build System" \
           --infobox "Enabling ZerOS branding and updating files..." 10 50
    sleep 2
    sudo ./update-issue.sh
    if [ $? -ne 0 ]; then
        dialog --title "CWD SYSTEMS Automated Build System" \
               --msgbox "Error in update-issue.sh. Exiting..." 10 50
        exit 1
    fi
}


# Detect distribution
detect_distribution

# Main menu
while true; do
    clear
    CHOICE=$(dialog --clear \
                    --title "CWD SYSTEMS Automated Build System" \
                    --backtitle "ZerOS Automated Build" \
                    --menu "Choose a step to run:" 20 60 6 \
                    1 "Show detected Linux distribution ($PRETTY_NAME)" \
                    2 "Build and install The Crawling Serpent Kernel" \
                    3 "Harden TCP/IP stack and apply security settings" \
                    4 "Enable ZerOS branding and update files" \
                    6 "Exit" 3>&1 1>&2 2>&3)
    
    case $CHOICE in
        1)
            show_distribution
            ;;
        2)
            run_build_server
            ;;
        3)
            run_stage2_hardening
            ;;
        4)
            run_update_issue
            ;;
        5)
            run_update_motd
            ;;
        6)
            clear
            dialog --title "CWD SYSTEMS Automated Build System" \
                   --msgbox "Thank you for using CWD Automated build script!" 10 50
            break
            ;;
        *)
            dialog --title "CWD SYSTEMS Automated Build System" \
                   --msgbox "Invalid option. Please try again." 10 50
            ;;
    esac
done

clear
