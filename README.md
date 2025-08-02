# OpenWRT WAN Check Restart

A simple, reliable solution for automatically monitoring and restarting WAN interfaces on OpenWRT routers when connectivity issues are detected.

## Quick Install

```bash
# Install directly from GitHub
wget -O - https://raw.githubusercontent.com/commanduser/OpenWRT_WAN-Check-Restart/main/install.sh | sh

# Uninstall
wget -O - https://raw.githubusercontent.com/commanduser/OpenWRT_WAN-Check-Restart/main/uninstall.sh | sh
```

## What It Does

- **Monitors** all WAN interfaces (case-insensitive matching)
- **Tests** connectivity using ping to 8.8.8.8
- **Restarts** failed interfaces automatically
- **Logs** all activities with timestamps
- **Runs** every 5 minutes via cron
- **Prevents** endless restart loops with failure counting

## Quick Start

1. **Install:**
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

2. **Check logs:**
   ```bash
   logread | grep wan_check
   ```

3. **Uninstall (if needed):**
   ```bash
   chmod +x uninstall.sh
   ./uninstall.sh
   ```

## Configuration

Edit `/root/wan_check_config.sh` to customize:

```bash
# Ping target (default: Google DNS)
PING_TARGET="8.8.8.8"

# How often to check (in cron job)
# Edit the cron job: crontab -e
# Current: */5 * * * * (every 5 minutes)

# Failure handling
MAX_CONSECUTIVE_FAILURES=3  # Skip restart after 3 failures

# Email notifications (optional)
ENABLE_EMAIL_NOTIFICATIONS=0
EMAIL_RECIPIENT="your@email.com"
```

## Manual Testing

```bash
# Test the script manually
/root/wan_check.sh

# Check what interfaces will be monitored
ubus list network.interface.* | grep -i wan
```

## How It Works

1. Finds all interfaces containing "wan" in the name
2. Pings 8.8.8.8 through each interface
3. If ping fails, restarts the interface with `ifdown`/`ifup`
4. Tracks consecutive failures to prevent endless restarts
5. Logs everything with the tag `wan_check`

## Troubleshooting

**Script not running?**
```bash
# Check cron status
/etc/init.d/cron status

# Check cron jobs
crontab -l

# Check cron logs
logread | grep cron
```

**No WAN interfaces found?**
```bash
# List all interfaces
ubus list network.interface.*

# Check interface status
ubus call network.interface.wan status
```

**High CPU usage?**
- Increase check interval in cron (e.g., `*/10` for every 10 minutes)
- Reduce ping count in config (change `PING_COUNT=3` to `PING_COUNT=1`)

## Files

- `wan_check.sh` - Main script
- `wan_check_config.sh` - Configuration file
- `install.sh` - Installation script
- `uninstall.sh` - Removal script

## Requirements

- OpenWRT router
- Root access
- Standard utilities: `ubus`, `jsonfilter`, `ping`, `logger`, `cron`

## License

MIT License - feel free to use and modify. 