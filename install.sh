#!/bin/sh

# OpenWRT WAN Check Restart - Installation Script
# Simple installation for the WAN connectivity check and restart functionality

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    log_error "This script must be run as root"
    exit 1
fi

log_info "Installing OpenWRT WAN Check Restart..."

# Copy the main script to /root/
log_info "Copying wan_check.sh to /root/"
cp wan_check.sh /root/
chmod +x /root/wan_check.sh

# Copy configuration file if it exists
if [ -f "wan_check_config.sh" ]; then
    log_info "Copying configuration file to /root/"
    cp wan_check_config.sh /root/
fi

# Create backup of current crontab
log_info "Backing up current crontab..."
crontab -l > /tmp/crontab_backup_$(date +%Y%m%d_%H%M%S) 2>/dev/null || true

# Add cron job (every 5 minutes)
log_info "Adding cron job to run every 5 minutes..."
(crontab -l 2>/dev/null; echo "*/5 * * * * /root/wan_check.sh") | crontab -

# Enable and restart cron service
log_info "Enabling cron service..."
/etc/init.d/cron enable

log_info "Restarting cron service..."
/etc/init.d/cron restart

# Verify installation
log_info "Verifying installation..."

if [ -f "/root/wan_check.sh" ]; then
    log_info "✓ Script installed successfully"
else
    log_error "✗ Script installation failed"
    exit 1
fi

if [ -x "/root/wan_check.sh" ]; then
    log_info "✓ Script is executable"
else
    log_error "✗ Script is not executable"
    exit 1
fi

if crontab -l 2>/dev/null | grep -q "wan_check.sh"; then
    log_info "✓ Cron job installed successfully"
else
    log_error "✗ Cron job installation failed"
    exit 1
fi

log_info "Installation completed successfully!"
log_info "The script will run every 5 minutes to check WAN connectivity"
log_info "Check logs with: logread | grep wan_check"
log_info "Edit configuration: nano /root/wan_check_config.sh" 