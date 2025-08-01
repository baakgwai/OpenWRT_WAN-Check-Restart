#!/bin/sh

# OpenWRT WAN Check & Restart - WGET Installation Script
# This script downloads and installs the WAN monitoring scripts using wget

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log tag
LOG_TAG="wan_check_install"

# Log function
log_message() {
    logger -t "$LOG_TAG" "$1"
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Error function
error_message() {
    logger -t "$LOG_TAG" "ERROR: $1"
    echo -e "${RED}[ERROR]${NC} $1"
}

# Success function
success_message() {
    logger -t "$LOG_TAG" "$1"
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Warning function
warning_message() {
    logger -t "$LOG_TAG" "WARNING: $1"
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    error_message "This script must be run as root"
    exit 1
fi

# Check if wget is available
if ! command -v wget >/dev/null 2>&1; then
    error_message "wget is not installed. Installing wget..."
    opkg update
    opkg install wget
    if [ $? -ne 0 ]; then
        error_message "Failed to install wget. Please install it manually: opkg install wget"
        exit 1
    fi
fi

# Check if curl is available (for GitHub API)
if ! command -v curl >/dev/null 2>&1; then
    warning_message "curl not found. Installing curl..."
    opkg update
    opkg install curl
fi

# Repository information
REPO_OWNER="your-username"
REPO_NAME="OpenWRT_WAN-Check-Restart"
REPO_BRANCH="main"
INSTALL_DIR="/root/wan_check"

log_message "Starting installation of OpenWRT WAN Check & Restart scripts"

# Create installation directory
log_message "Creating installation directory..."
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Download scripts using wget
log_message "Downloading scripts from repository..."

# Method 1: Try direct GitHub raw URLs
SCRIPTS=(
    "check_all_wan.sh"
    "check_all_wan_enhanced.sh"
    "install.sh"
    "install_enhanced.sh"
    "uninstall.sh"
    "status.sh"
    "config.sh"
    "README.md"
    "QUICK_START.md"
)

for script in "${SCRIPTS[@]}"; do
    log_message "Downloading $script..."
    wget -q --no-check-certificate \
        "https://raw.githubusercontent.com/$REPO_OWNER/$REPO_NAME/$REPO_BRANCH/$script" \
        -O "$script"
    
    if [ $? -eq 0 ]; then
        success_message "Downloaded $script"
        chmod +x "$script"
    else
        error_message "Failed to download $script"
    fi
done

# Alternative method: Download as ZIP and extract
if [ ! -f "check_all_wan.sh" ]; then
    log_message "Direct download failed, trying ZIP method..."
    
    # Download ZIP file
    wget -q --no-check-certificate \
        "https://github.com/$REPO_OWNER/$REPO_NAME/archive/$REPO_BRANCH.zip" \
        -O "$REPO_NAME.zip"
    
    if [ $? -eq 0 ]; then
        # Check if unzip is available
        if command -v unzip >/dev/null 2>&1; then
            unzip -q "$REPO_NAME.zip"
            cp -r "$REPO_NAME-$REPO_BRANCH"/* .
            rm -rf "$REPO_NAME-$REPO_BRANCH" "$REPO_NAME.zip"
            chmod +x *.sh
            success_message "Downloaded and extracted scripts from ZIP"
        else
            warning_message "unzip not available. Installing unzip..."
            opkg update
            opkg install unzip
            if [ $? -eq 0 ]; then
                unzip -q "$REPO_NAME.zip"
                cp -r "$REPO_NAME-$REPO_BRANCH"/* .
                rm -rf "$REPO_NAME-$REPO_BRANCH" "$REPO_NAME.zip"
                chmod +x *.sh
                success_message "Downloaded and extracted scripts from ZIP"
            else
                error_message "Failed to install unzip. Please install manually: opkg install unzip"
                exit 1
            fi
        fi
    else
        error_message "Failed to download repository ZIP file"
        exit 1
    fi
fi

# Verify essential scripts are present
if [ ! -f "check_all_wan.sh" ]; then
    error_message "Essential script check_all_wan.sh not found. Installation failed."
    exit 1
fi

# Install the monitoring system
log_message "Installing WAN monitoring system..."

# Copy scripts to /root for easy access
cp check_all_wan.sh /root/
cp check_all_wan_enhanced.sh /root/
cp status.sh /root/
cp config.sh /root/wan_check_config.sh
chmod +x /root/*.sh

# Create cron job for automatic monitoring
log_message "Setting up cron job for automatic monitoring..."
(crontab -l 2>/dev/null; echo "*/5 * * * * /root/check_all_wan.sh") | crontab -

# Test the installation
log_message "Testing installation..."
if /root/check_all_wan.sh; then
    success_message "Installation completed successfully!"
    echo
    echo -e "${GREEN}=== Installation Summary ===${NC}"
    echo -e "Scripts installed in: ${BLUE}/root/${NC}"
    echo -e "Configuration file: ${BLUE}/root/wan_check_config.sh${NC}"
    echo -e "Cron job: ${BLUE}Every 5 minutes${NC}"
    echo
    echo -e "${GREEN}=== Quick Commands ===${NC}"
    echo -e "Check status: ${BLUE}/root/status.sh${NC}"
    echo -e "Manual test: ${BLUE}/root/check_all_wan.sh${NC}"
    echo -e "View logs: ${BLUE}logread | grep wan_check${NC}"
    echo -e "Uninstall: ${BLUE}cd $INSTALL_DIR && ./uninstall.sh${NC}"
    echo
    success_message "WAN monitoring is now active and will run every 5 minutes"
else
    warning_message "Installation completed but test failed. Check logs for details."
fi

log_message "Installation process completed" 