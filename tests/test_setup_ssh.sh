#!/bin/bash
# ============================================================================
# Test suite untuk setup-ssh.sh — Tahap 4: SSH Tunneling, HAProxy & Services
# ============================================================================
# Menjalankan pengujian unit untuk fungsi-fungsi di setup-ssh.sh
# tanpa menjalankan operasi berbahaya (install/service management).
#
# Penggunaan:
#   chmod +x tests/test_setup_ssh.sh
#   ./tests/test_setup_ssh.sh
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/setup-ssh.sh"

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
echo "  Test Suite: setup-ssh.sh (Tahap 4)"
echo "=============================================="
echo ""

# ===========================================================================
# Section 1: Basic File Tests
# ===========================================================================

# ---- Test 1: File setup-ssh.sh ada ----
test_name="setup-ssh.sh file exists"
if [[ -f "$SCRIPT_PATH" ]]; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 2: File setup-ssh.sh executable ----
test_name="setup-ssh.sh is executable"
if [[ -x "$SCRIPT_PATH" ]]; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 3: Bash syntax valid ----
test_name="setup-ssh.sh has valid bash syntax"
if bash -n "$SCRIPT_PATH" 2>/dev/null; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 4: Shebang correct ----
test_name="setup-ssh.sh has correct shebang (#!/bin/bash)"
first_line=$(head -1 "$SCRIPT_PATH")
assert_eq "$test_name" "#!/bin/bash" "$first_line"

# ---- Test 5: Script header mentions Tahap 4 ----
test_name="Script header mentions Tahap 4"
if grep -q 'Tahap 4' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 2: Variables & Constants
# ===========================================================================

# ---- Test 6: LOG_FILE is defined ----
test_name="LOG_FILE variable is set to /root/syslog.log"
if grep -q 'LOG_FILE="/root/syslog.log"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 7: OPENSSH_PORT defined ----
test_name="OPENSSH_PORT is defined as 22"
if grep -q 'OPENSSH_PORT=22' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 8: DROPBEAR_PORTS defined ----
test_name="DROPBEAR_PORTS includes 80 143 443"
if grep -q 'DROPBEAR_PORTS="80 143 443"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 9: DROPBEAR_STUNNEL_PORT defined ----
test_name="DROPBEAR_STUNNEL_PORT is defined as 446"
if grep -q 'DROPBEAR_STUNNEL_PORT=446' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 10: DROPBEAR_STUNNEL_WS_PORT defined ----
test_name="DROPBEAR_STUNNEL_WS_PORT is defined as 445"
if grep -q 'DROPBEAR_STUNNEL_WS_PORT=445' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 11: SSHWS_HTTP_PORT defined ----
test_name="SSHWS_HTTP_PORT is defined as 8880"
if grep -q 'SSHWS_HTTP_PORT=8880' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 12: SQUID_PORT1 defined ----
test_name="SQUID_PORT1 is defined as 3128"
if grep -q 'SQUID_PORT1=3128' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 13: SQUID_PORT2 defined ----
test_name="SQUID_PORT2 is defined as 8080"
if grep -q 'SQUID_PORT2=8080' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 14: OHP_SSH_PORT defined ----
test_name="OHP_SSH_PORT is defined as 2083"
if grep -q 'OHP_SSH_PORT=2083' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 15: OHP_DROPBEAR_PORT defined ----
test_name="OHP_DROPBEAR_PORT is defined as 2084"
if grep -q 'OHP_DROPBEAR_PORT=2084' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 16: OHP_OPENVPN_PORT defined ----
test_name="OHP_OPENVPN_PORT is defined as 2087"
if grep -q 'OHP_OPENVPN_PORT=2087' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 17: BADVPN_PORTS defined ----
test_name="BADVPN_PORTS includes 7100-7900"
if grep -q 'BADVPN_PORTS="7100 7200 7300 7400 7500 7600 7700 7800 7900"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 18: STUNNEL_CONF path defined ----
test_name="STUNNEL_CONF path is /etc/stunnel/stunnel.conf"
if grep -q 'STUNNEL_CONF="/etc/stunnel/stunnel.conf"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 19: HAPROXY_CONF path defined ----
test_name="HAPROXY_CONF path is /etc/haproxy/haproxy.cfg"
if grep -q 'HAPROXY_CONF="/etc/haproxy/haproxy.cfg"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 20: SQUID_CONF path defined ----
test_name="SQUID_CONF path is /etc/squid/squid.conf"
if grep -q 'SQUID_CONF="/etc/squid/squid.conf"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 21: FAIL2BAN_CONF path defined ----
test_name="FAIL2BAN_CONF path is /etc/fail2ban/jail.local"
if grep -q 'FAIL2BAN_CONF="/etc/fail2ban/jail.local"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 22: BANNER_FILE path defined ----
test_name="BANNER_FILE path is /etc/banner"
if grep -q 'BANNER_FILE="/etc/banner"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 23: SSHWS_BIN path defined ----
test_name="SSHWS_BIN path is /usr/local/bin/sshws"
if grep -q 'SSHWS_BIN="/usr/local/bin/sshws"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 24: BADVPN_BIN path defined ----
test_name="BADVPN_BIN path is /usr/local/bin/badvpn-udpgw"
if grep -q 'BADVPN_BIN="/usr/local/bin/badvpn-udpgw"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 25: OHP_BIN path defined ----
test_name="OHP_BIN path is /usr/local/bin/ohp"
if grep -q 'OHP_BIN="/usr/local/bin/ohp"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 3: Prerequisite Check Functions
# ===========================================================================

# ---- Test 26: Script contains check_root function ----
test_name="Script contains check_root function"
if grep -q 'check_root()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 27: Script contains check_os function ----
test_name="Script contains check_os function"
if grep -q 'check_os()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 28: Script contains check_arch function ----
test_name="Script contains check_arch function"
if grep -q 'check_arch()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 29: Script contains check_virt function ----
test_name="Script contains check_virt function"
if grep -q 'check_virt()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 30: Script contains check_tahap3 function ----
test_name="Script contains check_tahap3 function"
if grep -q 'check_tahap3()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 31-33: Script supports Ubuntu versions ----
for ver in "20.04" "22.04" "24.04"; do
    test_name="Script supports Ubuntu $ver"
    if grep -q "$ver" "$SCRIPT_PATH"; then
        assert_eq "$test_name" "true" "true"
    else
        assert_eq "$test_name" "true" "false"
    fi
done

# ---- Test 34-36: Script supports Debian versions ----
for ver in 10 11 12; do
    test_name="Script supports Debian $ver"
    if grep -A5 'debian)' "$SCRIPT_PATH" | grep -q "$ver"; then
        assert_eq "$test_name" "true" "true"
    else
        assert_eq "$test_name" "true" "false"
    fi
done

# ---- Test 37: Script checks for x86_64 architecture ----
test_name="Script checks for x86_64 architecture"
if grep -q 'x86_64' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 38: Script rejects OpenVZ ----
test_name="Script rejects OpenVZ virtualization"
if grep -q 'openvz' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 39: Script verifies Tahap 3 completion ----
test_name="Script checks for domain file from Tahap 3"
if grep -q '/etc/xray/domain' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 40: Script checks for Nginx installation ----
test_name="Script verifies Nginx is installed"
if grep -q 'command -v nginx' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 41: Script checks for Xray installation ----
test_name="Script verifies Xray is installed"
if grep -q 'command -v xray' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 4: Dropbear SSH Functions
# ===========================================================================

# ---- Test 42: Script contains install_dropbear function ----
test_name="Script contains install_dropbear function"
if grep -q 'install_dropbear()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 43: Script contains configure_dropbear function ----
test_name="Script contains configure_dropbear function"
if grep -q 'configure_dropbear()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 44: Script contains start_dropbear function ----
test_name="Script contains start_dropbear function"
if grep -q 'start_dropbear()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 45: Dropbear configured with multi-port ----
test_name="Dropbear configured with ports 80 143 443"
if grep -q '\-p 80 -p 143 -p 443' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 46: Dropbear uses banner ----
test_name="Dropbear configured with /etc/banner"
if grep -q 'DROPBEAR_BANNER="/etc/banner"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 47: Dropbear generates host keys ----
test_name="Script generates Dropbear host keys"
if grep -q 'dropbearkey' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 48: Script installs dropbear via apt ----
test_name="Script installs dropbear via apt-get"
if grep -q 'apt-get install.*dropbear' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 5: Stunnel Functions
# ===========================================================================

# ---- Test 49: Script contains install_stunnel function ----
test_name="Script contains install_stunnel function"
if grep -q 'install_stunnel()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 50: Script contains configure_stunnel function ----
test_name="Script contains configure_stunnel function"
if grep -q 'configure_stunnel()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 51: Script contains start_stunnel function ----
test_name="Script contains start_stunnel function"
if grep -q 'start_stunnel()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 52: Stunnel config uses SSL certificate ----
test_name="Stunnel config references SSL certificate"
if grep -q 'XRAY_CERT' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 53: Stunnel config uses SSL key ----
test_name="Stunnel config references SSL key"
if grep -q 'XRAY_KEY' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 54: Stunnel has SSH section (port 446) ----
test_name="Stunnel config has [ssh] section accepting port 446"
if grep -q '\[ssh\]' "$SCRIPT_PATH" && grep -q 'accept.*446' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 55: Stunnel has SSH-WS section (port 445) ----
test_name="Stunnel config has [ssh-ws] section accepting port 445"
if grep -q '\[ssh-ws\]' "$SCRIPT_PATH" && grep -q 'accept.*445' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 56: Stunnel installs stunnel4 ----
test_name="Script installs stunnel4 via apt-get"
if grep -q 'apt-get install.*stunnel4' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 57: Stunnel enables ENABLED=1 ----
test_name="Script enables stunnel4 (ENABLED=1)"
if grep -q 'ENABLED=1' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 6: SSH WebSocket Handler
# ===========================================================================

# ---- Test 58: Script contains create_sshws function ----
test_name="Script contains create_sshws function"
if grep -q 'create_sshws()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 59: SSH WS handler is Python3 ----
test_name="SSH WebSocket handler is Python3 script"
if grep -q 'python3' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 60: SSH WS uses DEFAULT_HOST 127.0.0.1:143 ----
test_name="SSH WS default host is 127.0.0.1:143 (Dropbear)"
if grep -q "DEFAULT_HOST = '127.0.0.1:143'" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 61: SSH WS sends 101 Switching Protocols ----
test_name="SSH WS sends HTTP 101 Switching Protocols"
if grep -q '101 Switching Protocols' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 62: SSH WS has systemd service ----
test_name="SSH WS has systemd service file"
if grep -q 'sshws.service' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 63: SSH WS is executable (chmod 755) ----
test_name="SSH WS script set to executable"
if grep -q 'chmod 755.*SSHWS_BIN' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 7: HAProxy Functions
# ===========================================================================

# ---- Test 64: Script contains install_haproxy function ----
test_name="Script contains install_haproxy function"
if grep -q 'install_haproxy()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 65: Script contains configure_haproxy function ----
test_name="Script contains configure_haproxy function"
if grep -q 'configure_haproxy()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 66: Script contains start_haproxy function ----
test_name="Script contains start_haproxy function"
if grep -q 'start_haproxy()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 67: HAProxy has frontend for port 443 ----
test_name="HAProxy has frontend for port 443 (HTTPS)"
if grep -q 'bind \*:443' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 68: HAProxy has frontend for port 80 ----
test_name="HAProxy has frontend for port 80 (HTTP)"
if grep -q 'bind \*:80' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 69: HAProxy routes to Nginx HTTPS on port 663 ----
test_name="HAProxy backend routes to Nginx HTTPS (port 663)"
if grep -q '127.0.0.1:663' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 70: HAProxy routes to Nginx HTTP on port 81 ----
test_name="HAProxy backend routes to Nginx HTTP (port 81)"
if grep -q '127.0.0.1:81' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 71: HAProxy has TLS SNI inspection ----
test_name="HAProxy inspects TLS SNI"
if grep -q 'req_ssl_hello_type' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 72: HAProxy installs via apt ----
test_name="Script installs haproxy via apt-get"
if grep -q 'apt-get install.*haproxy' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 73: HAProxy has Dropbear backend ----
test_name="HAProxy has Dropbear backend"
if grep -q 'bk_dropbear' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 74: HAProxy has SSH WS backend ----
test_name="HAProxy has SSH WebSocket backend"
if grep -q 'bk_sshws' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 8: Squid Functions
# ===========================================================================

# ---- Test 75: Script contains install_squid function ----
test_name="Script contains install_squid function"
if grep -q 'install_squid()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 76: Script contains configure_squid function ----
test_name="Script contains configure_squid function"
if grep -q 'configure_squid()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 77: Script contains start_squid function ----
test_name="Script contains start_squid function"
if grep -q 'start_squid()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 78: Squid config has port 3128 ----
test_name="Squid config has http_port 3128"
if grep -q 'http_port.*3128' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 79: Squid config has port 8080 ----
test_name="Squid config has http_port 8080"
if grep -q 'http_port.*8080' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 80: Squid has ACL rules ----
test_name="Squid config has ACL rules"
if grep -q 'acl.*localhost' "$SCRIPT_PATH" && grep -q 'acl.*SSL_ports' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 81: Squid installs via apt ----
test_name="Script installs squid via apt-get"
if grep -q 'apt-get install.*squid' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 9: BadVPN/UDPGW Functions
# ===========================================================================

# ---- Test 82: Script contains install_badvpn function ----
test_name="Script contains install_badvpn function"
if grep -q 'install_badvpn()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 83: Script contains configure_badvpn function ----
test_name="Script contains configure_badvpn function"
if grep -q 'configure_badvpn()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 84: Script contains start_badvpn function ----
test_name="Script contains start_badvpn function"
if grep -q 'start_badvpn()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 85: BadVPN creates systemd services ----
test_name="BadVPN creates systemd services for each port"
if grep -q 'badvpn-udpgw-.*\.service' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 86: BadVPN uses --max-clients ----
test_name="BadVPN configured with --max-clients"
if grep -q '\-\-max-clients' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 87: BadVPN uses --listen-addr 127.0.0.1 ----
test_name="BadVPN listens on 127.0.0.1 (localhost only)"
if grep -q '\-\-listen-addr 127.0.0.1' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 10: Fail2ban Functions
# ===========================================================================

# ---- Test 88: Script contains install_fail2ban function ----
test_name="Script contains install_fail2ban function"
if grep -q 'install_fail2ban()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 89: Script contains configure_fail2ban function ----
test_name="Script contains configure_fail2ban function"
if grep -q 'configure_fail2ban()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 90: Script contains start_fail2ban function ----
test_name="Script contains start_fail2ban function"
if grep -q 'start_fail2ban()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 91: Fail2ban config has sshd jail ----
test_name="Fail2ban config has [sshd] jail"
if grep -q '\[sshd\]' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 92: Fail2ban config has dropbear jail ----
test_name="Fail2ban config has [dropbear] jail"
if grep -q '\[dropbear\]' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 93: Fail2ban has bantime setting ----
test_name="Fail2ban has bantime configuration"
if grep -q 'bantime' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 94: Fail2ban installs via apt ----
test_name="Script installs fail2ban via apt-get"
if grep -q 'apt-get install.*fail2ban' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 11: OHP Functions
# ===========================================================================

# ---- Test 95: Script contains install_ohp function ----
test_name="Script contains install_ohp function"
if grep -q 'install_ohp()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 96: Script contains configure_ohp function ----
test_name="Script contains configure_ohp function"
if grep -q 'configure_ohp()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 97: Script contains start_ohp function ----
test_name="Script contains start_ohp function"
if grep -q 'start_ohp()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 98: OHP has SSH service (port 2083) ----
test_name="OHP has service for OpenSSH (port 2083)"
if grep -q 'ohp-ssh.service' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 99: OHP has Dropbear service (port 2084) ----
test_name="OHP has service for Dropbear (port 2084)"
if grep -q 'ohp-dropbear.service' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 100: OHP has OpenVPN service (port 2087) ----
test_name="OHP has service for OpenVPN (port 2087)"
if grep -q 'ohp-openvpn.service' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 101: OHP uses Squid as proxy ----
test_name="OHP uses Squid proxy (port 3128)"
if grep -q '\-proxy 127.0.0.1.*3128' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 12: SSH Banner
# ===========================================================================

# ---- Test 102: Script contains setup_banner function ----
test_name="Script contains setup_banner function"
if grep -q 'setup_banner()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 103: Banner creates /etc/banner ----
test_name="Banner writes to /etc/banner"
if grep -q 'BANNER_FILE' "$SCRIPT_PATH" && grep -q '/etc/banner' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 104: Banner content has VPN branding ----
test_name="Banner content has VPN TUNNELING AUTOSCRIPT branding"
if grep -q 'VPN TUNNELING AUTOSCRIPT' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 105: OpenSSH configured with Banner ----
test_name="OpenSSH sshd_config gets Banner setting"
if grep -q 'Banner.*BANNER_FILE' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 13: Cronjobs
# ===========================================================================

# ---- Test 106: Script contains setup_cronjobs function ----
test_name="Script contains setup_cronjobs function"
if grep -q 'setup_cronjobs()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 107: Script creates auto-clear-log cronjob ----
test_name="Script creates /etc/cron.d/auto-clear-log"
if grep -q '/etc/cron.d/auto-clear-log' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 108: Script creates auto-delete-expired cronjob ----
test_name="Script creates /etc/cron.d/auto-delete-expired"
if grep -q '/etc/cron.d/auto-delete-expired' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 109: Auto clear runs every 10 minutes ----
test_name="Auto clear log runs every 10 minutes (*/10)"
if grep -q '\*/10' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 110: Auto delete runs daily at midnight ----
test_name="Auto delete expired runs daily at 00:00"
if grep -q '0 0 \* \* \*' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 111: Script creates auto-clear-log utility ----
test_name="Script creates /usr/local/bin/auto-clear-log"
if grep -q '/usr/local/bin/auto-clear-log' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 112: Script creates auto-delete-expired utility ----
test_name="Script creates /usr/local/bin/auto-delete-expired"
if grep -q '/usr/local/bin/auto-delete-expired' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 113: Auto clear clears Xray access log ----
test_name="Auto clear clears /var/log/xray/access.log"
if grep -q '/var/log/xray/access.log' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 114: Auto clear clears Nginx access log ----
test_name="Auto clear clears /var/log/nginx/access.log"
if grep -q '/var/log/nginx/access.log' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 14: Main Function & Flow
# ===========================================================================

# ---- Test 115: Script contains main function ----
test_name="Script contains main function"
if grep -q 'main()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 116: Script logs to syslog.log ----
test_name="Script writes to log file"
if grep -q 'LOG_FILE' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 117: Main calls all install functions ----
test_name="Main calls install_dropbear"
if grep -q 'install_dropbear' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 118: Main calls Stunnel functions ----
test_name="Main calls install_stunnel"
if grep -q 'install_stunnel' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 119: Main calls SSH WS function ----
test_name="Main calls create_sshws"
if grep -q 'create_sshws' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 120: Main calls HAProxy functions ----
test_name="Main calls install_haproxy"
if grep -q 'install_haproxy' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 121: Main calls Fail2ban functions ----
test_name="Main calls install_fail2ban"
if grep -q 'install_fail2ban' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 122: Main calls setup_banner ----
test_name="Main calls setup_banner"
if grep -q 'setup_banner' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 123: Main calls setup_cronjobs ----
test_name="Main calls setup_cronjobs"
if grep -q 'setup_cronjobs' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 124: Script sets DEBIAN_FRONTEND=noninteractive ----
test_name="Script sets DEBIAN_FRONTEND=noninteractive"
if grep -q 'DEBIAN_FRONTEND=noninteractive' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 125: Script enables systemd services ----
test_name="Script enables systemd services (systemctl enable)"
if grep -q 'systemctl enable' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 126: Script passes shellcheck ----
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
