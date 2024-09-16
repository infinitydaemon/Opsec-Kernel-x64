#!/bin/bash
# This is an optional utility and is part of ZerOS. W.I.P and needs its own place. Not exactly part of the automated build process.

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Please run with sudo${NC}"
        exit 1
    fi
}

check_chkrootkit() {
    if ! command -v chkrootkit &> /dev/null; then
        echo -e "${YELLOW}chkrootkit not found, installing...${NC}"
        apt-get update && apt-get install -y chkrootkit
    fi
}

check_rkhunter() {
    if ! command -v rkhunter &> /dev/null; then
        echo -e "${YELLOW}rkhunter not found, installing...${NC}"
        apt-get update && apt-get install -y rkhunter
    fi
}

run_chkrootkit() {
    echo -e "${BLUE}Running chkrootkit...${NC}"
    chkrootkit > chkrootkit.log
    echo -e "${GREEN}chkrootkit scan completed. Results:${NC}"
    cat chkrootkit.log
}

run_rkhunter() {
    echo -e "${BLUE}Running rkhunter...${NC}"
    rkhunter --check --sk --logfile rkhunter.log
    echo -e "${GREEN}rkhunter scan completed. Results:${NC}"
    cat rkhunter.log
}

check_outbound_connections() {
    echo -e "${BLUE}Checking outbound connections...${NC}"
    netstat -ntp | grep ESTABLISHED
}

main() {
    check_root
    check_chkrootkit
    check_rkhunter
    run_chkrootkit
    run_rkhunter
    check_outbound_connections
    echo -e "${GREEN}Malware scan and connection check completed.${NC}"
}

main
