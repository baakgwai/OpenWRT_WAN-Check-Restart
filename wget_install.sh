#!/bin/sh

# One-liner installation script for OpenWRT WAN Check & Restart
# Usage: wget -O - https://raw.githubusercontent.com/your-username/OpenWRT_WAN-Check-Restart/main/wget_install.sh | sh

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}OpenWRT WAN Check & Restart - WGET Installation${NC}"
echo "=================================================="

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo -e "${RED}Error: This script must be run as root${NC}"
    exit 1
fi

# Install required packages
echo "Installing required packages..."
opkg update
opkg install wget unzip

# Create temporary directory
TEMP_DIR="/tmp/wan_check_install"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# Download scripts
echo "Downloading scripts..."
wget -q --no-check-certificate https://raw.githubusercontent.com/your-username/OpenWRT_WAN-Check-Restart/main/check_all_wan.sh
wget -q --no-check-certificate https://raw.githubusercontent.com/your-username/OpenWRT_WAN-Check-Restart/main/check_all_wan_enhanced.sh
wget -q --no-check-certificate https://raw.githubusercontent.com/your-username/OpenWRT_WAN-Check-Restart/main/status.sh
wget -q --no-check-certificate https://raw.githubusercontent.com/your-username/OpenWRT_WAN-Check-Restart/main/config.sh

# Make executable and copy to /root
chmod +x *.sh
cp *.sh /root/
cp config.sh /root/wan_check_config.sh

# Set up cron job
echo "Setting up automatic monitoring..."
(crontab -l 2>/dev/null; echo "*/5 * * * * /root/check_all_wan.sh") | crontab -

# Test installation
echo "Testing installation..."
if /root/check_all_wan.sh; then
    echo -e "${GREEN}Installation completed successfully!${NC}"
    echo
    echo "Quick commands:"
    echo -e "  Check status: ${BLUE}/root/status.sh${NC}"
    echo -e "  Manual test: ${BLUE}/root/check_all_wan.sh${NC}"
    echo -e "  View logs: ${BLUE}logread | grep wan_check${NC}"
else
    echo -e "${RED}Installation completed but test failed${NC}"
fi

# Cleanup
rm -rf "$TEMP_DIR" 