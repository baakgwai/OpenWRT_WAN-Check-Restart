#!/bin/sh

# OpenWRT WAN Connectivity Check and Restart Script
# A single, comprehensive solution for monitoring and restarting WAN interfaces

# Load configuration if available
CONFIG_FILE="/root/wan_check_config.sh"
if [ -f "$CONFIG_FILE" ]; then
    . "$CONFIG_FILE"
else
    # Default configuration
    PING_TARGET="8.8.8.8"
    PING_COUNT=3
    PING_TIMEOUT=1
    RESTART_DELAY=3
    LOG_TAG="wan_check"
    VERBOSE_LOGGING=0
    INTERFACE_PATTERN="wan"
    MAX_CONSECUTIVE_FAILURES=3
    ENABLE_EMAIL_NOTIFICATIONS=0
    EMAIL_RECIPIENT=""
    EMAIL_SUBJECT="OpenWRT WAN Check Alert"
fi

# Log function for consistent logging
log_message() {
    logger -t "$LOG_TAG" "$1"
    [ "$VERBOSE_LOGGING" -eq 1 ] && echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}


# Function to check consecutive failures
check_consecutive_failures() {
    local iface="$1"
    local failure_file="/tmp/wan_check_failures_$iface"
    
    if [ "$MAX_CONSECUTIVE_FAILURES" -gt 0 ]; then
        local failures=$(cat "$failure_file" 2>/dev/null || echo "0")
        if [ "$failures" -ge "$MAX_CONSECUTIVE_FAILURES" ]; then
            log_message "WARNING: $iface has failed $failures consecutive times, skipping restart"
            send_email_notification "WAN interface $iface has failed $failures consecutive times and restart has been skipped"
            return 1
        fi
    fi
    return 0
}

# Function to update failure count
update_failure_count() {
    local iface="$1"
    local success="$2"
    local failure_file="/tmp/wan_check_failures_$iface"
    
    if [ "$MAX_CONSECUTIVE_FAILURES" -gt 0 ]; then
        if [ "$success" -eq 0 ]; then
            # Increment failure count
            local failures=$(cat "$failure_file" 2>/dev/null || echo "0")
            echo $((failures + 1)) > "$failure_file"
        else
            # Reset failure count on success
            echo "0" > "$failure_file"
        fi
    fi
}

# Main execution
log_message "Starting WAN connectivity check for pattern: $INTERFACE_PATTERN"

# Get all interface names matching the pattern (case-insensitive)
for IFACE in $(ubus list network.interface.* | grep -i "$INTERFACE_PATTERN" | cut -d'.' -f3); do
    # Get device name for the interface
    DEVICE=$(ubus call network.interface.$IFACE status | jsonfilter -e '@["l3_device"]')

    # Skip if device name is empty
    [ -z "$DEVICE" ] && continue

    log_message "Checking interface $IFACE ($DEVICE) with ping to $PING_TARGET"

    # Check consecutive failures before proceeding
    if ! check_consecutive_failures "$IFACE"; then
        continue
    fi

    # Ping using specific interface
    ping -I "$DEVICE" -c "$PING_COUNT" -W "$PING_TIMEOUT" "$PING_TARGET" >/dev/null 2>&1
    ping_result=$?

    if [ $ping_result -ne 0 ]; then
        log_message "$IFACE ($DEVICE) failed ping test, restarting interface"
        send_email_notification "WAN interface $IFACE ($DEVICE) failed ping test and is being restarted"
        
        ifdown "$IFACE"
        sleep "$RESTART_DELAY"
        ifup "$IFACE"
        
        log_message "$IFACE restart completed"
        update_failure_count "$IFACE" 0
    else
        log_message "$IFACE ($DEVICE) ping test passed"
        update_failure_count "$IFACE" 1
    fi
done

log_message "WAN connectivity check completed" 