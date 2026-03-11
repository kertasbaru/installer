#!/bin/bash
# ============================================================================
# Test suite untuk setup-account.sh — Tahap 6: Manajemen Akun & User
# ============================================================================
# Menjalankan pengujian unit untuk fungsi-fungsi di setup-account.sh
# tanpa menjalankan operasi berbahaya (install/service management).
#
# Penggunaan:
#   chmod +x tests/test_setup_account.sh
#   ./tests/test_setup_account.sh
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/setup-account.sh"

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
echo "  Test Suite: setup-account.sh (Tahap 6)"
echo "=============================================="
echo ""

# ===========================================================================
# Section 1: Basic File Tests
# ===========================================================================

# ---- Test 1: File setup-account.sh ada ----
test_name="setup-account.sh file exists"
if [[ -f "$SCRIPT_PATH" ]]; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 2: File setup-account.sh executable ----
test_name="setup-account.sh is executable"
if [[ -x "$SCRIPT_PATH" ]]; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 3: Bash syntax valid ----
test_name="setup-account.sh has valid bash syntax"
if bash -n "$SCRIPT_PATH" 2>/dev/null; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 4: Shebang correct ----
test_name="setup-account.sh has correct shebang (#!/bin/bash)"
first_line=$(head -1 "$SCRIPT_PATH")
assert_eq "$test_name" "#!/bin/bash" "$first_line"

# ---- Test 5: Script header mentions Tahap 6 ----
test_name="Script header mentions Tahap 6"
if grep -q 'Tahap 6' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 2: Variables & Constants — Umum
# ===========================================================================

# ---- Test 6: LOG_FILE is defined ----
test_name="LOG_FILE variable is set to /root/syslog.log"
if grep -q 'LOG_FILE="/root/syslog.log"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 7: XRAY_CERT path defined ----
test_name="XRAY_CERT is defined as /etc/xray/xray.crt"
if grep -q 'XRAY_CERT="/etc/xray/xray.crt"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 8: DOMAIN_FILE path defined ----
test_name="DOMAIN_FILE is defined as /etc/xray/domain"
if grep -q 'DOMAIN_FILE="/etc/xray/domain"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 9: XRAY_CONFIG path defined ----
test_name="XRAY_CONFIG is defined as /etc/xray/config.json"
if grep -q 'XRAY_CONFIG="/etc/xray/config.json"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 10: HYSTERIA2_CONFIG path defined ----
test_name="HYSTERIA2_CONFIG is defined as /etc/hysteria2/config.yaml"
if grep -q 'HYSTERIA2_CONFIG="/etc/hysteria2/config.yaml"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 11: TROJAN_GO_CONFIG path defined ----
test_name="TROJAN_GO_CONFIG is defined as /etc/trojan-go/config.json"
if grep -q 'TROJAN_GO_CONFIG="/etc/trojan-go/config.json"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 3: Variables — Direktori Akun
# ===========================================================================

# ---- Test 12: ACCOUNT_DIR defined ----
test_name="ACCOUNT_DIR is defined as /etc/vpnray/accounts"
if grep -q 'ACCOUNT_DIR="/etc/vpnray/accounts"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 13: SSH_ACCOUNT_DIR defined ----
test_name="SSH_ACCOUNT_DIR is defined"
if grep -q 'SSH_ACCOUNT_DIR=.*ssh' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 14: VMESS_ACCOUNT_DIR defined ----
test_name="VMESS_ACCOUNT_DIR is defined"
if grep -q 'VMESS_ACCOUNT_DIR=.*vmess' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 15: VLESS_ACCOUNT_DIR defined ----
test_name="VLESS_ACCOUNT_DIR is defined"
if grep -q 'VLESS_ACCOUNT_DIR=.*vless' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 16: TROJAN_ACCOUNT_DIR defined ----
test_name="TROJAN_ACCOUNT_DIR is defined"
if grep -q 'TROJAN_ACCOUNT_DIR=.*trojan' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 17: SHADOWSOCKS_ACCOUNT_DIR defined ----
test_name="SHADOWSOCKS_ACCOUNT_DIR is defined"
if grep -q 'SHADOWSOCKS_ACCOUNT_DIR=.*shadowsocks' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 18: SOCKS_ACCOUNT_DIR defined ----
test_name="SOCKS_ACCOUNT_DIR is defined"
if grep -q 'SOCKS_ACCOUNT_DIR=.*socks' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 19: HYSTERIA2_ACCOUNT_DIR defined ----
test_name="HYSTERIA2_ACCOUNT_DIR is defined"
if grep -q 'HYSTERIA2_ACCOUNT_DIR=.*hysteria2' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 20: TROJAN_GO_ACCOUNT_DIR defined ----
test_name="TROJAN_GO_ACCOUNT_DIR is defined"
if grep -q 'TROJAN_GO_ACCOUNT_DIR=.*trojan-go' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 21: SSH_LOCKED_DIR defined ----
test_name="SSH_LOCKED_DIR is defined as /etc/vpnray/ssh-locked"
if grep -q 'SSH_LOCKED_DIR="/etc/vpnray/ssh-locked"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 22: SSH_BANNED_DIR defined ----
test_name="SSH_BANNED_DIR is defined as /etc/vpnray/ssh-banned"
if grep -q 'SSH_BANNED_DIR="/etc/vpnray/ssh-banned"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 4: Variables — Utility Script Paths
# ===========================================================================

# ---- Test 23: XP_SSH_BIN defined ----
test_name="XP_SSH_BIN is defined as /usr/local/bin/xp-ssh"
if grep -q 'XP_SSH_BIN="/usr/local/bin/xp-ssh"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 24: XP_XRAY_BIN defined ----
test_name="XP_XRAY_BIN is defined as /usr/local/bin/xp-xray"
if grep -q 'XP_XRAY_BIN="/usr/local/bin/xp-xray"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 25: AUTO_DELETE_BIN defined ----
test_name="AUTO_DELETE_BIN is defined as /usr/local/bin/auto-delete-expired"
if grep -q 'AUTO_DELETE_BIN="/usr/local/bin/auto-delete-expired"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 26: AUTO_DISCONNECT_BIN defined ----
test_name="AUTO_DISCONNECT_BIN is defined as /usr/local/bin/auto-disconnect-duplicate"
if grep -q 'AUTO_DISCONNECT_BIN="/usr/local/bin/auto-disconnect-duplicate"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 27: LIMIT_IP_SSH_BIN defined ----
test_name="LIMIT_IP_SSH_BIN is defined"
if grep -q 'LIMIT_IP_SSH_BIN="/usr/local/bin/limit-ip-ssh"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 28: LIMIT_IP_XRAY_BIN defined ----
test_name="LIMIT_IP_XRAY_BIN is defined"
if grep -q 'LIMIT_IP_XRAY_BIN="/usr/local/bin/limit-ip-xray"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 29: LIMIT_QUOTA_XRAY_BIN defined ----
test_name="LIMIT_QUOTA_XRAY_BIN is defined"
if grep -q 'LIMIT_QUOTA_XRAY_BIN="/usr/local/bin/limit-quota-xray"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 30: LOCK_SSH_BIN defined ----
test_name="LOCK_SSH_BIN is defined"
if grep -q 'LOCK_SSH_BIN="/usr/local/bin/lock-ssh"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 31: LOCK_XRAY_BIN defined ----
test_name="LOCK_XRAY_BIN is defined"
if grep -q 'LOCK_XRAY_BIN="/usr/local/bin/lock-xray"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 5: Variables — Cronjob Paths
# ===========================================================================

# ---- Test 32: CRON_DELETE_EXPIRED defined ----
test_name="CRON_DELETE_EXPIRED is defined"
if grep -q 'CRON_DELETE_EXPIRED="/etc/cron.d/auto-delete-expired"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 33: CRON_DISCONNECT_DUP defined ----
test_name="CRON_DISCONNECT_DUP is defined"
if grep -q 'CRON_DISCONNECT_DUP="/etc/cron.d/auto-disconnect-duplicate"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 6: Fungsi Utilitas — Logging & Header
# ===========================================================================

# ---- Test 34: log() function exists ----
test_name="log() function is defined"
if grep -q '^log()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 35: log_warn() function exists ----
test_name="log_warn() function is defined"
if grep -q '^log_warn()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 36: log_error() function exists ----
test_name="log_error() function is defined"
if grep -q '^log_error()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 37: print_header() function exists ----
test_name="print_header() function is defined"
if grep -q '^print_header()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 38: log() writes to LOG_FILE ----
test_name="log() function writes to LOG_FILE"
if grep -A5 '^log()' "$SCRIPT_PATH" | grep -q 'LOG_FILE'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 7: Fungsi Pengecekan Prasyarat
# ===========================================================================

# ---- Test 39: check_root() exists ----
test_name="check_root() function is defined"
if grep -q '^check_root()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 40: check_os() exists ----
test_name="check_os() function is defined"
if grep -q '^check_os()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 41: check_arch() exists ----
test_name="check_arch() function is defined"
if grep -q '^check_arch()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 42: check_virt() exists ----
test_name="check_virt() function is defined"
if grep -q '^check_virt()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 43: check_tahap5() exists ----
test_name="check_tahap5() function is defined"
if grep -q '^check_tahap5()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 44: check_os supports Ubuntu 20.04 ----
test_name="check_os supports Ubuntu 20.04"
if grep -A30 '^check_os()' "$SCRIPT_PATH" | grep -q '20.04'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 45: check_os supports Ubuntu 22.04 ----
test_name="check_os supports Ubuntu 22.04"
if grep -A30 '^check_os()' "$SCRIPT_PATH" | grep -q '22.04'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 46: check_os supports Ubuntu 24.04 ----
test_name="check_os supports Ubuntu 24.04"
if grep -A30 '^check_os()' "$SCRIPT_PATH" | grep -q '24.04'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 47: check_os supports Debian 10 ----
test_name="check_os supports Debian 10"
if grep -A40 '^check_os()' "$SCRIPT_PATH" | grep -q '10'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 48: check_os supports Debian 11 ----
test_name="check_os supports Debian 11"
if grep -A40 '^check_os()' "$SCRIPT_PATH" | grep -q '11'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 49: check_os supports Debian 12 ----
test_name="check_os supports Debian 12"
if grep -A40 '^check_os()' "$SCRIPT_PATH" | grep -q '12'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 50: check_virt rejects openvz ----
test_name="check_virt rejects openvz"
if grep -A30 '^check_virt()' "$SCRIPT_PATH" | grep -q 'openvz'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 51: check_tahap5 checks for Hysteria2 ----
test_name="check_tahap5 checks for Hysteria2 binary"
if grep -A60 '^check_tahap5()' "$SCRIPT_PATH" | grep -q 'hysteria'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 52: check_tahap5 checks for Trojan-Go ----
test_name="check_tahap5 checks for Trojan-Go binary"
if grep -A50 '^check_tahap5()' "$SCRIPT_PATH" | grep -q 'trojan-go'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 53: check_tahap5 checks for OpenVPN ----
test_name="check_tahap5 checks for OpenVPN"
if grep -A60 '^check_tahap5()' "$SCRIPT_PATH" | grep -q 'openvpn'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 8: Helper Functions
# ===========================================================================

# ---- Test 54: get_domain() exists ----
test_name="get_domain() function is defined"
if grep -q '^get_domain()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 55: get_public_ip() exists ----
test_name="get_public_ip() function is defined"
if grep -q '^get_public_ip()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 56: generate_uuid() exists ----
test_name="generate_uuid() function is defined"
if grep -q '^generate_uuid()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 57: generate_password() exists ----
test_name="generate_password() function is defined"
if grep -q '^generate_password()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 58: get_current_date() exists ----
test_name="get_current_date() function is defined"
if grep -q '^get_current_date()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 59: get_expiry_date() exists ----
test_name="get_expiry_date() function is defined"
if grep -q '^get_expiry_date()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 60: is_expired() exists ----
test_name="is_expired() function is defined"
if grep -q '^is_expired()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 9: SSH Account Functions
# ===========================================================================

# ---- Test 61: create_ssh_account() exists ----
test_name="create_ssh_account() function is defined"
if grep -q '^create_ssh_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 62: delete_ssh_account() exists ----
test_name="delete_ssh_account() function is defined"
if grep -q '^delete_ssh_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 63: extend_ssh_account() exists ----
test_name="extend_ssh_account() function is defined"
if grep -q '^extend_ssh_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 64: lock_ssh_account() exists ----
test_name="lock_ssh_account() function is defined"
if grep -q '^lock_ssh_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 65: unlock_ssh_account() exists ----
test_name="unlock_ssh_account() function is defined"
if grep -q '^unlock_ssh_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 66: ban_ssh_account() exists ----
test_name="ban_ssh_account() function is defined"
if grep -q '^ban_ssh_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 67: unban_ssh_account() exists ----
test_name="unban_ssh_account() function is defined"
if grep -q '^unban_ssh_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 68: check_ssh_login() exists ----
test_name="check_ssh_login() function is defined"
if grep -q '^check_ssh_login()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 69: limit_ip_ssh() exists ----
test_name="limit_ip_ssh() function is defined"
if grep -q '^limit_ip_ssh()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 70: list_ssh_accounts() exists ----
test_name="list_ssh_accounts() function is defined"
if grep -q '^list_ssh_accounts()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 71: create_ssh saves JSON account file ----
test_name="create_ssh_account saves JSON file to SSH_ACCOUNT_DIR"
if grep -A40 '^create_ssh_account()' "$SCRIPT_PATH" | grep -q 'SSH_ACCOUNT_DIR.*\.json'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 72: create_ssh uses useradd ----
test_name="create_ssh_account uses useradd command"
if grep -A40 '^create_ssh_account()' "$SCRIPT_PATH" | grep -q 'useradd'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 73: lock_ssh uses passwd -l ----
test_name="lock_ssh_account uses passwd -l"
if grep -A20 '^lock_ssh_account()' "$SCRIPT_PATH" | grep -q 'passwd -l'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 10: VMess Account Functions
# ===========================================================================

# ---- Test 74: create_vmess_account() exists ----
test_name="create_vmess_account() function is defined"
if grep -q '^create_vmess_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 75: delete_vmess_account() exists ----
test_name="delete_vmess_account() function is defined"
if grep -q '^delete_vmess_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 76: extend_vmess_account() exists ----
test_name="extend_vmess_account() function is defined"
if grep -q '^extend_vmess_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 77: lock_vmess_account() exists ----
test_name="lock_vmess_account() function is defined"
if grep -q '^lock_vmess_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 78: unlock_vmess_account() exists ----
test_name="unlock_vmess_account() function is defined"
if grep -q '^unlock_vmess_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 79: ban_vmess_account() exists ----
test_name="ban_vmess_account() function is defined"
if grep -q '^ban_vmess_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 80: unban_vmess_account() exists ----
test_name="unban_vmess_account() function is defined"
if grep -q '^unban_vmess_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 81: limit_ip_vmess() exists ----
test_name="limit_ip_vmess() function is defined"
if grep -q '^limit_ip_vmess()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 82: limit_quota_vmess() exists ----
test_name="limit_quota_vmess() function is defined"
if grep -q '^limit_quota_vmess()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 83: list_vmess_accounts() exists ----
test_name="list_vmess_accounts() function is defined"
if grep -q '^list_vmess_accounts()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 84: create_vmess uses generate_uuid ----
test_name="create_vmess_account uses generate_uuid"
if grep -A30 '^create_vmess_account()' "$SCRIPT_PATH" | grep -q 'generate_uuid'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 11: VLESS Account Functions
# ===========================================================================

# ---- Test 85: create_vless_account() exists ----
test_name="create_vless_account() function is defined"
if grep -q '^create_vless_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 86: delete_vless_account() exists ----
test_name="delete_vless_account() function is defined"
if grep -q '^delete_vless_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 87: lock_vless_account() exists ----
test_name="lock_vless_account() function is defined"
if grep -q '^lock_vless_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 88: limit_ip_vless() exists ----
test_name="limit_ip_vless() function is defined"
if grep -q '^limit_ip_vless()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 89: limit_quota_vless() exists ----
test_name="limit_quota_vless() function is defined"
if grep -q '^limit_quota_vless()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 90: create_vless uses generate_uuid ----
test_name="create_vless_account uses generate_uuid"
if grep -A30 '^create_vless_account()' "$SCRIPT_PATH" | grep -q 'generate_uuid'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 12: Trojan Account Functions
# ===========================================================================

# ---- Test 91: create_trojan_account() exists ----
test_name="create_trojan_account() function is defined"
if grep -q '^create_trojan_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 92: delete_trojan_account() exists ----
test_name="delete_trojan_account() function is defined"
if grep -q '^delete_trojan_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 93: lock_trojan_account() exists ----
test_name="lock_trojan_account() function is defined"
if grep -q '^lock_trojan_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 94: create_trojan uses generate_password ----
test_name="create_trojan_account uses generate_password"
if grep -A20 '^create_trojan_account()' "$SCRIPT_PATH" | grep -q 'generate_password'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 95: limit_quota_trojan() exists ----
test_name="limit_quota_trojan() function is defined"
if grep -q '^limit_quota_trojan()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 13: Shadowsocks Account Functions
# ===========================================================================

# ---- Test 96: create_shadowsocks_account() exists ----
test_name="create_shadowsocks_account() function is defined"
if grep -q '^create_shadowsocks_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 97: delete_shadowsocks_account() exists ----
test_name="delete_shadowsocks_account() function is defined"
if grep -q '^delete_shadowsocks_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 98: lock_shadowsocks_account() exists ----
test_name="lock_shadowsocks_account() function is defined"
if grep -q '^lock_shadowsocks_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 99: create_shadowsocks uses generate_password ----
test_name="create_shadowsocks_account uses generate_password"
if grep -A20 '^create_shadowsocks_account()' "$SCRIPT_PATH" | grep -q 'generate_password'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 100: limit_quota_shadowsocks() exists ----
test_name="limit_quota_shadowsocks() function is defined"
if grep -q '^limit_quota_shadowsocks()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 14: Socks Account Functions
# ===========================================================================

# ---- Test 101: create_socks_account() exists ----
test_name="create_socks_account() function is defined"
if grep -q '^create_socks_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 102: delete_socks_account() exists ----
test_name="delete_socks_account() function is defined"
if grep -q '^delete_socks_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 103: lock_socks_account() exists ----
test_name="lock_socks_account() function is defined"
if grep -q '^lock_socks_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 104: create_socks uses generate_password ----
test_name="create_socks_account uses generate_password"
if grep -A20 '^create_socks_account()' "$SCRIPT_PATH" | grep -q 'generate_password'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 105: limit_quota_socks() exists ----
test_name="limit_quota_socks() function is defined"
if grep -q '^limit_quota_socks()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 15: Hysteria2 Account Functions
# ===========================================================================

# ---- Test 106: create_hysteria2_account() exists ----
test_name="create_hysteria2_account() function is defined"
if grep -q '^create_hysteria2_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 107: delete_hysteria2_account() exists ----
test_name="delete_hysteria2_account() function is defined"
if grep -q '^delete_hysteria2_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 108: extend_hysteria2_account() exists ----
test_name="extend_hysteria2_account() function is defined"
if grep -q '^extend_hysteria2_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 109: lock_hysteria2_account() exists ----
test_name="lock_hysteria2_account() function is defined"
if grep -q '^lock_hysteria2_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 110: ban_hysteria2_account() exists ----
test_name="ban_hysteria2_account() function is defined"
if grep -q '^ban_hysteria2_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 111: limit_ip_hysteria2() exists ----
test_name="limit_ip_hysteria2() function is defined"
if grep -q '^limit_ip_hysteria2()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 112: limit_quota_hysteria2() exists ----
test_name="limit_quota_hysteria2() function is defined"
if grep -q '^limit_quota_hysteria2()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 113: create_hysteria2 modifies HYSTERIA2_CONFIG ----
test_name="create_hysteria2_account modifies Hysteria2 config"
if grep -A30 '^create_hysteria2_account()' "$SCRIPT_PATH" | grep -q 'HYSTERIA2_CONFIG'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 16: Trojan-Go Account Functions
# ===========================================================================

# ---- Test 114: create_trojan_go_account() exists ----
test_name="create_trojan_go_account() function is defined"
if grep -q '^create_trojan_go_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 115: delete_trojan_go_account() exists ----
test_name="delete_trojan_go_account() function is defined"
if grep -q '^delete_trojan_go_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 116: lock_trojan_go_account() exists ----
test_name="lock_trojan_go_account() function is defined"
if grep -q '^lock_trojan_go_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 117: ban_trojan_go_account() exists ----
test_name="ban_trojan_go_account() function is defined"
if grep -q '^ban_trojan_go_account()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 118: create_trojan_go modifies TROJAN_GO_CONFIG ----
test_name="create_trojan_go_account modifies Trojan-Go config"
if grep -A30 '^create_trojan_go_account()' "$SCRIPT_PATH" | grep -q 'TROJAN_GO_CONFIG'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 17: Bulk & Recovery Functions
# ===========================================================================

# ---- Test 119: bulk_create_accounts() exists ----
test_name="bulk_create_accounts() function is defined"
if grep -q '^bulk_create_accounts()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 120: recover_expired_accounts() exists ----
test_name="recover_expired_accounts() function is defined"
if grep -q '^recover_expired_accounts()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 121: bulk_create supports vmess ----
test_name="bulk_create_accounts supports vmess protocol"
if grep -A40 '^bulk_create_accounts()' "$SCRIPT_PATH" | grep -q 'vmess'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 122: bulk_create supports all protocols ----
test_name="bulk_create_accounts supports ssh protocol"
if grep -A40 '^bulk_create_accounts()' "$SCRIPT_PATH" | grep -q 'ssh'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 123: recover supports is_expired check ----
test_name="recover_expired_accounts uses is_expired"
if grep -A60 '^recover_expired_accounts()' "$SCRIPT_PATH" | grep -q 'is_expired'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 18: Utility Script Creators
# ===========================================================================

# ---- Test 124: create_xp_ssh_script() exists ----
test_name="create_xp_ssh_script() function is defined"
if grep -q '^create_xp_ssh_script()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 125: create_xp_xray_script() exists ----
test_name="create_xp_xray_script() function is defined"
if grep -q '^create_xp_xray_script()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 126: create_auto_delete_script() exists ----
test_name="create_auto_delete_script() function is defined"
if grep -q '^create_auto_delete_script()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 127: create_auto_disconnect_script() exists ----
test_name="create_auto_disconnect_script() function is defined"
if grep -q '^create_auto_disconnect_script()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 128: create_limit_ip_scripts() exists ----
test_name="create_limit_ip_scripts() function is defined"
if grep -q '^create_limit_ip_scripts()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 129: create_limit_quota_script() exists ----
test_name="create_limit_quota_script() function is defined"
if grep -q '^create_limit_quota_script()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 130: create_lock_scripts() exists ----
test_name="create_lock_scripts() function is defined"
if grep -q '^create_lock_scripts()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 131: xp-ssh script writes to XP_SSH_BIN ----
test_name="create_xp_ssh_script writes to XP_SSH_BIN"
if grep -A5 '^create_xp_ssh_script()' "$SCRIPT_PATH" | grep -q 'XP_SSH_BIN'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 132: auto-delete script references all protocols ----
test_name="auto-delete script handles multiple protocols"
if grep -A80 '^create_auto_delete_script()' "$SCRIPT_PATH" | grep -q 'vmess vless trojan'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 19: Monitoring & Generators
# ===========================================================================

# ---- Test 133: setup_bandwidth_monitoring() exists ----
test_name="setup_bandwidth_monitoring() function is defined"
if grep -q '^setup_bandwidth_monitoring()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 134: create_subscription_generator() exists ----
test_name="create_subscription_generator() function is defined"
if grep -q '^create_subscription_generator()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 135: create_clash_config_generator() exists ----
test_name="create_clash_config_generator() function is defined"
if grep -q '^create_clash_config_generator()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 136: create_vpnray_converter() exists ----
test_name="create_vpnray_converter() function is defined"
if grep -q '^create_vpnray_converter()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 137: subscription generator supports vmess ----
test_name="Subscription generator supports vmess protocol"
if grep -A70 '^create_subscription_generator()' "$SCRIPT_PATH" | grep -q 'vmess://'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 138: subscription generator supports vless ----
test_name="Subscription generator supports vless protocol"
if grep -A70 '^create_subscription_generator()' "$SCRIPT_PATH" | grep -q 'vless://'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 139: subscription generator supports trojan ----
test_name="Subscription generator supports trojan protocol"
if grep -A70 '^create_subscription_generator()' "$SCRIPT_PATH" | grep -q 'trojan://'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 140: clash generator creates YAML config ----
test_name="Clash config generator creates proxy config"
if grep -A120 '^create_clash_config_generator()' "$SCRIPT_PATH" | grep -q 'proxies:'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 141: vpnray converter outputs JSON ----
test_name="VPNRay converter outputs JSON format"
if grep -A80 '^create_vpnray_converter()' "$SCRIPT_PATH" | grep -q '"uuid"'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 20: Cronjob Setup
# ===========================================================================

# ---- Test 142: setup_account_cronjobs() exists ----
test_name="setup_account_cronjobs() function is defined"
if grep -q '^setup_account_cronjobs()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 143: cronjob auto-delete at midnight ----
test_name="Cronjob auto-delete scheduled at midnight"
if grep -A20 '^setup_account_cronjobs()' "$SCRIPT_PATH" | grep -q '0 0 \* \* \*'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 144: cronjob auto-disconnect every 5 min ----
test_name="Cronjob auto-disconnect scheduled every 5 minutes"
if grep -A30 '^setup_account_cronjobs()' "$SCRIPT_PATH" | grep -q '\*/5 \* \* \* \*'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 145: cronjob writes to CRON_DELETE_EXPIRED ----
test_name="Cronjob writes to CRON_DELETE_EXPIRED path"
if grep -A10 '^setup_account_cronjobs()' "$SCRIPT_PATH" | grep -q 'CRON_DELETE_EXPIRED'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 21: Setup Account Directories
# ===========================================================================

# ---- Test 146: setup_account_directories() exists ----
test_name="setup_account_directories() function is defined"
if grep -q '^setup_account_directories()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 147: setup_account_directories creates SSH dir ----
test_name="setup_account_directories includes SSH_ACCOUNT_DIR"
if grep -A30 '^setup_account_directories()' "$SCRIPT_PATH" | grep -q 'SSH_ACCOUNT_DIR'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 148: setup_account_directories uses mkdir -p ----
test_name="setup_account_directories uses mkdir -p"
if grep -A30 '^setup_account_directories()' "$SCRIPT_PATH" | grep -q 'mkdir -p'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 149: setup_account_directories sets permissions ----
test_name="setup_account_directories sets directory permissions (chmod 700)"
if grep -A30 '^setup_account_directories()' "$SCRIPT_PATH" | grep -q 'chmod 700'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 22: Main Function
# ===========================================================================

# ---- Test 150: main() exists ----
test_name="main() function is defined"
if grep -q '^main()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 151: Main calls check_root ----
test_name="Main function calls check_root"
if grep -A30 '^main()' "$SCRIPT_PATH" | grep -q 'check_root'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 152: Main calls check_tahap5 ----
test_name="Main function calls check_tahap5"
if grep -A30 '^main()' "$SCRIPT_PATH" | grep -q 'check_tahap5'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 153: Main calls setup_account_directories ----
test_name="Main function calls setup_account_directories"
if grep -A40 '^main()' "$SCRIPT_PATH" | grep -q 'setup_account_directories'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 154: Main calls create_xp_ssh_script ----
test_name="Main function calls create_xp_ssh_script"
if grep -A50 '^main()' "$SCRIPT_PATH" | grep -q 'create_xp_ssh_script'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 155: Main calls create_xp_xray_script ----
test_name="Main function calls create_xp_xray_script"
if grep -A50 '^main()' "$SCRIPT_PATH" | grep -q 'create_xp_xray_script'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 156: Main calls create_auto_delete_script ----
test_name="Main function calls create_auto_delete_script"
if grep -A50 '^main()' "$SCRIPT_PATH" | grep -q 'create_auto_delete_script'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 157: Main calls create_subscription_generator ----
test_name="Main function calls create_subscription_generator"
if grep -A60 '^main()' "$SCRIPT_PATH" | grep -q 'create_subscription_generator'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 158: Main calls create_clash_config_generator ----
test_name="Main function calls create_clash_config_generator"
if grep -A60 '^main()' "$SCRIPT_PATH" | grep -q 'create_clash_config_generator'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 159: Main calls create_vpnray_converter ----
test_name="Main function calls create_vpnray_converter"
if grep -A60 '^main()' "$SCRIPT_PATH" | grep -q 'create_vpnray_converter'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 160: Main calls setup_account_cronjobs ----
test_name="Main function calls setup_account_cronjobs"
if grep -A70 '^main()' "$SCRIPT_PATH" | grep -q 'setup_account_cronjobs'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 23: Completion Output
# ===========================================================================

# ---- Test 161: Script prints Tahap 6 completion message ----
test_name="Script prints Tahap 6 completion message"
if grep -q 'Tahap 6 selesai' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 162: Script logs Tahap 6 completion ----
test_name="Script logs Tahap 6 completion to log file"
if grep -q 'Tahap 6 selesai.*Manajemen akun' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 163: Script mentions Tahap 7 readiness ----
test_name="Script mentions readiness for Tahap 7"
if grep -q 'Tahap 7' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 24: Account File Format
# ===========================================================================

# ---- Test 164: SSH account file has username field ----
test_name="SSH account JSON has username field"
if grep -A40 '^create_ssh_account()' "$SCRIPT_PATH" | grep -q '"username"'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 165: SSH account file has expiry field ----
test_name="SSH account JSON has expiry field"
if grep -A40 '^create_ssh_account()' "$SCRIPT_PATH" | grep -q '"expiry"'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 166: SSH account file has status field ----
test_name="SSH account JSON has status field"
if grep -A30 '^create_ssh_account()' "$SCRIPT_PATH" | grep -q '"status"'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 167: VMess account has uuid field ----
test_name="VMess account JSON has uuid field"
if grep -A40 '^create_vmess_account()' "$SCRIPT_PATH" | grep -q '"uuid"'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 168: VMess account has quota_limit field ----
test_name="VMess account JSON has quota_limit field"
if grep -A40 '^create_vmess_account()' "$SCRIPT_PATH" | grep -q '"quota_limit"'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 169: Account files set 600 permissions ----
test_name="Account files have restrictive permissions (chmod 600)"
if grep -q 'chmod 600.*\.json' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 25: Referensi & Integrasi
# ===========================================================================

# ---- Test 170: Script references Xray-core ----
test_name="Script references XTLS/Xray-core"
if grep -q 'XTLS/Xray-core' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 171: Script references apernet/hysteria ----
test_name="Script references apernet/hysteria"
if grep -q 'apernet/hysteria' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 172: Script references p4gefau1t/trojan-go ----
test_name="Script references p4gefau1t/trojan-go"
if grep -q 'p4gefau1t/trojan-go' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 173: Script references FN-Rerechan02/Autoscript ----
test_name="Script references FN-Rerechan02/Autoscript"
if grep -q 'FN-Rerechan02/Autoscript' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 26: Xray Config Integration
# ===========================================================================

# ---- Test 174: VMess uses jq for Xray config ----
test_name="VMess account management uses jq for config"
if grep -A20 '^create_vmess_account()' "$SCRIPT_PATH" | grep -q 'jq'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 175: VMess adds client with alterId 0 ----
test_name="VMess uses alterId 0"
if grep -q '"alterId": 0' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 176: Trojan adds client with password ----
test_name="Trojan adds password-based client"
if grep -A20 '^create_trojan_account()' "$SCRIPT_PATH" | grep -q '"password"'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 177: Shadowsocks uses chacha20-ietf-poly1305 ----
test_name="Shadowsocks uses chacha20-ietf-poly1305 method"
if grep -q 'chacha20-ietf-poly1305' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 178: Socks uses user/pass authentication ----
test_name="Socks account uses user/pass authentication"
if grep -A20 '^create_socks_account()' "$SCRIPT_PATH" | grep -q '"user"'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 27: Shellcheck Validation
# ===========================================================================

# ---- Test 179: Script passes shellcheck ----
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
