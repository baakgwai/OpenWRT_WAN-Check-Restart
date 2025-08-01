#!/bin/sh

# OpenWRT WAN Check Restart - Enhanced Installation Script
# This script installs the WAN connectivity check and restart functionality

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log function
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_question() {
    echo -e "${BLUE}[QUESTION]${NC} $1"
}

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    log_error "This script must be run as root"
    exit 1
fi

log_info "Installing OpenWRT WAN Check Restart..."

# Ask user which version to install
log_question "Which version would you like to install?"
echo "1) Basic version (simple, reliable)"
echo "2) Enhanced version (configurable, with failure tracking)"
echo "3) Both versions"
read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        SCRIPT_TO_INSTALL="basic"
        ;;
    2)
        SCRIPT_TO_INSTALL="enhanced"
        ;;
    3)
        SCRIPT_TO_INSTALL="both"
        ;;
    *)
        log_error "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Install basic version
if [ "$SCRIPT_TO_INSTALL" = "basic" ] || [ "$SCRIPT_TO_INSTALL" = "both" ]; then
    log_info "Installing basic version..."
    cp check_all_wan.sh /root/
    chmod +x /root/check_all_wan.sh
    log_info "✓ Basic script installed"
fi

# Install enhanced version
if [ "$SCRIPT_TO_INSTALL" = "enhanced" ] || [ "$SCRIPT_TO_INSTALL" = "both" ]; then
    log_info "Installing enhanced version..."
    cp check_all_wan_enhanced.sh /root/
    chmod +x /root/check_all_wan_enhanced.sh
    
    # Ask if user wants to install configuration
    log_question "Would you like to install a configuration file? (y/n)"
    read -p "Enter your choice: " install_config
    
    if [ "$install_config" = "y" ] || [ "$install_config" = "Y" ]; then
        cp config.sh /root/wan_check_config.sh
        log_info "✓ Configuration file installed"
        log_info "You can edit /root/wan_check_config.sh to customize settings"
    fi
    
    log_info "✓ Enhanced script installed"
fi

# Copy status script
cp status.sh /root/
chmod +x /root/status.sh
log_info "✓ Status script installed"

# Create backup of current crontab
log_info "Backing up current crontab..."
crontab -l > /tmp/crontab_backup_$(date +%Y%m%d_%H%M%S) 2>/dev/null || true

# Determine which script to use for cron
if [ "$SCRIPT_TO_INSTALL" = "enhanced" ]; then
    CRON_SCRIPT="/root/check_all_wan_enhanced.sh"
else
    CRON_SCRIPT="/root/check_all_wan.sh"
fi

# Ask for cron frequency
log_question "How often should the script run?"
echo "1) Every 2 minutes"
echo "2) Every 5 minutes (recommended)"
echo "3) Every 10 minutes"
echo "4) Every hour"
echo "5) Custom interval"
read -p "Enter your choice (1-5): " cron_choice

case $cron_choice in
    1)
        CRON_SCHEDULE="*/2 * * * *"
        ;;
    2)
        CRON_SCHEDULE="*/5 * * * *"
        ;;
    3)
        CRON_SCHEDULE="*/10 * * * *"
        ;;
    4)
        CRON_SCHEDULE="0 * * * *"
        ;;
    5)
        log_question "Enter custom cron schedule (e.g., '*/15 * * * *' for every 15 minutes):"
        read -p "Schedule: " CRON_SCHEDULE
        ;;
    *)
        log_error "Invalid choice. Using default (every 5 minutes)."
        CRON_SCHEDULE="*/5 * * * *"
        ;;
esac

# Add cron job
log_info "Adding cron job: $CRON_SCHEDULE $CRON_SCRIPT"
(crontab -l 2>/dev/null; echo "$CRON_SCHEDULE $CRON_SCRIPT") | crontab -

# Enable and restart cron service
log_info "Enabling cron service..."
/etc/init.d/cron enable

log_info "Restarting cron service..."
/etc/init.d/cron restart

# Verify installation
log_info "Verifying installation..."

# Check if scripts are installed and executable
if [ "$SCRIPT_TO_INSTALL" = "basic" ] || [ "$SCRIPT_TO_INSTALL" = "both" ]; then
    if [ -f "/root/check_all_wan.sh" ] && [ -x "/root/check_all_wan.sh" ]; then
        log_info "✓ Basic script verified"
    else
        log_error "✗ Basic script verification failed"
        exit 1
    fi
fi

if [ "$SCRIPT_TO_INSTALL" = "enhanced" ] || [ "$SCRIPT_TO_INSTALL" = "both" ]; then
    if [ -f "/root/check_all_wan_enhanced.sh" ] && [ -x "/root/check_all_wan_enhanced.sh" ]; then
        log_info "✓ Enhanced script verified"
    else
        log_error "✗ Enhanced script verification failed"
        exit 1
    fi
fi

# Check cron job
if crontab -l 2>/dev/null | grep -q "check_all_wan"; then
    log_info "✓ Cron job verified"
else
    log_error "✗ Cron job verification failed"
    exit 1
fi

# Check status script
if [ -f "/root/status.sh" ] && [ -x "/root/status.sh" ]; then
    log_info "✓ Status script verified"
else
    log_error "✗ Status script verification failed"
    exit 1
fi

log_info "Installation completed successfully!"
echo
log_info "Quick Start Guide:"
echo "  • Check status: /root/status.sh"
echo "  • View logs: logread | grep wan_check"
echo "  • Test manually: $CRON_SCRIPT"
echo "  • Edit config (enhanced): /root/wan_check_config.sh"
echo
log_info "The script will run $CRON_SCHEDULE to check WAN connectivity" 