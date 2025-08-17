#!/bin/sh

# Simple WAN Check and Restart Script for OpenWRT
# Copy this entire script to /root/wan_check.sh and make it executable
# Then add to cron: crontab -e and add: */5 * * * * /root/wan_check.sh

# Configuration - edit these values as needed
PING_TARGET="8.8.8.8"
PING_COUNT=3
PING_TIMEOUT=1
RESTART_DELAY=3
LOG_TAG="wan_check"
MAX_FAILURES=3

# Log function
log_message() {
    logger -t "$LOG_TAG" "$1"
}

# Check consecutive failures
check_failures() {
    local iface="$1"
    local failure_file="/tmp/wan_failures_$iface"
    
    if [ "$MAX_FAILURES" -gt 0 ]; then
        local failures=$(cat "$failure_file" 2>/dev/null || echo "0")
        if [ "$failures" -ge "$MAX_FAILURES" ]; then
            log_message "WARNING: $iface failed $failures times, skipping restart"
            return 1
        fi
    fi
    return 0
}

# Update failure count
update_failures() {
    local iface="$1"
    local success="$2"
    local failure_file="/tmp/wan_failures_$iface"
    
    if [ "$MAX_FAILURES" -gt 0 ]; then
        if [ "$success" -eq 0 ]; then
            local failures=$(cat "$failure_file" 2>/dev/null || echo "0")
            echo $((failures + 1)) > "$failure_file"
        else
            echo "0" > "$failure_file"
        fi
    fi
}

# Main execution
log_message "Starting WAN connectivity check"

# Find all WAN interfaces
for IFACE in $(ubus list network.interface.* | grep -i wan | cut -d'.' -f3); do
    # Get device name
    DEVICE=$(ubus call network.interface.$IFACE status | jsonfilter -e '@["l3_device"]')
    
    # Skip if no device
    [ -z "$DEVICE" ] && continue
    
    log_message "Checking $IFACE ($DEVICE)"
    
    # Check failures before proceeding
    if ! check_failures "$IFACE"; then
        continue
    fi
    
    # Test connectivity
    ping -I "$DEVICE" -c "$PING_COUNT" -W "$PING_TIMEOUT" "$PING_TARGET" >/dev/null 2>&1
    
    if [ $? -ne 0 ]; then
        log_message "$IFACE failed ping test, restarting"
        
        ifdown "$IFACE"
        sleep "$RESTART_DELAY"
        ifup "$IFACE"
        
        log_message "$IFACE restart completed"
        update_failures "$IFACE" 0
    else
        log_message "$IFACE ping test passed"
        update_failures "$IFACE" 1
    fi
done

log_message "WAN check completed" 