#!/bin/sh

# OpenWRT WAN Check Restart - Uninstall Script
# This script removes the WAN connectivity check and restart functionality

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

log_info "Uninstalling OpenWRT WAN Check Restart..."

# Remove cron job
log_info "Removing cron job..."
crontab -l 2>/dev/null | grep -v "check_all_wan.sh" | crontab - || true

# Remove script file
log_info "Removing script file..."
if [ -f "/root/check_all_wan.sh" ]; then
    rm -f /root/check_all_wan.sh
    log_info "✓ Script file removed"
else
    log_warn "Script file not found at /root/check_all_wan.sh"
fi

# Restart cron service
log_info "Restarting cron service..."
/etc/init.d/cron restart

log_info "Uninstallation completed successfully!"
log_info "The WAN check functionality has been removed from your system" 