# Quick Start Guide

## 🚀 Fast Installation

### Method 1: WGET One-Liner (Recommended)
```bash
wget -O - https://raw.githubusercontent.com/baakgwai/OpenWRT_WAN-Check-Restart/main/wget_install.sh | sh
```

### Method 2: Manual Installation
1. **Download the repository** to your OpenWRT router
2. **Run the test script** to verify compatibility:
   ```bash
   ./test_script.sh
   ```
3. **Install using the enhanced installer**:
   ```bash
   ./install_enhanced.sh
   ```
4. **Check status**:
   ```bash
   /root/status.sh
   ```

## 📋 What's Included

### Core Scripts
- `check_all_wan.sh` - Basic WAN check script (your original script)
- `check_all_wan_enhanced.sh` - Enhanced version with configuration support

### Installation & Management
- `install.sh` - Simple installation script
- `install_enhanced.sh` - Interactive installation with options
- `uninstall.sh` - Complete removal script
- `status.sh` - System status checker

### Configuration & Testing
- `config.sh` - Configuration template
- `test_script.sh` - Pre-installation compatibility test

## 🎯 Key Features

✅ **Automatic WAN monitoring** - Detects connectivity issues  
✅ **Smart interface restart** - Uses ifdown/ifup for clean restarts  
✅ **Comprehensive logging** - All activities logged with timestamps  
✅ **Cron integration** - Runs automatically every 5 minutes  
✅ **Easy installation** - One-command setup  
✅ **Status monitoring** - Real-time system status  
✅ **Configuration support** - Customizable settings  
✅ **Failure tracking** - Prevents endless restart loops  

## 🔧 Basic Usage

### Check Status
```bash
/root/status.sh
```

### View Logs
```bash
logread | grep wan_check
```

### Manual Test
```bash
/root/check_all_wan.sh
```

### Uninstall
```bash
./uninstall.sh
```

## 📝 Configuration (Enhanced Version)

Edit `/root/wan_check_config.sh` to customize:
- Ping target (8.8.8.8, 1.1.1.1, etc.)
- Check frequency
- Logging verbosity
- Failure thresholds
- Email notifications

## 🆘 Troubleshooting

### Script Not Running
```bash
/etc/init.d/cron status
crontab -l
```

### No WAN Interfaces Found
```bash
ubus list network.interface.*
```

### Check Logs
```bash
logread | grep wan_check
```

## 📞 Support

- Check the full README.md for detailed documentation
- Run `./test_script.sh` to diagnose issues
- Use `./status.sh` to check system health

---

**Ready to get started?** Run `./install_enhanced.sh` and follow the prompts! 