# OpenWRT WAN Check Restart

A robust solution for automatically monitoring and restarting WAN interfaces on OpenWRT routers when connectivity issues are detected.

## Overview

This project provides a ping-based connectivity monitoring system for OpenWRT routers. It automatically detects when WAN interfaces lose connectivity and restarts them to restore internet access.

## Features

- **Automatic Detection**: Monitors all WAN interfaces (case-insensitive matching)
- **Ping-Based Testing**: Uses ping tests to verify connectivity to 8.8.8.8
- **Automatic Recovery**: Restarts failed interfaces using ifdown/ifup
- **Comprehensive Logging**: All activities are logged with the tag `wan_check`
- **Cron Integration**: Runs every 5 minutes automatically
- **Easy Installation**: Simple install/uninstall scripts

## Requirements

- OpenWRT router
- Root access
- `ubus`, `jsonfilter`, `ping`, `logger` utilities (standard on OpenWRT)
- Cron service

## Installation

### Quick Install

1. Clone or download this repository to your OpenWRT router
2. Make the installation script executable:
   ```bash
   chmod +x install.sh
   ```
3. Run the installation script:
   ```bash
   ./install.sh
   ```

### Manual Installation

If you prefer manual installation:

1. Copy the script to `/root/`:
   ```bash
   cp check_all_wan.sh /root/
   chmod +x /root/check_all_wan.sh
   ```

2. Add the cron job (runs every 5 minutes):
   ```bash
   (crontab -l 2>/dev/null; echo "*/5 * * * * /root/check_all_wan.sh") | crontab -
   ```

3. Enable and restart cron:
   ```bash
   /etc/init.d/cron enable
   /etc/init.d/cron restart
   ```

## Usage

### Monitoring Logs

To monitor the script's activity:

```bash
# View all wan_check logs
logread | grep wan_check

# Follow logs in real-time
logread -f | grep wan_check
```

### Manual Testing

To test the script manually:

```bash
/root/check_all_wan.sh
```

### Checking Cron Status

To verify the cron job is active:

```bash
crontab -l
```

## Configuration

### Changing Ping Target

Edit `/root/check_all_wan.sh` and modify the `PING_TARGET` variable:

```bash
# Default: Google DNS
PING_TARGET="8.8.8.8"

# Alternative: Cloudflare DNS
PING_TARGET="1.1.1.1"

# Alternative: OpenDNS
PING_TARGET="208.67.222.222"
```

### Adjusting Check Frequency

To change how often the script runs, edit the cron job:

```bash
# Every 2 minutes
*/2 * * * * /root/check_all_wan.sh

# Every 10 minutes
*/10 * * * * /root/check_all_wan.sh

# Every hour
0 * * * * /root/check_all_wan.sh
```

## Uninstallation

### Quick Uninstall

```bash
chmod +x uninstall.sh
./uninstall.sh
```

### Manual Uninstall

1. Remove the cron job:
   ```bash
   crontab -l 2>/dev/null | grep -v "check_all_wan.sh" | crontab -
   ```

2. Remove the script:
   ```bash
   rm -f /root/check_all_wan.sh
   ```

3. Restart cron:
   ```bash
   /etc/init.d/cron restart
   ```

## How It Works

1. **Interface Discovery**: Uses `ubus list network.interface.*` to find all interfaces containing "wan"
2. **Device Resolution**: Gets the actual network device name using `ubus call network.interface.$IFACE status`
3. **Connectivity Test**: Pings the target (8.8.8.8) using the specific interface with 3 packets and 1-second timeout
4. **Failure Detection**: If ping fails, the interface is considered down
5. **Recovery Action**: Uses `ifdown` and `ifup` to restart the interface
6. **Logging**: All actions are logged with timestamps

## Troubleshooting

### Script Not Running

1. Check if cron is enabled:
   ```bash
   /etc/init.d/cron status
   ```

2. Verify the cron job exists:
   ```bash
   crontab -l
   ```

3. Check cron logs:
   ```bash
   logread | grep cron
   ```

### No WAN Interfaces Found

1. List all network interfaces:
   ```bash
   ubus list network.interface.*
   ```

2. Check interface status:
   ```bash
   ubus call network.interface.wan status
   ```

### Interface Restart Not Working

1. Check if the interface name is correct:
   ```bash
   ifconfig
   ```

2. Test manual restart:
   ```bash
   ifdown wan
   ifup wan
   ```

### High CPU Usage

If the script causes high CPU usage, consider:
- Increasing the check interval (e.g., every 10 minutes instead of 5)
- Reducing ping packets (change `-c 3` to `-c 1` in the script)

## Log Examples

```
wan_check: Checking interface wan (eth0) with ping to 8.8.8.8
wan_check: wan (eth0) ping test passed
wan_check: Checking interface wan2 (eth1) with ping to 8.8.8.8
wan_check: wan2 (eth1) failed ping test, restarting DHCP client
wan_check: wan2 restart completed
```

## Contributing

Feel free to submit issues, feature requests, or pull requests to improve this project.

## License

This project is open source and available under the MIT License.

## Disclaimer

This script modifies network interface configurations. Use at your own risk and test thoroughly in your environment before deploying in production. 