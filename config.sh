#!/bin/sh

# OpenWRT WAN Check Restart - Configuration File
# Copy this file to /root/wan_check_config.sh and modify as needed

# Ping target for connectivity testing
# Options: 8.8.8.8 (Google DNS), 1.1.1.1 (Cloudflare DNS), 208.67.222.222 (OpenDNS)
PING_TARGET="8.8.8.8"

# Number of ping packets to send
PING_COUNT=3

# Ping timeout in seconds
PING_TIMEOUT=1

# Wait time between ifdown and ifup (in seconds)
RESTART_DELAY=3

# Log tag for identification in logs
LOG_TAG="wan_check"

# Enable/disable verbose logging (1=enable, 0=disable)
VERBOSE_LOGGING=1

# Interface name pattern to match (case-insensitive)
# Default: "wan" - will match wan, wan2, wan3, etc.
INTERFACE_PATTERN="wan"

# Maximum number of consecutive failures before giving up
# Set to 0 to disable this feature
MAX_CONSECUTIVE_FAILURES=0

# Email notification settings (optional)
# Set to 1 to enable email notifications
ENABLE_EMAIL_NOTIFICATIONS=0
EMAIL_RECIPIENT="admin@example.com"
EMAIL_SUBJECT="WAN Interface Restart Alert" 