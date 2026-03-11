#!/bin/bash
# ============================================================================
# Test suite untuk setup-monitor.sh — Tahap 9: Monitoring, Backup & Keamanan
# ============================================================================
# Menjalankan pengujian unit untuk fungsi-fungsi di setup-monitor.sh
# tanpa menjalankan operasi berbahaya (install/service management).
#
# Penggunaan:
#   chmod +x tests/test_setup_monitor.sh
#   ./tests/test_setup_monitor.sh
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/setup-monitor.sh"

PASS=0
FAIL=0
SKIP=0

# Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

assert_eq() {
    local test_name="$1"
    local expected="$2"
    local actual="$3"

    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}[PASS]${NC} $test_name"
        ((PASS++))
    else
        echo -e "${RED}[FAIL]${NC} $test_name"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        ((FAIL++))
    fi
}

assert_contains() {
    local test_name="$1"
    local needle="$2"
    local haystack="$3"

    if echo "$haystack" | grep -q "$needle"; then
        echo -e "${GREEN}[PASS]${NC} $test_name"
        ((PASS++))
    else
        echo -e "${RED}[FAIL]${NC} $test_name"
        echo "  Expected to contain: $needle"
        echo "  In: $haystack"
        ((FAIL++))
    fi
}

echo "=============================================="
echo "  Test Suite: setup-monitor.sh (Tahap 9)"
echo "=============================================="
echo ""

# ===========================================================================
# Section 1: Basic File Tests
# ===========================================================================

# ---- Test 1: File exists ----
test_name="setup-monitor.sh file exists"
if [[ -f "$SCRIPT_PATH" ]]; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 2: File executable ----
test_name="setup-monitor.sh is executable"
if [[ -x "$SCRIPT_PATH" ]]; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 3: Bash syntax valid ----
test_name="setup-monitor.sh has valid bash syntax"
if bash -n "$SCRIPT_PATH" 2>/dev/null; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 4: Shebang line ----
test_name="setup-monitor.sh has correct shebang"
shebang=$(head -1 "$SCRIPT_PATH")
assert_eq "$test_name" "#!/bin/bash" "$shebang"

# ---- Test 5: Contains Tahap 9 reference ----
test_name="setup-monitor.sh contains Tahap 9 reference"
if grep -q "Tahap 9" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 2: Script Variables
# ===========================================================================

REQUIRED_VARS=(
    'LOG_FILE="/root/syslog.log"'
    'DOMAIN_FILE="/etc/xray/domain"'
    'XRAY_CONFIG="/etc/xray/config.json"'
    'VNSTAT_WEB_PORT=8899'
    'FAIL2BAN_CONFIG="/etc/fail2ban/jail.local"'
    'FIREWALL_RULES_FILE="/etc/vpnray/firewall-rules.conf"'
    'BACKUP_DIR="/home/vps/backup"'
    'BACKUP_SCRIPT="/usr/local/bin/vpnray-backup"'
    'RESTORE_SCRIPT="/usr/local/bin/vpnray-restore"'
    'AUTO_BACKUP_CRON="/etc/cron.d/vpnray-auto-backup"'
    'ADS_HOSTS_FILE="/etc/vpnray/ads-hosts.conf"'
    'DOMAIN_BLACKLIST_FILE="/etc/vpnray/domain-blacklist.conf"'
    'BT_BLOCK_FILE="/etc/vpnray/bt-block.conf"'
    'IP_WHITELIST_FILE="/etc/vpnray/ip-whitelist.conf"'
    'IP_BLACKLIST_FILE="/etc/vpnray/ip-blacklist.conf"'
    'SOD_CONFIG_FILE="/etc/vpnray/service-on-demand.conf"'
    'SOD_SCRIPT="/usr/local/bin/vpnray-sod"'
    'CPU_MONITOR_SCRIPT="/usr/local/bin/vpnray-cpu-monitor"'
    'MEM_MONITOR_SCRIPT="/usr/local/bin/vpnray-mem-monitor"'
    'RESOURCE_MONITOR_SCRIPT="/usr/local/bin/vpnray-resource-monitor"'
    'LOGROTATE_CONFIG="/etc/logrotate.d/vpnray"'
    'ACCOUNT_DIR="/etc/vpnray/accounts"'
    'SWAP_FILE="/var/swapfile"'
    'WEBMIN_PORT=10000'
)

for var in "${REQUIRED_VARS[@]}"; do
    var_name=$(echo "$var" | cut -d'=' -f1)
    test_name="Variable '$var_name' defined"
    if grep -q "$var" "$SCRIPT_PATH"; then
        assert_eq "$test_name" "true" "true"
    else
        assert_eq "$test_name" "true" "false"
    fi
done

# ===========================================================================
# Section 3: Required Functions Exist
# ===========================================================================

REQUIRED_FUNCTIONS=(
    "log"
    "log_warn"
    "log_error"
    "print_header"
    "check_root"
    "check_os"
    "check_arch"
    "check_virt"
    "check_tahap8"
    "setup_vnstat"
    "setup_vnstat_web"
    "setup_fail2ban"
    "setup_firewall"
    "create_iptables_rules"
    "setup_rclone"
    "create_backup_script"
    "create_restore_script"
    "setup_auto_backup"
    "setup_hidessh"
    "setup_webmin"
    "setup_swap"
    "setup_ads_block"
    "setup_domain_blacklist"
    "setup_bt_block"
    "setup_ip_management"
    "setup_service_on_demand"
    "setup_resource_monitoring"
    "setup_log_rotation"
    "main"
)

for func in "${REQUIRED_FUNCTIONS[@]}"; do
    test_name="Function '$func' exists"
    if grep -q "^${func}()" "$SCRIPT_PATH"; then
        assert_eq "$test_name" "true" "true"
    else
        assert_eq "$test_name" "true" "false"
    fi
done

# ===========================================================================
# Section 4: Content Checks for Key Components
# ===========================================================================

# ---- Test: vnStat web HTML ----
test_name="Script contains vnStat web HTML"
if grep -q "vnStat - Bandwidth Monitor" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: vnStat CGI script ----
test_name="Script creates vnStat CGI"
if grep -q "VNSTAT_CGI_SCRIPT" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: vnStat web systemd service ----
test_name="Script creates vnStat web systemd service"
if grep -q "vpnray-vnstat-web.service" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Fail2ban jail config ----
test_name="Script has Fail2ban jail configuration"
if grep -q "\[sshd\]" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Fail2ban Dropbear filter ----
test_name="Script has Dropbear filter"
if grep -q "dropbear-auth" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Fail2ban Xray filter ----
test_name="Script has Xray auth filter"
if grep -q "xray-auth" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Fail2ban recidive jail ----
test_name="Script has recidive jail"
if grep -q "\[recidive\]" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Firewall rules file ----
test_name="Script creates firewall rules file"
if grep -q "firewall-rules.conf" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Firewall has port 9000 for API ----
test_name="Firewall rules include API port 9000"
if grep -q "9000/tcp" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Firewall has port 443 ----
test_name="Firewall rules include port 443"
if grep -q "443/tcp" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: iptables script creation ----
test_name="Script creates iptables management script"
if grep -q "vpnray-firewall" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Backup script content ----
test_name="Backup script uses tar"
if grep -q "tar -czf" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Backup script uses rclone ----
test_name="Backup script uses rclone"
if grep -q "rclone copy" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Restore script exists ----
test_name="Restore script is created"
if grep -q "vpnray-restore" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Auto backup cronjob ----
test_name="Auto backup cronjob at 02:00"
if grep -q "0 2 \* \* \*" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: HideSSH web panel HTML ----
test_name="HideSSH web panel has HTML content"
if grep -q "VPN Tunneling Panel" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Webmin install script ----
test_name="Webmin install script created"
if grep -q "vpnray-install-webmin" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: SWAP script 1GB ----
test_name="SWAP script supports 1GB"
if grep -q "Setup SWAP 1GB" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: SWAP script 2GB ----
test_name="SWAP script supports 2GB"
if grep -q "Setup SWAP 2GB" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: SWAP script off ----
test_name="SWAP script supports disable"
if grep -q "Menonaktifkan SWAP" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Ads block hosts file ----
test_name="Ads block has Indonesian ad domains"
if grep -q "ads.telkomsel.com" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Ads block management script ----
test_name="Ads block management script created"
if grep -q "vpnray-ads-block" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Domain blacklist ----
test_name="Domain blacklist file created"
if grep -q "domain-blacklist.conf" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Domain blacklist management script ----
test_name="Domain blacklist management script created"
if grep -q "vpnray-blacklist" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: BT block config ----
test_name="BT block configuration created"
if grep -q "bt-block.conf" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: BT block iptables rules ----
test_name="BT block has iptables rules"
if grep -q "BitTorrent" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: BT block management script ----
test_name="BT block management script created"
if grep -q "vpnray-bt-block" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: IP whitelist file ----
test_name="IP whitelist file created"
if grep -q "ip-whitelist.conf" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: IP blacklist file ----
test_name="IP blacklist file created"
if grep -q "ip-blacklist.conf" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: IP management script ----
test_name="IP management script created"
if grep -q "vpnray-ip-manage" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Service on Demand config ----
test_name="Service on Demand config created"
if grep -q "service-on-demand.conf" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Service on Demand script ----
test_name="Service on Demand script created"
if grep -q "vpnray-sod" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Service on Demand cronjob ----
test_name="Service on Demand cronjob created"
if grep -q "vpnray-sod" "$SCRIPT_PATH" && grep -q '*/5' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: CPU monitor script ----
test_name="CPU monitor script created"
if grep -q "vpnray-cpu-monitor" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Memory monitor script ----
test_name="Memory monitor script created"
if grep -q "vpnray-mem-monitor" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Resource monitor script ----
test_name="Resource monitor script created"
if grep -q "vpnray-resource-monitor" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Logrotate config for Xray ----
test_name="Logrotate config for Xray"
if grep -q "/var/log/xray/" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Logrotate config for Nginx ----
test_name="Logrotate config for Nginx"
if grep -q "/var/log/nginx/" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Logrotate config for VPNRay ----
test_name="Logrotate config for VPNRay logs"
if grep -q "/var/log/vpnray-" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Logrotate config for syslog ----
test_name="Logrotate config for syslog.log"
if grep -q "/root/syslog.log" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 5: Main Function Checks
# ===========================================================================

# ---- Test: Main has numbered steps ----
test_name="Main function has step [1/15]"
if grep -q "\[1/15\]" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Main has last numbered step ----
test_name="Main function has step [15/15]"
if grep -q "\[15/15\]" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Completion message ----
test_name="Script has Tahap 9 completion message"
if grep -q "Tahap 9 selesai" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Tahap 10 readiness ----
test_name="Script mentions Tahap 10 readiness"
if grep -q "Tahap 10" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: main "$@" at end ----
test_name="Script ends with main call"
last_line=$(tail -1 "$SCRIPT_PATH")
assert_eq "$test_name" 'main "$@"' "$last_line"

# ---- Test: Color definitions ----
test_name="Script has color definitions"
if grep -q "RED=" "$SCRIPT_PATH" && grep -q "GREEN=" "$SCRIPT_PATH" && grep -q "CYAN=" "$SCRIPT_PATH" && grep -q "NC=" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: References in header ----
test_name="Script has references in header"
if grep -q "FN-Rerechan02/Autoscript" "$SCRIPT_PATH" && grep -q "mack-a/v2ray-agent" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 6: Shellcheck Validation
# ===========================================================================

# ---- Test: Script passes shellcheck ----
test_name="Script passes shellcheck"
if command -v shellcheck &>/dev/null; then
    if shellcheck "$SCRIPT_PATH" 2>/dev/null; then
        assert_eq "$test_name" "true" "true"
    else
        assert_eq "$test_name" "true" "false"
    fi
else
    echo -e "${YELLOW}[SKIP]${NC} $test_name (shellcheck not installed)"
    ((SKIP++))
fi

# ---- Hasil ----
echo ""
echo "=============================================="
echo "  Hasil: $PASS passed, $FAIL failed, $SKIP skipped"
echo "=============================================="

if [[ "$FAIL" -gt 0 ]]; then
    exit 1
fi

exit 0
