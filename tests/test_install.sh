#!/bin/bash
# ============================================================================
# Test suite untuk install.sh — Tahap 2: Install Dependencies & Setup
# ============================================================================
# Menjalankan pengujian unit untuk fungsi-fungsi di install.sh
# tanpa menjalankan operasi berbahaya (install/sysctl).
#
# Penggunaan:
#   chmod +x tests/test_install.sh
#   ./tests/test_install.sh
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/install.sh"

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
echo "  Test Suite: install.sh (Tahap 2)"
echo "=============================================="
echo ""

# ---- Test 1: File install.sh ada ----
test_name="install.sh file exists"
if [[ -f "$SCRIPT_PATH" ]]; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 2: File install.sh executable ----
test_name="install.sh is executable"
if [[ -x "$SCRIPT_PATH" ]]; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 3: Bash syntax valid ----
test_name="install.sh has valid bash syntax"
if bash -n "$SCRIPT_PATH" 2>/dev/null; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 4: Shebang correct ----
test_name="install.sh has correct shebang (#!/bin/bash)"
first_line=$(head -1 "$SCRIPT_PATH")
assert_eq "$test_name" "#!/bin/bash" "$first_line"

# ---- Test 5: LOG_FILE is defined ----
test_name="LOG_FILE variable is set to /root/syslog.log"
if grep -q 'LOG_FILE="/root/syslog.log"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 6: Script contains check_root function ----
test_name="Script contains check_root function"
if grep -q 'check_root()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 7: Script contains check_os function ----
test_name="Script contains check_os function"
if grep -q 'check_os()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 8: Script contains check_arch function ----
test_name="Script contains check_arch function"
if grep -q 'check_arch()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 9: Script contains check_virt function ----
test_name="Script contains check_virt function"
if grep -q 'check_virt()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 10: Script contains disable_ipv6 function ----
test_name="Script contains disable_ipv6 function"
if grep -q 'disable_ipv6()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 11: Script contains install_dependencies function ----
test_name="Script contains install_dependencies function"
if grep -q 'install_dependencies()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 12: Script contains setup_timezone function ----
test_name="Script contains setup_timezone function"
if grep -q 'setup_timezone()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 13: Script contains setup_directories function ----
test_name="Script contains setup_directories function"
if grep -q 'setup_directories()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 14: Script contains setup_cloudflare function ----
test_name="Script contains setup_cloudflare function"
if grep -q 'setup_cloudflare()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 15: Script contains main function ----
test_name="Script contains main function"
if grep -q 'main()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 16-18: Script supports Ubuntu versions ----
for ver in "20.04" "22.04" "24.04"; do
    test_name="Script supports Ubuntu $ver"
    if grep -q "$ver" "$SCRIPT_PATH"; then
        assert_eq "$test_name" "true" "true"
    else
        assert_eq "$test_name" "true" "false"
    fi
done

# ---- Test 19-21: Script supports Debian versions ----
for ver in 10 11 12; do
    test_name="Script supports Debian $ver"
    if grep -A5 'debian)' "$SCRIPT_PATH" | grep -q "$ver"; then
        assert_eq "$test_name" "true" "true"
    else
        assert_eq "$test_name" "true" "false"
    fi
done

# ---- Test 22: Script disables IPv6 (all) ----
test_name="Script disables IPv6 for all interfaces"
if grep -q 'net.ipv6.conf.all.disable_ipv6=1' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 23: Script disables IPv6 (default) ----
test_name="Script disables IPv6 for default interface"
if grep -q 'net.ipv6.conf.default.disable_ipv6=1' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 24: Script persists IPv6 disable via sysctl.d ----
test_name="Script persists IPv6 disable in sysctl.d"
if grep -q '99-disable-ipv6.conf' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 25-36: Script installs all required dependencies ----
deps=(whois bzip2 gzip coreutils wget screen nscd curl tmux gnupg perl dnsutils)
for dep in "${deps[@]}"; do
    test_name="Script installs dependency: $dep"
    if grep -q "$dep" "$SCRIPT_PATH"; then
        assert_eq "$test_name" "true" "true"
    else
        assert_eq "$test_name" "true" "false"
    fi
done

# ---- Test 37: Script sets DEBIAN_FRONTEND=noninteractive ----
test_name="Script sets DEBIAN_FRONTEND=noninteractive"
if grep -q 'DEBIAN_FRONTEND=noninteractive' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 38: Script runs apt-get update ----
test_name="Script runs apt-get update"
if grep -q 'apt-get update' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 39: Script uses --reinstall --fix-missing for dependencies ----
test_name="Script uses --reinstall --fix-missing for apt-get install"
if grep -q '\-\-reinstall.*\-\-fix-missing' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 40: Script accepts CF_API_KEY argument ----
test_name="Script accepts Cloudflare API Key as first argument"
if grep -q 'CF_API_KEY="${1:-}"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 41: Script saves CF API Key to /etc/xray/cloudflare ----
test_name="Script saves CF API Key to /etc/xray/cloudflare"
if grep -q '/etc/xray/cloudflare' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 42: Script sets proper permissions on cloudflare file ----
test_name="Script sets chmod 600 on cloudflare config"
if grep -q 'chmod 600 /etc/xray/cloudflare' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 43: Script creates /etc/xray directory ----
test_name="Script creates /etc/xray directory"
if grep -q '/etc/xray' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 44: Script creates /etc/hysteria2 directory ----
test_name="Script creates /etc/hysteria2 directory"
if grep -q '/etc/hysteria2' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 45: Script creates /etc/trojan-go directory ----
test_name="Script creates /etc/trojan-go directory"
if grep -q '/etc/trojan-go' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 46: Script creates /etc/nginx/conf.d directory ----
test_name="Script creates /etc/nginx/conf.d directory"
if grep -q '/etc/nginx/conf.d' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 47: Script creates /etc/haproxy directory ----
test_name="Script creates /etc/haproxy directory"
if grep -q '/etc/haproxy' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 48: Script creates /etc/openvpn directory ----
test_name="Script creates /etc/openvpn directory"
if grep -q '/etc/openvpn' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 49: Script creates /etc/softether directory ----
test_name="Script creates /etc/softether directory"
if grep -q '/etc/softether' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 50: Script creates /etc/stunnel directory ----
test_name="Script creates /etc/stunnel directory"
if grep -q '/etc/stunnel' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 51: Script creates /etc/squid directory ----
test_name="Script creates /etc/squid directory"
if grep -q '/etc/squid' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 52: Script creates /etc/fail2ban directory ----
test_name="Script creates /etc/fail2ban directory"
if grep -q '/etc/fail2ban' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 53: Script creates /etc/warp directory ----
test_name="Script creates /etc/warp directory"
if grep -q '/etc/warp' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 54: Script creates /home/vps/public_html directory ----
test_name="Script creates /home/vps/public_html directory"
if grep -q '/home/vps/public_html' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 55: Script creates /home/vps/backup directory ----
test_name="Script creates /home/vps/backup directory"
if grep -q '/home/vps/backup' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 56: Script creates rclone config directory ----
test_name="Script creates rclone config directory"
if grep -q '.config/rclone' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 57: Script sets timezone to Asia/Jakarta ----
test_name="Script sets timezone to Asia/Jakarta"
if grep -q 'Asia/Jakarta' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 58: Script checks for x86_64 architecture ----
test_name="Script checks for x86_64 architecture"
if grep -q 'x86_64' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 59: Script rejects OpenVZ ----
test_name="Script rejects OpenVZ virtualization"
if grep -q 'openvz' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 60: Script creates /etc/xray/domain file ----
test_name="Script creates /etc/xray/domain file"
if grep -q '/etc/xray/domain' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 61: Script logs to syslog.log ----
test_name="Script writes to log file"
if grep -q 'LOG_FILE' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 62: Script creates /etc/cron.d directory ----
test_name="Script creates /etc/cron.d directory"
if grep -q '/etc/cron.d' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 63: Script creates /etc/vnstat directory ----
test_name="Script creates /etc/vnstat directory"
if grep -q '/etc/vnstat' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 64: Script passes shellcheck ----
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

# ---- Test 65: Script header mentions Tahap 2 ----
test_name="Script header mentions Tahap 2"
if grep -q 'Tahap 2' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
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
