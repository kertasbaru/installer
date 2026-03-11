#!/bin/bash
# ============================================================================
# Test suite untuk setup-menu.sh — Tahap 7: Menu Sistem & CLI Dashboard
# ============================================================================
# Menjalankan pengujian unit untuk fungsi-fungsi di setup-menu.sh
# tanpa menjalankan operasi berbahaya (install/service management).
#
# Penggunaan:
#   chmod +x tests/test_setup_menu.sh
#   ./tests/test_setup_menu.sh
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/setup-menu.sh"

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
echo "  Test Suite: setup-menu.sh (Tahap 7)"
echo "=============================================="
echo ""

# ===========================================================================
# Section 1: Basic File Tests
# ===========================================================================

# ---- Test 1: File setup-menu.sh ada ----
test_name="setup-menu.sh file exists"
if [[ -f "$SCRIPT_PATH" ]]; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 2: File setup-menu.sh executable ----
test_name="setup-menu.sh is executable"
if [[ -x "$SCRIPT_PATH" ]]; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 3: Bash syntax valid ----
test_name="setup-menu.sh has valid bash syntax"
if bash -n "$SCRIPT_PATH" 2>/dev/null; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 4: Shebang correct ----
test_name="setup-menu.sh has correct shebang (#!/bin/bash)"
first_line=$(head -1 "$SCRIPT_PATH")
assert_eq "$test_name" "#!/bin/bash" "$first_line"

# ---- Test 5: Script header mentions Tahap 7 ----
test_name="Script header mentions Tahap 7"
if grep -q 'Tahap 7' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 2: Variables — Umum
# ===========================================================================

# ---- Test 6: LOG_FILE is defined ----
test_name="LOG_FILE variable is set to /root/syslog.log"
if grep -q 'LOG_FILE="/root/syslog.log"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 7: DOMAIN_FILE is defined ----
test_name="DOMAIN_FILE variable is set to /etc/xray/domain"
if grep -q 'DOMAIN_FILE="/etc/xray/domain"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 8: XRAY_CONFIG is defined ----
test_name="XRAY_CONFIG variable is set to /etc/xray/config.json"
if grep -q 'XRAY_CONFIG="/etc/xray/config.json"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 9: XRAY_CERT is defined ----
test_name="XRAY_CERT variable is set to /etc/xray/xray.crt"
if grep -q 'XRAY_CERT="/etc/xray/xray.crt"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 10: XRAY_KEY is defined ----
test_name="XRAY_KEY variable is set to /etc/xray/xray.key"
if grep -q 'XRAY_KEY="/etc/xray/xray.key"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 11: ACCOUNT_DIR is defined ----
test_name="ACCOUNT_DIR variable is set to /etc/vpnray/accounts"
if grep -q 'ACCOUNT_DIR="/etc/vpnray/accounts"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 3: Variables — Menu Script Paths
# ===========================================================================

# ---- Test 12: MENU_BIN is defined ----
test_name="MENU_BIN variable is set to /usr/local/bin/menu"
if grep -q 'MENU_BIN="/usr/local/bin/menu"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 13: MENU_SSH_BIN is defined ----
test_name="MENU_SSH_BIN variable is set to /usr/local/bin/menu-ssh"
if grep -q 'MENU_SSH_BIN="/usr/local/bin/menu-ssh"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 14: MENU_VMESS_BIN is defined ----
test_name="MENU_VMESS_BIN variable is set to /usr/local/bin/menu-vmess"
if grep -q 'MENU_VMESS_BIN="/usr/local/bin/menu-vmess"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 15: MENU_VLESS_BIN is defined ----
test_name="MENU_VLESS_BIN variable is set to /usr/local/bin/menu-vless"
if grep -q 'MENU_VLESS_BIN="/usr/local/bin/menu-vless"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 16: MENU_TROJAN_BIN is defined ----
test_name="MENU_TROJAN_BIN variable is set to /usr/local/bin/menu-trojan"
if grep -q 'MENU_TROJAN_BIN="/usr/local/bin/menu-trojan"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 17: MENU_SS_BIN is defined ----
test_name="MENU_SS_BIN variable is set to /usr/local/bin/menu-shadowsocks"
if grep -q 'MENU_SS_BIN="/usr/local/bin/menu-shadowsocks"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 18: MENU_SOCKS_BIN is defined ----
test_name="MENU_SOCKS_BIN variable is set to /usr/local/bin/menu-socks"
if grep -q 'MENU_SOCKS_BIN="/usr/local/bin/menu-socks"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 19: MENU_HYSTERIA2_BIN is defined ----
test_name="MENU_HYSTERIA2_BIN variable is set to /usr/local/bin/menu-hysteria2"
if grep -q 'MENU_HYSTERIA2_BIN="/usr/local/bin/menu-hysteria2"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 20: MENU_TROJAN_GO_BIN is defined ----
test_name="MENU_TROJAN_GO_BIN variable is set to /usr/local/bin/menu-trojan-go"
if grep -q 'MENU_TROJAN_GO_BIN="/usr/local/bin/menu-trojan-go"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 21: MENU_SOFTETHER_BIN is defined ----
test_name="MENU_SOFTETHER_BIN variable is set to /usr/local/bin/menu-softether"
if grep -q 'MENU_SOFTETHER_BIN="/usr/local/bin/menu-softether"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 22: MENU_WARP_BIN is defined ----
test_name="MENU_WARP_BIN variable is set to /usr/local/bin/menu-warp"
if grep -q 'MENU_WARP_BIN="/usr/local/bin/menu-warp"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 23: MENU_BACKUP_BIN is defined ----
test_name="MENU_BACKUP_BIN variable is set to /usr/local/bin/menu-backup"
if grep -q 'MENU_BACKUP_BIN="/usr/local/bin/menu-backup"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 24: MENU_API_BIN is defined ----
test_name="MENU_API_BIN variable is set to /usr/local/bin/menu-api"
if grep -q 'MENU_API_BIN="/usr/local/bin/menu-api"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 25: MENU_BOT_BIN is defined ----
test_name="MENU_BOT_BIN variable is set to /usr/local/bin/menu-bot"
if grep -q 'MENU_BOT_BIN="/usr/local/bin/menu-bot"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 26: MENU_SYSTEM_BIN is defined ----
test_name="MENU_SYSTEM_BIN variable is set to /usr/local/bin/menu-system"
if grep -q 'MENU_SYSTEM_BIN="/usr/local/bin/menu-system"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 27: RUNNING_BIN is defined ----
test_name="RUNNING_BIN variable is set to /usr/local/bin/running"
if grep -q 'RUNNING_BIN="/usr/local/bin/running"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 28: SPEEDTEST_BIN is defined ----
test_name="SPEEDTEST_BIN variable is set to /usr/local/bin/speedtest"
if grep -q 'SPEEDTEST_BIN="/usr/local/bin/speedtest"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 29: BANDWIDTH_BIN is defined ----
test_name="BANDWIDTH_BIN variable is set to /usr/local/bin/vnstat"
if grep -q 'BANDWIDTH_BIN="/usr/local/bin/vnstat"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 4: Fungsi Utilitas
# ===========================================================================

# ---- Test 30: log() function exists ----
test_name="log() function is defined"
if grep -q '^log() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 31: log_warn() function exists ----
test_name="log_warn() function is defined"
if grep -q '^log_warn() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 32: log_error() function exists ----
test_name="log_error() function is defined"
if grep -q '^log_error() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 33: print_header() function exists ----
test_name="print_header() function is defined"
if grep -q '^print_header() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 34: log() writes to LOG_FILE ----
test_name="log() writes to LOG_FILE"
if grep -A5 '^log() {' "$SCRIPT_PATH" | grep -q 'LOG_FILE'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 5: Pengecekan Prasyarat
# ===========================================================================

# ---- Test 35: check_root() function exists ----
test_name="check_root() function is defined"
if grep -q '^check_root() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 36: check_os() function exists ----
test_name="check_os() function is defined"
if grep -q '^check_os() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 37: check_arch() function exists ----
test_name="check_arch() function is defined"
if grep -q '^check_arch() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 38: check_virt() function exists ----
test_name="check_virt() function is defined"
if grep -q '^check_virt() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 39: check_tahap6() function exists ----
test_name="check_tahap6() function is defined"
if grep -q '^check_tahap6() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 40: check_os supports Ubuntu 20.04 ----
test_name="check_os supports Ubuntu 20.04"
if grep -A40 '^check_os() {' "$SCRIPT_PATH" | grep -q '20.04'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 41: check_os supports Ubuntu 22.04 ----
test_name="check_os supports Ubuntu 22.04"
if grep -A40 '^check_os() {' "$SCRIPT_PATH" | grep -q '22.04'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 42: check_os supports Ubuntu 24.04 ----
test_name="check_os supports Ubuntu 24.04"
if grep -A40 '^check_os() {' "$SCRIPT_PATH" | grep -q '24.04'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 43: check_os supports Debian 10 ----
test_name="check_os supports Debian 10"
if grep -A40 '^check_os() {' "$SCRIPT_PATH" | grep -q '10'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 44: check_virt rejects openvz ----
test_name="check_virt rejects openvz"
if grep -A30 '^check_virt() {' "$SCRIPT_PATH" | grep -q 'openvz'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 6: Menu Utama
# ===========================================================================

# ---- Test 45: create_main_menu() function exists ----
test_name="create_main_menu() function is defined"
if grep -q '^create_main_menu() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 46: create_main_menu writes to MENU_BIN ----
test_name="create_main_menu writes to MENU_BIN"
if grep -A5 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'MENU_BIN'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 47: Main menu contains VPN TUNNELING AUTOSCRIPT header ----
test_name="Main menu contains VPN TUNNELING AUTOSCRIPT header"
if grep -A120 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'VPN TUNNELING AUTOSCRIPT'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 48: Main menu has item [1] ----
test_name="Main menu has item [1]"
if grep -A120 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q '\[1\]'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 49: Main menu has item [18] ----
test_name="Main menu has item [18]"
if grep -A120 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q '\[18\]'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 50: Main menu has item [0] Exit ----
test_name="Main menu has item [0] Exit"
if grep -A130 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q '\[0\]'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 51: Main menu references menu-ssh ----
test_name="Main menu references menu-ssh"
if grep -A200 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'menu-ssh'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 52: Main menu references menu-vmess ----
test_name="Main menu references menu-vmess"
if grep -A200 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'menu-vmess'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 53: Main menu references menu-vless ----
test_name="Main menu references menu-vless"
if grep -A200 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'menu-vless'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 54: Main menu references menu-trojan ----
test_name="Main menu references menu-trojan"
if grep -A200 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'menu-trojan'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 55: Main menu references menu-system ----
test_name="Main menu references menu-system"
if grep -A200 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'menu-system'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 56: Main menu references menu-backup ----
test_name="Main menu references menu-backup"
if grep -A200 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'menu-backup'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 57: Main menu has Reboot option ----
test_name="Main menu has Reboot option"
if grep -A200 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'Reboot'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 58: Main menu has Running Services option ----
test_name="Main menu has Running Services option"
if grep -A120 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'Running Services'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 59: Main menu has Speedtest option ----
test_name="Main menu has Speedtest option"
if grep -A120 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'Speedtest'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 60: Main menu has box drawing characters ----
test_name="Main menu has box drawing characters"
if grep -A120 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q '┌'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 61: Main menu chmod +x ----
test_name="Main menu applies chmod +x to MENU_BIN"
if grep -A210 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'chmod +x'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 7: Protocol Sub-Menus
# ===========================================================================

# ---- Test 62: create_protocol_menu() function exists ----
test_name="create_protocol_menu() function is defined"
if grep -q '^create_protocol_menu() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 63: create_ssh_menu() function exists ----
test_name="create_ssh_menu() function is defined"
if grep -q '^create_ssh_menu() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 64: create_ssh_menu calls create_protocol_menu ----
test_name="create_ssh_menu calls create_protocol_menu"
if grep -A3 '^create_ssh_menu() {' "$SCRIPT_PATH" | grep -q 'create_protocol_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 65: create_vmess_menu() function exists ----
test_name="create_vmess_menu() function is defined"
if grep -q '^create_vmess_menu() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 66: create_vmess_menu calls create_protocol_menu ----
test_name="create_vmess_menu calls create_protocol_menu"
if grep -A3 '^create_vmess_menu() {' "$SCRIPT_PATH" | grep -q 'create_protocol_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 67: create_vless_menu() function exists ----
test_name="create_vless_menu() function is defined"
if grep -q '^create_vless_menu() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 68: create_vless_menu calls create_protocol_menu ----
test_name="create_vless_menu calls create_protocol_menu"
if grep -A3 '^create_vless_menu() {' "$SCRIPT_PATH" | grep -q 'create_protocol_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 69: create_trojan_menu() function exists ----
test_name="create_trojan_menu() function is defined"
if grep -q '^create_trojan_menu() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 70: create_trojan_menu calls create_protocol_menu ----
test_name="create_trojan_menu calls create_protocol_menu"
if grep -A3 '^create_trojan_menu() {' "$SCRIPT_PATH" | grep -q 'create_protocol_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 71: create_shadowsocks_menu() function exists ----
test_name="create_shadowsocks_menu() function is defined"
if grep -q '^create_shadowsocks_menu() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 72: create_shadowsocks_menu calls create_protocol_menu ----
test_name="create_shadowsocks_menu calls create_protocol_menu"
if grep -A3 '^create_shadowsocks_menu() {' "$SCRIPT_PATH" | grep -q 'create_protocol_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 73: create_socks_menu() function exists ----
test_name="create_socks_menu() function is defined"
if grep -q '^create_socks_menu() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 74: create_socks_menu calls create_protocol_menu ----
test_name="create_socks_menu calls create_protocol_menu"
if grep -A3 '^create_socks_menu() {' "$SCRIPT_PATH" | grep -q 'create_protocol_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 75: create_hysteria2_menu() function exists ----
test_name="create_hysteria2_menu() function is defined"
if grep -q '^create_hysteria2_menu() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 76: create_hysteria2_menu calls create_protocol_menu ----
test_name="create_hysteria2_menu calls create_protocol_menu"
if grep -A3 '^create_hysteria2_menu() {' "$SCRIPT_PATH" | grep -q 'create_protocol_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 77: create_trojan_go_menu() function exists ----
test_name="create_trojan_go_menu() function is defined"
if grep -q '^create_trojan_go_menu() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 78: create_trojan_go_menu calls create_protocol_menu ----
test_name="create_trojan_go_menu calls create_protocol_menu"
if grep -A3 '^create_trojan_go_menu() {' "$SCRIPT_PATH" | grep -q 'create_protocol_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 79: Protocol menu has Create Account option ----
test_name="Protocol menu has Create Account option"
if grep -A170 '^create_protocol_menu() {' "$SCRIPT_PATH" | grep -q 'Create Account'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 80: Protocol menu has Bulk Create option ----
test_name="Protocol menu has Bulk Create option"
if grep -A170 '^create_protocol_menu() {' "$SCRIPT_PATH" | grep -q 'Bulk Create'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 81: Protocol menu has Delete Account option ----
test_name="Protocol menu has Delete Account option"
if grep -A170 '^create_protocol_menu() {' "$SCRIPT_PATH" | grep -q 'Delete Account'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 82: Protocol menu has Extend / Renew option ----
test_name="Protocol menu has Extend / Renew option"
if grep -A170 '^create_protocol_menu() {' "$SCRIPT_PATH" | grep -q 'Extend'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 83: Protocol menu has Check User Login option ----
test_name="Protocol menu has Check User Login option"
if grep -A170 '^create_protocol_menu() {' "$SCRIPT_PATH" | grep -q 'Check User Login'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 84: Protocol menu has User Details option ----
test_name="Protocol menu has User Details option"
if grep -A170 '^create_protocol_menu() {' "$SCRIPT_PATH" | grep -q 'User Details'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 85: Protocol menu has Lock Account option ----
test_name="Protocol menu has Lock Account option"
if grep -A170 '^create_protocol_menu() {' "$SCRIPT_PATH" | grep -q 'Lock Account'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 86: Protocol menu has Unlock Account option ----
test_name="Protocol menu has Unlock Account option"
if grep -A170 '^create_protocol_menu() {' "$SCRIPT_PATH" | grep -q 'Unlock Account'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 87: Protocol menu has Limit IP option ----
test_name="Protocol menu has Limit IP Login option"
if grep -A170 '^create_protocol_menu() {' "$SCRIPT_PATH" | grep -q 'Limit IP'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 88: Protocol menu has Limit Quota option ----
test_name="Protocol menu has Limit Quota option"
if grep -A170 '^create_protocol_menu() {' "$SCRIPT_PATH" | grep -q 'Limit Quota'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 89: Protocol menu has Ban Account option ----
test_name="Protocol menu has Ban Account option"
if grep -A170 '^create_protocol_menu() {' "$SCRIPT_PATH" | grep -q 'Ban Account'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 90: Protocol menu has Unban Account option ----
test_name="Protocol menu has Unban Account option"
if grep -A170 '^create_protocol_menu() {' "$SCRIPT_PATH" | grep -q 'Unban Account'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 91: Protocol menu has Recover Expired option ----
test_name="Protocol menu has Recover Expired option"
if grep -A170 '^create_protocol_menu() {' "$SCRIPT_PATH" | grep -q 'Recover Expired'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 92: Protocol menu has List All Members option ----
test_name="Protocol menu has List All Members option"
if grep -A170 '^create_protocol_menu() {' "$SCRIPT_PATH" | grep -q 'List All Members'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 93: Protocol menu has [0] back option ----
test_name="Protocol menu has [0] Back to Main Menu option"
if grep -A170 '^create_protocol_menu() {' "$SCRIPT_PATH" | grep -q 'Back to Main Menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 94: Protocol menu has chmod +x ----
test_name="Protocol menu applies chmod +x"
if grep -A175 '^create_protocol_menu() {' "$SCRIPT_PATH" | grep -q 'chmod +x'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 8: SoftEther Menu
# ===========================================================================

# ---- Test 95: create_softether_menu() function exists ----
test_name="create_softether_menu() function is defined"
if grep -q '^create_softether_menu() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 96: create_softether_menu references MENU_SOFTETHER_BIN ----
test_name="create_softether_menu references MENU_SOFTETHER_BIN"
if grep -A5 '^create_softether_menu() {' "$SCRIPT_PATH" | grep -q 'MENU_SOFTETHER_BIN'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 97: SoftEther menu has SoftEther Status option ----
test_name="SoftEther menu has SoftEther Status option"
if grep -A100 '^create_softether_menu() {' "$SCRIPT_PATH" | grep -q 'SoftEther Status'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 98: SoftEther menu has Start SoftEther option ----
test_name="SoftEther menu has Start SoftEther option"
if grep -A100 '^create_softether_menu() {' "$SCRIPT_PATH" | grep -q 'Start SoftEther'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 99: SoftEther menu has Stop SoftEther option ----
test_name="SoftEther menu has Stop SoftEther option"
if grep -A100 '^create_softether_menu() {' "$SCRIPT_PATH" | grep -q 'Stop SoftEther'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 100: SoftEther menu has chmod +x ----
test_name="SoftEther menu applies chmod +x"
if grep -A130 '^create_softether_menu() {' "$SCRIPT_PATH" | grep -q 'chmod +x'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 9: WARP Menu
# ===========================================================================

# ---- Test 101: create_warp_menu() function exists ----
test_name="create_warp_menu() function is defined"
if grep -q '^create_warp_menu() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 102: create_warp_menu references MENU_WARP_BIN ----
test_name="create_warp_menu references MENU_WARP_BIN"
if grep -A5 '^create_warp_menu() {' "$SCRIPT_PATH" | grep -q 'MENU_WARP_BIN'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 103: WARP menu has Enable WARP option ----
test_name="WARP menu has Enable WARP option"
if grep -A100 '^create_warp_menu() {' "$SCRIPT_PATH" | grep -q 'Enable WARP'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 104: WARP menu has Disable WARP option ----
test_name="WARP menu has Disable WARP option"
if grep -A100 '^create_warp_menu() {' "$SCRIPT_PATH" | grep -q 'Disable WARP'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 105: WARP menu has WARP Status option ----
test_name="WARP menu has WARP Status option"
if grep -A100 '^create_warp_menu() {' "$SCRIPT_PATH" | grep -q 'WARP Status'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 106: WARP menu has chmod +x ----
test_name="WARP menu applies chmod +x"
if grep -A140 '^create_warp_menu() {' "$SCRIPT_PATH" | grep -q 'chmod +x'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 10: Backup Menu
# ===========================================================================

# ---- Test 107: create_backup_menu() function exists ----
test_name="create_backup_menu() function is defined"
if grep -q '^create_backup_menu() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 108: create_backup_menu references MENU_BACKUP_BIN ----
test_name="create_backup_menu references MENU_BACKUP_BIN"
if grep -A5 '^create_backup_menu() {' "$SCRIPT_PATH" | grep -q 'MENU_BACKUP_BIN'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 109: Backup menu has Backup Data option ----
test_name="Backup menu has Backup Data option"
if grep -A100 '^create_backup_menu() {' "$SCRIPT_PATH" | grep -q 'Backup Data'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 110: Backup menu has Restore Data option ----
test_name="Backup menu has Restore Data option"
if grep -A100 '^create_backup_menu() {' "$SCRIPT_PATH" | grep -q 'Restore Data'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 111: Backup menu has Setup Rclone option ----
test_name="Backup menu has Setup Rclone option"
if grep -A100 '^create_backup_menu() {' "$SCRIPT_PATH" | grep -q 'Setup Rclone'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 112: Backup menu has chmod +x ----
test_name="Backup menu applies chmod +x"
if grep -A230 '^create_backup_menu() {' "$SCRIPT_PATH" | grep -q 'chmod +x'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 11: API Menu
# ===========================================================================

# ---- Test 113: create_api_menu() function exists ----
test_name="create_api_menu() function is defined"
if grep -q '^create_api_menu() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 114: create_api_menu references MENU_API_BIN ----
test_name="create_api_menu references MENU_API_BIN"
if grep -A5 '^create_api_menu() {' "$SCRIPT_PATH" | grep -q 'MENU_API_BIN'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 115: API menu has Start API Server option ----
test_name="API menu has Start API Server option"
if grep -A100 '^create_api_menu() {' "$SCRIPT_PATH" | grep -q 'Start API Server'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 116: API menu has Stop API Server option ----
test_name="API menu has Stop API Server option"
if grep -A100 '^create_api_menu() {' "$SCRIPT_PATH" | grep -q 'Stop API Server'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 117: API menu has Restart API Server option ----
test_name="API menu has Restart API Server option"
if grep -A100 '^create_api_menu() {' "$SCRIPT_PATH" | grep -q 'Restart API Server'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 118: API menu has API Status option ----
test_name="API menu has API Status option"
if grep -A100 '^create_api_menu() {' "$SCRIPT_PATH" | grep -q 'API Status'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 119: API menu has Change API Port option ----
test_name="API menu has Change API Port option"
if grep -A100 '^create_api_menu() {' "$SCRIPT_PATH" | grep -q 'Change API Port'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 120: API menu has Generate API Key option ----
test_name="API menu has Generate API Key option"
if grep -A100 '^create_api_menu() {' "$SCRIPT_PATH" | grep -q 'Generate API Key'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 121: API menu has chmod +x ----
test_name="API menu applies chmod +x"
if grep -A150 '^create_api_menu() {' "$SCRIPT_PATH" | grep -q 'chmod +x'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 12: Bot Menu
# ===========================================================================

# ---- Test 122: create_bot_menu() function exists ----
test_name="create_bot_menu() function is defined"
if grep -q '^create_bot_menu() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 123: create_bot_menu references MENU_BOT_BIN ----
test_name="create_bot_menu references MENU_BOT_BIN"
if grep -A5 '^create_bot_menu() {' "$SCRIPT_PATH" | grep -q 'MENU_BOT_BIN'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 124: Bot menu has Register Bot Token option ----
test_name="Bot menu has Register Bot Token option"
if grep -A100 '^create_bot_menu() {' "$SCRIPT_PATH" | grep -q 'Register Bot Token'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 125: Bot menu has Start Bot option ----
test_name="Bot menu has Start Bot option"
if grep -A100 '^create_bot_menu() {' "$SCRIPT_PATH" | grep -q 'Start Bot'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 126: Bot menu has Stop Bot option ----
test_name="Bot menu has Stop Bot option"
if grep -A100 '^create_bot_menu() {' "$SCRIPT_PATH" | grep -q 'Stop Bot'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 127: Bot menu has Set Admin ID option ----
test_name="Bot menu has Set Admin ID option"
if grep -A100 '^create_bot_menu() {' "$SCRIPT_PATH" | grep -q 'Set Admin ID'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 128: Bot menu has chmod +x ----
test_name="Bot menu applies chmod +x"
if grep -A160 '^create_bot_menu() {' "$SCRIPT_PATH" | grep -q 'chmod +x'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 13: System Menu
# ===========================================================================

# ---- Test 129: create_system_menu() function exists ----
test_name="create_system_menu() function is defined"
if grep -q '^create_system_menu() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 130: create_system_menu references MENU_SYSTEM_BIN ----
test_name="create_system_menu references MENU_SYSTEM_BIN"
if grep -A5 '^create_system_menu() {' "$SCRIPT_PATH" | grep -q 'MENU_SYSTEM_BIN'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 131: System menu has Reboot VPS option ----
test_name="System menu has Reboot VPS option"
if grep -A100 '^create_system_menu() {' "$SCRIPT_PATH" | grep -q 'Reboot VPS'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 132: System menu has Change Timezone option ----
test_name="System menu has Change Timezone option"
if grep -A100 '^create_system_menu() {' "$SCRIPT_PATH" | grep -q 'Change Timezone'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 133: System menu has Change Banner / MOTD option ----
test_name="System menu has Change Banner / MOTD option"
if grep -A100 '^create_system_menu() {' "$SCRIPT_PATH" | grep -q 'Banner'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 134: System menu has Memory Usage option ----
test_name="System menu has Memory Usage option"
if grep -A100 '^create_system_menu() {' "$SCRIPT_PATH" | grep -q 'Memory Usage'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 135: System menu has Clear Log option ----
test_name="System menu has Clear Log option"
if grep -A100 '^create_system_menu() {' "$SCRIPT_PATH" | grep -q 'Clear Log'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 136: System menu has chmod +x ----
test_name="System menu applies chmod +x"
if grep -A220 '^create_system_menu() {' "$SCRIPT_PATH" | grep -q 'chmod +x'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 14: Running Script
# ===========================================================================

# ---- Test 137: create_running_script() function exists ----
test_name="create_running_script() function is defined"
if grep -q '^create_running_script() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 138: create_running_script references RUNNING_BIN ----
test_name="create_running_script references RUNNING_BIN"
if grep -A5 '^create_running_script() {' "$SCRIPT_PATH" | grep -q 'RUNNING_BIN'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 139: Running script checks SSH service ----
test_name="Running script checks SSH (sshd) service"
if grep -A100 '^create_running_script() {' "$SCRIPT_PATH" | grep -q 'sshd'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 140: Running script checks Nginx service ----
test_name="Running script checks Nginx service"
if grep -A100 '^create_running_script() {' "$SCRIPT_PATH" | grep -qi 'nginx'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 141: Running script checks Xray service ----
test_name="Running script checks Xray service"
if grep -A100 '^create_running_script() {' "$SCRIPT_PATH" | grep -qi 'xray'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 142: Running script checks Hysteria2 ----
test_name="Running script checks Hysteria2"
if grep -A100 '^create_running_script() {' "$SCRIPT_PATH" | grep -qi 'hysteria'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 143: Running script has chmod +x ----
test_name="Running script applies chmod +x"
if grep -A110 '^create_running_script() {' "$SCRIPT_PATH" | grep -q 'chmod +x'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 15: Speedtest Script
# ===========================================================================

# ---- Test 144: create_speedtest_script() function exists ----
test_name="create_speedtest_script() function is defined"
if grep -q '^create_speedtest_script() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 145: create_speedtest_script references SPEEDTEST_BIN ----
test_name="create_speedtest_script references SPEEDTEST_BIN"
if grep -A5 '^create_speedtest_script() {' "$SCRIPT_PATH" | grep -q 'SPEEDTEST_BIN'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 146: Speedtest script has speedtest-cli reference ----
test_name="Speedtest script has speedtest-cli reference"
if grep -A60 '^create_speedtest_script() {' "$SCRIPT_PATH" | grep -q 'speedtest-cli'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 147: Speedtest script has chmod +x ----
test_name="Speedtest script applies chmod +x"
if grep -A60 '^create_speedtest_script() {' "$SCRIPT_PATH" | grep -q 'chmod +x'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 16: Bandwidth Script
# ===========================================================================

# ---- Test 148: create_bandwidth_script() function exists ----
test_name="create_bandwidth_script() function is defined"
if grep -q '^create_bandwidth_script() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 149: create_bandwidth_script references BANDWIDTH_BIN ----
test_name="create_bandwidth_script references BANDWIDTH_BIN"
if grep -A5 '^create_bandwidth_script() {' "$SCRIPT_PATH" | grep -q 'BANDWIDTH_BIN'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 150: Bandwidth script has vnstat reference ----
test_name="Bandwidth script has vnstat reference"
if grep -A60 '^create_bandwidth_script() {' "$SCRIPT_PATH" | grep -q 'vnstat'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 151: Bandwidth script has chmod +x ----
test_name="Bandwidth script applies chmod +x"
if grep -A70 '^create_bandwidth_script() {' "$SCRIPT_PATH" | grep -q 'chmod +x'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 17: Menu Functions Library
# ===========================================================================

# ---- Test 152: create_menu_functions() function exists ----
test_name="create_menu_functions() function is defined"
if grep -q '^create_menu_functions() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 153: MENU_FUNCTIONS variable is defined ----
test_name="MENU_FUNCTIONS variable is defined"
if grep -q 'MENU_FUNCTIONS=' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 154: create_menu_functions creates library file ----
test_name="create_menu_functions writes to MENU_FUNCTIONS"
if grep -A10 '^create_menu_functions() {' "$SCRIPT_PATH" | grep -q 'MENU_FUNCTIONS'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 155: Menu functions library has _list_accounts ----
test_name="Menu functions library has _list_accounts function"
if grep -A100 '^create_menu_functions() {' "$SCRIPT_PATH" | grep -q '_list_accounts'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 156: Menu functions library has _stub_function ----
test_name="Menu functions library has _stub_function function"
if grep -A100 '^create_menu_functions() {' "$SCRIPT_PATH" | grep -q '_stub_function'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 18: Register Commands
# ===========================================================================

# ---- Test 157: register_menu_commands() function exists ----
test_name="register_menu_commands() function is defined"
if grep -q '^register_menu_commands() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 158: register_menu_commands makes scripts executable ----
test_name="register_menu_commands uses chmod +x"
if grep -A30 '^register_menu_commands() {' "$SCRIPT_PATH" | grep -q 'chmod +x'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 159: register_menu_commands references MENU_BIN ----
test_name="register_menu_commands references MENU_BIN"
if grep -A30 '^register_menu_commands() {' "$SCRIPT_PATH" | grep -q 'MENU_BIN'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 160: register_menu_commands references MENU_SSH_BIN ----
test_name="register_menu_commands references MENU_SSH_BIN"
if grep -A30 '^register_menu_commands() {' "$SCRIPT_PATH" | grep -q 'MENU_SSH_BIN'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 161: register_menu_commands references MENU_VMESS_BIN ----
test_name="register_menu_commands references MENU_VMESS_BIN"
if grep -A30 '^register_menu_commands() {' "$SCRIPT_PATH" | grep -q 'MENU_VMESS_BIN'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 162: register_menu_commands references RUNNING_BIN ----
test_name="register_menu_commands references RUNNING_BIN"
if grep -A30 '^register_menu_commands() {' "$SCRIPT_PATH" | grep -q 'RUNNING_BIN'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 163: register_menu_commands references SPEEDTEST_BIN ----
test_name="register_menu_commands references SPEEDTEST_BIN"
if grep -A30 '^register_menu_commands() {' "$SCRIPT_PATH" | grep -q 'SPEEDTEST_BIN'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 19: Profile Setup
# ===========================================================================

# ---- Test 164: setup_profile_menu() function exists ----
test_name="setup_profile_menu() function is defined"
if grep -q '^setup_profile_menu() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 165: setup_profile_menu references .profile ----
test_name="setup_profile_menu references .profile"
if grep -A20 '^setup_profile_menu() {' "$SCRIPT_PATH" | grep -q '.profile'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 166: setup_profile_menu has auto-menu on login ----
test_name="setup_profile_menu has auto-menu on login"
if grep -A20 '^setup_profile_menu() {' "$SCRIPT_PATH" | grep -q '/usr/local/bin/menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 167: setup_profile_menu has VPN-AUTOSCRIPT-MENU marker ----
test_name="setup_profile_menu has VPN-AUTOSCRIPT-MENU marker"
if grep -A20 '^setup_profile_menu() {' "$SCRIPT_PATH" | grep -q 'VPN-AUTOSCRIPT-MENU'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 20: Main Function
# ===========================================================================

# ---- Test 168: main() function exists ----
test_name="main() function is defined"
if grep -q '^main() {' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 169: main calls check_root ----
test_name="main() calls check_root"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'check_root'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 170: main calls check_os ----
test_name="main() calls check_os"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'check_os'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 171: main calls check_arch ----
test_name="main() calls check_arch"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'check_arch'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 172: main calls check_virt ----
test_name="main() calls check_virt"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'check_virt'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 173: main calls check_tahap6 ----
test_name="main() calls check_tahap6"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'check_tahap6'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 174: main calls create_main_menu ----
test_name="main() calls create_main_menu"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'create_main_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 175: main calls create_ssh_menu ----
test_name="main() calls create_ssh_menu"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'create_ssh_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 176: main calls create_vmess_menu ----
test_name="main() calls create_vmess_menu"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'create_vmess_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 177: main calls create_vless_menu ----
test_name="main() calls create_vless_menu"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'create_vless_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 178: main calls create_trojan_menu ----
test_name="main() calls create_trojan_menu"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'create_trojan_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 179: main calls create_softether_menu ----
test_name="main() calls create_softether_menu"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'create_softether_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 180: main calls create_warp_menu ----
test_name="main() calls create_warp_menu"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'create_warp_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 181: main calls create_backup_menu ----
test_name="main() calls create_backup_menu"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'create_backup_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 182: main calls create_api_menu ----
test_name="main() calls create_api_menu"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'create_api_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 183: main calls create_bot_menu ----
test_name="main() calls create_bot_menu"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'create_bot_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 184: main calls create_system_menu ----
test_name="main() calls create_system_menu"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'create_system_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 185: main calls create_running_script ----
test_name="main() calls create_running_script"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'create_running_script'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 186: main calls create_speedtest_script ----
test_name="main() calls create_speedtest_script"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'create_speedtest_script'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 187: main calls create_bandwidth_script ----
test_name="main() calls create_bandwidth_script"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'create_bandwidth_script'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 188: main calls register_menu_commands ----
test_name="main() calls register_menu_commands"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'register_menu_commands'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 189: main calls setup_profile_menu ----
test_name="main() calls setup_profile_menu"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'setup_profile_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 190: main calls create_shadowsocks_menu ----
test_name="main() calls create_shadowsocks_menu"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'create_shadowsocks_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 191: main calls create_socks_menu ----
test_name="main() calls create_socks_menu"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'create_socks_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 192: main calls create_hysteria2_menu ----
test_name="main() calls create_hysteria2_menu"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'create_hysteria2_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 193: main calls create_trojan_go_menu ----
test_name="main() calls create_trojan_go_menu"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'create_trojan_go_menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 194: main calls create_menu_functions ----
test_name="main() calls create_menu_functions"
if grep -A70 '^main() {' "$SCRIPT_PATH" | grep -q 'create_menu_functions'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 21: Completion Output
# ===========================================================================

# ---- Test 195: Tahap 7 selesai message ----
test_name="Script has 'Tahap 7 selesai' completion message"
if grep -q 'Tahap 7 selesai' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 196: Logs Tahap 7 completion ----
test_name="Script logs Tahap 7 completion"
if grep -q 'log.*Tahap 7 selesai' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 197: Mentions Tahap 8 readiness ----
test_name="Script mentions Tahap 8 readiness"
if grep -q 'Tahap 8' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 22: Referensi
# ===========================================================================

# ---- Test 198: References FN-Rerechan02/Autoscript ----
test_name="Script references FN-Rerechan02/Autoscript"
if grep -q 'FN-Rerechan02/Autoscript' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 199: References mack-a/v2ray-agent ----
test_name="Script references mack-a/v2ray-agent"
if grep -q 'mack-a/v2ray-agent' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 200: References Menu Sistem & CLI Dashboard in header ----
test_name="Script references Menu Sistem & CLI Dashboard"
if grep -q 'Menu Sistem' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 23: Additional Feature Tests
# ===========================================================================

# ---- Test 201: Main menu has SSH & OpenVPN Menu entry ----
test_name="Main menu has SSH & OpenVPN Menu entry"
if grep -A120 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'SSH & OpenVPN Menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 202: Main menu has VMess Menu entry ----
test_name="Main menu has VMess Menu entry"
if grep -A120 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'VMess Menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 203: Main menu has Shadowsocks Menu entry ----
test_name="Main menu has Shadowsocks Menu entry"
if grep -A120 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'Shadowsocks Menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 204: Main menu has Hysteria2 Menu entry ----
test_name="Main menu has Hysteria2 Menu entry"
if grep -A120 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'Hysteria2 Menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 205: Main menu has SoftEther VPN Menu entry ----
test_name="Main menu has SoftEther VPN Menu entry"
if grep -A120 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'SoftEther VPN Menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 206: Main menu has Cloudflare WARP Menu entry ----
test_name="Main menu has Cloudflare WARP Menu entry"
if grep -A120 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'Cloudflare WARP Menu'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 207: Main menu has System & Server Settings entry ----
test_name="Main menu has System & Server Settings entry"
if grep -A120 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'System & Server Settings'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 208: Main menu has Backup & Restore entry ----
test_name="Main menu has Backup & Restore entry"
if grep -A120 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'Backup & Restore'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 209: Main menu has vnStat Bandwidth entry ----
test_name="Main menu has vnStat Bandwidth entry"
if grep -A120 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'vnStat Bandwidth'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 210: Main menu has Script Info entry ----
test_name="Main menu has Script Info entry"
if grep -A120 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'Script Info'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 211: check_os supports Debian 11 ----
test_name="check_os supports Debian 11"
if grep -A40 '^check_os() {' "$SCRIPT_PATH" | grep -q '11'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 212: check_os supports Debian 12 ----
test_name="check_os supports Debian 12"
if grep -A40 '^check_os() {' "$SCRIPT_PATH" | grep -q '12'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 213: check_tahap6 checks ACCOUNT_DIR ----
test_name="check_tahap6 checks ACCOUNT_DIR"
if grep -A80 '^check_tahap6() {' "$SCRIPT_PATH" | grep -q 'ACCOUNT_DIR'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 214: SoftEther menu has Restart SoftEther option ----
test_name="SoftEther menu has Restart SoftEther option"
if grep -A100 '^create_softether_menu() {' "$SCRIPT_PATH" | grep -q 'Restart SoftEther'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 215: WARP menu has Change WARP Mode option ----
test_name="WARP menu has Change WARP Mode option"
if grep -A100 '^create_warp_menu() {' "$SCRIPT_PATH" | grep -q 'Change WARP Mode'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 216: Backup menu has Auto Backup Settings option ----
test_name="Backup menu has Auto Backup Settings option"
if grep -A100 '^create_backup_menu() {' "$SCRIPT_PATH" | grep -q 'Auto Backup'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 217: Bot menu has Bot Status option ----
test_name="Bot menu has Bot Status option"
if grep -A100 '^create_bot_menu() {' "$SCRIPT_PATH" | grep -q 'Bot Status'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 218: System menu has Kernel Info option ----
test_name="System menu has Kernel Info option"
if grep -A100 '^create_system_menu() {' "$SCRIPT_PATH" | grep -q 'Kernel Info'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 219: System menu has Auto Reboot Settings option ----
test_name="System menu has Auto Reboot Settings option"
if grep -A100 '^create_system_menu() {' "$SCRIPT_PATH" | grep -q 'Auto Reboot'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 220: Running script checks Trojan-Go ----
test_name="Running script checks Trojan-Go"
if grep -A100 '^create_running_script() {' "$SCRIPT_PATH" | grep -qi 'trojan-go'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 221: Running script checks HAProxy ----
test_name="Running script checks HAProxy"
if grep -A100 '^create_running_script() {' "$SCRIPT_PATH" | grep -qi 'haproxy'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 222: Running script checks OpenVPN ----
test_name="Running script checks OpenVPN"
if grep -A100 '^create_running_script() {' "$SCRIPT_PATH" | grep -qi 'openvpn'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 223: Running script checks SoftEther ----
test_name="Running script checks SoftEther"
if grep -A100 '^create_running_script() {' "$SCRIPT_PATH" | grep -qi 'softether'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 224: Running script checks Fail2Ban ----
test_name="Running script checks Fail2Ban"
if grep -A100 '^create_running_script() {' "$SCRIPT_PATH" | grep -qi 'fail2ban'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 225: Running script checks Cloudflare WARP ----
test_name="Running script checks Cloudflare WARP"
if grep -A100 '^create_running_script() {' "$SCRIPT_PATH" | grep -qi 'warp'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 226: Running script checks Dropbear ----
test_name="Running script checks Dropbear"
if grep -A100 '^create_running_script() {' "$SCRIPT_PATH" | grep -qi 'dropbear'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 227: Running script checks Stunnel4 ----
test_name="Running script checks Stunnel4"
if grep -A100 '^create_running_script() {' "$SCRIPT_PATH" | grep -qi 'stunnel'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 228: Running script checks Squid Proxy ----
test_name="Running script checks Squid Proxy"
if grep -A100 '^create_running_script() {' "$SCRIPT_PATH" | grep -qi 'squid'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 229: Protocol menu has call_account_function ----
test_name="Protocol menu has call_account_function"
if grep -A170 '^create_protocol_menu() {' "$SCRIPT_PATH" | grep -q 'call_account_function'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 230: Main menu has PROTOCOL TUNNEL MENU section ----
test_name="Main menu has PROTOCOL TUNNEL MENU section"
if grep -A120 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'PROTOCOL TUNNEL MENU'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 231: Main menu has MANAGEMENT & TOOLS section ----
test_name="Main menu has MANAGEMENT & TOOLS section"
if grep -A120 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'MANAGEMENT & TOOLS'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 232: Main menu has QUICK TOOLS section ----
test_name="Main menu has QUICK TOOLS section"
if grep -A120 '^create_main_menu() {' "$SCRIPT_PATH" | grep -q 'QUICK TOOLS'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 233: Menu functions generates per-protocol functions ----
test_name="Menu functions generates per-protocol stub functions"
if grep -A100 '^create_menu_functions() {' "$SCRIPT_PATH" | grep -q 'for proto in'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 234: Menu functions supports ssh protocol ----
test_name="Menu functions supports ssh protocol"
if grep -A100 '^create_menu_functions() {' "$SCRIPT_PATH" | grep -q 'ssh'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 235: Menu functions supports vmess protocol ----
test_name="Menu functions supports vmess protocol"
if grep -A100 '^create_menu_functions() {' "$SCRIPT_PATH" | grep -q 'vmess'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 24: Shellcheck
# ===========================================================================

# ---- Test 236: Shellcheck compliance ----
test_name="setup-menu.sh passes shellcheck"
if command -v shellcheck &>/dev/null; then
    if shellcheck -S warning "$SCRIPT_PATH" 2>/dev/null; then
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
