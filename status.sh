#!/bin/sh

# OpenWRT WAN Check Restart - Status Script
# This script shows the current status of the WAN check system

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored status
print_status() {
    local status="$1"
    local message="$2"
    
    case "$status" in
        "OK")
            echo -e "${GREEN}✓${NC} $message"
            ;;
        "WARN")
            echo -e "${YELLOW}⚠${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}✗${NC} $message"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ${NC} $message"
            ;;
    esac
}

echo "=========================================="
echo "    OpenWRT WAN Check Restart Status"
echo "=========================================="
echo

# Check if main script exists
if [ -f "/root/check_all_wan.sh" ]; then
    print_status "OK" "Main script found: /root/check_all_wan.sh"
    if [ -x "/root/check_all_wan.sh" ]; then
        print_status "OK" "Script is executable"
    else
        print_status "ERROR" "Script is not executable"
    fi
else
    print_status "ERROR" "Main script not found: /root/check_all_wan.sh"
fi

# Check if enhanced script exists
if [ -f "/root/check_all_wan_enhanced.sh" ]; then
    print_status "OK" "Enhanced script found: /root/check_all_wan_enhanced.sh"
    if [ -x "/root/check_all_wan_enhanced.sh" ]; then
        print_status "OK" "Enhanced script is executable"
    else
        print_status "ERROR" "Enhanced script is not executable"
    fi
else
    print_status "INFO" "Enhanced script not found (optional)"
fi

# Check if config file exists
if [ -f "/root/wan_check_config.sh" ]; then
    print_status "OK" "Configuration file found: /root/wan_check_config.sh"
else
    print_status "INFO" "Configuration file not found (using defaults)"
fi

echo

# Check cron service status
if /etc/init.d/cron status >/dev/null 2>&1; then
    print_status "OK" "Cron service is running"
else
    print_status "ERROR" "Cron service is not running"
fi

# Check if cron is enabled
if /etc/init.d/cron enabled >/dev/null 2>&1; then
    print_status "OK" "Cron service is enabled"
else
    print_status "WARN" "Cron service is not enabled"
fi

echo

# Check cron jobs
echo "Cron Jobs:"
cron_jobs=$(crontab -l 2>/dev/null | grep "check_all_wan" || true)
if [ -n "$cron_jobs" ]; then
    echo "$cron_jobs" | while read -r job; do
        print_status "OK" "Cron job: $job"
    done
else
    print_status "ERROR" "No WAN check cron jobs found"
fi

echo

# Check network interfaces
echo "Network Interfaces:"
wan_interfaces=$(ubus list network.interface.* | grep -i 'wan' | cut -d'.' -f3 || true)
if [ -n "$wan_interfaces" ]; then
    echo "$wan_interfaces" | while read -r iface; do
        if [ -n "$iface" ]; then
            device=$(ubus call network.interface.$iface status 2>/dev/null | jsonfilter -e '@["l3_device"]' || echo "unknown")
            print_status "INFO" "Interface: $iface (device: $device)"
        fi
    done
else
    print_status "WARN" "No WAN interfaces found"
fi

echo

# Show recent logs
echo "Recent Logs (last 10 entries):"
recent_logs=$(logread | grep "wan_check" | tail -10 || true)
if [ -n "$recent_logs" ]; then
    echo "$recent_logs" | while read -r log; do
        echo "  $log"
    done
else
    print_status "INFO" "No recent wan_check logs found"
fi

echo

# Check failure tracking files
echo "Failure Tracking:"
failure_files=$(ls /tmp/wan_check_failures_* 2>/dev/null || true)
if [ -n "$failure_files" ]; then
    echo "$failure_files" | while read -r file; do
        iface=$(basename "$file" | sed 's/wan_check_failures_//')
        failures=$(cat "$file" 2>/dev/null || echo "0")
        print_status "INFO" "Interface $iface: $failures consecutive failures"
    done
else
    print_status "INFO" "No failure tracking files found"
fi

echo

# System information
echo "System Information:"
print_status "INFO" "OpenWRT Version: $(cat /etc/openwrt_release 2>/dev/null | grep DISTRIB_DESCRIPTION | cut -d'"' -f2 || echo "Unknown")"
print_status "INFO" "Uptime: $(uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')"
print_status "INFO" "Load Average: $(uptime | awk -F'load average: ' '{print $2}')"

echo
echo "==========================================" 