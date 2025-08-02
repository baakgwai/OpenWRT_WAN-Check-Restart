# OpenWRT WAN Check Configuration
# Edit these settings to customize the behavior

# Ping target (IP address to test connectivity)
PING_TARGET="8.8.8.8"

# Ping settings
PING_COUNT=3          # Number of ping packets
PING_TIMEOUT=1        # Timeout in seconds per packet

# Restart settings
RESTART_DELAY=3       # Seconds to wait between ifdown and ifup

# Logging settings
LOG_TAG="wan_check"   # Tag for log messages
VERBOSE_LOGGING=0     # 1 for verbose output, 0 for quiet

# Interface settings
INTERFACE_PATTERN="wan"  # Pattern to match interface names (case-insensitive)

# Failure handling
MAX_CONSECUTIVE_FAILURES=3  # Skip restart after this many consecutive failures (0 = disabled)

