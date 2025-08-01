#!/bin/sh

# OpenWRT WAN Connectivity Check and Restart Script
# This script checks all WAN interfaces and restarts them if they fail ping tests

# Target to test connectivity (can be changed, e.g., 8.8.8.8 or 1.1.1.1)
PING_TARGET="8.8.8.8"

# Log tag for easy identification
LOG_TAG="wan_check"

# Log function for consistent logging
log_message() {
    logger -t "$LOG_TAG" "$1"
}

# Get all interface names with "wan" (case-insensitive)
for IFACE in $(ubus list network.interface.* | grep -i 'wan' | cut -d'.' -f3); do
    # Get device name for the interface
    DEVICE=$(ubus call network.interface.$IFACE status | jsonfilter -e '@["l3_device"]')

    # Skip if device name is empty
    [ -z "$DEVICE" ] && continue

    log_message "Checking interface $IFACE ($DEVICE) with ping to $PING_TARGET"

    # Ping using specific interface (3 packets, wait 1 second each)
    ping -I "$DEVICE" -c 3 -W 1 "$PING_TARGET" >/dev/null 2>&1

    if [ $? -ne 0 ]; then
        log_message "$IFACE ($DEVICE) failed ping test, restarting DHCP client"
        ifdown "$IFACE"
        sleep 3
        ifup "$IFACE"
        log_message "$IFACE restart completed"
    else
        log_message "$IFACE ($DEVICE) ping test passed"
    fi
done 