#!/bin/bash
# ============================================================================
# Test suite untuk setup-protocol.sh — Tahap 5: Protokol Tambahan
# ============================================================================
# Menjalankan pengujian unit untuk fungsi-fungsi di setup-protocol.sh
# tanpa menjalankan operasi berbahaya (install/service management).
#
# Penggunaan:
#   chmod +x tests/test_setup_protocol.sh
#   ./tests/test_setup_protocol.sh
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/setup-protocol.sh"

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
echo "  Test Suite: setup-protocol.sh (Tahap 5)"
echo "=============================================="
echo ""

# ===========================================================================
# Section 1: Basic File Tests
# ===========================================================================

# ---- Test 1: File setup-protocol.sh ada ----
test_name="setup-protocol.sh file exists"
if [[ -f "$SCRIPT_PATH" ]]; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 2: File setup-protocol.sh executable ----
test_name="setup-protocol.sh is executable"
if [[ -x "$SCRIPT_PATH" ]]; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 3: Bash syntax valid ----
test_name="setup-protocol.sh has valid bash syntax"
if bash -n "$SCRIPT_PATH" 2>/dev/null; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 4: Shebang correct ----
test_name="setup-protocol.sh has correct shebang (#!/bin/bash)"
first_line=$(head -1 "$SCRIPT_PATH")
assert_eq "$test_name" "#!/bin/bash" "$first_line"

# ---- Test 5: Script header mentions Tahap 5 ----
test_name="Script header mentions Tahap 5"
if grep -q 'Tahap 5' "$SCRIPT_PATH"; then
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

# ---- Test 8: XRAY_KEY path defined ----
test_name="XRAY_KEY is defined as /etc/xray/xray.key"
if grep -q 'XRAY_KEY="/etc/xray/xray.key"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 9: DOMAIN_FILE path defined ----
test_name="DOMAIN_FILE is defined as /etc/xray/domain"
if grep -q 'DOMAIN_FILE="/etc/xray/domain"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 3: Variables — Hysteria2
# ===========================================================================

# ---- Test 10: HYSTERIA2_PORT defined ----
test_name="HYSTERIA2_PORT is defined as 443"
if grep -q 'HYSTERIA2_PORT=443' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 11: HYSTERIA2_CONFIG_DIR defined ----
test_name="HYSTERIA2_CONFIG_DIR is /etc/hysteria2"
if grep -q 'HYSTERIA2_CONFIG_DIR="/etc/hysteria2"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 12: HYSTERIA2_CONFIG defined ----
test_name="HYSTERIA2_CONFIG is /etc/hysteria2/config.yaml"
if grep -q 'HYSTERIA2_CONFIG=.*config.yaml' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 13: HYSTERIA2_BIN defined ----
test_name="HYSTERIA2_BIN is /usr/local/bin/hysteria"
if grep -q 'HYSTERIA2_BIN="/usr/local/bin/hysteria"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 4: Variables — Trojan-Go
# ===========================================================================

# ---- Test 14: TROJAN_GO_PORT_WS defined ----
test_name="TROJAN_GO_PORT_WS is defined as 443"
if grep -q 'TROJAN_GO_PORT_WS=443' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 15: TROJAN_GO_CONFIG_DIR defined ----
test_name="TROJAN_GO_CONFIG_DIR is /etc/trojan-go"
if grep -q 'TROJAN_GO_CONFIG_DIR="/etc/trojan-go"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 16: TROJAN_GO_CONFIG defined ----
test_name="TROJAN_GO_CONFIG is /etc/trojan-go/config.json"
if grep -q 'TROJAN_GO_CONFIG=.*config.json' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 17: TROJAN_GO_BIN defined ----
test_name="TROJAN_GO_BIN is /usr/local/bin/trojan-go"
if grep -q 'TROJAN_GO_BIN="/usr/local/bin/trojan-go"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 5: Variables — OpenVPN
# ===========================================================================

# ---- Test 18: OPENVPN_TCP_PORT1 defined ----
test_name="OPENVPN_TCP_PORT1 is defined as 1194"
if grep -q 'OPENVPN_TCP_PORT1=1194' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 19: OPENVPN_TCP_PORT2 defined ----
test_name="OPENVPN_TCP_PORT2 is defined as 2294"
if grep -q 'OPENVPN_TCP_PORT2=2294' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 20: OPENVPN_UDP_PORT1 defined ----
test_name="OPENVPN_UDP_PORT1 is defined as 2200"
if grep -q 'OPENVPN_UDP_PORT1=2200' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 21: OPENVPN_UDP_PORT2 defined ----
test_name="OPENVPN_UDP_PORT2 is defined as 2295"
if grep -q 'OPENVPN_UDP_PORT2=2295' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 22: OPENVPN_STUNNEL_PORT defined ----
test_name="OPENVPN_STUNNEL_PORT is defined as 2296"
if grep -q 'OPENVPN_STUNNEL_PORT=2296' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 23: OPENVPN_CONFIG_DIR defined ----
test_name="OPENVPN_CONFIG_DIR is /etc/openvpn"
if grep -q 'OPENVPN_CONFIG_DIR="/etc/openvpn"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 24: OPENVPN_STUNNEL_CONF defined ----
test_name="OPENVPN_STUNNEL_CONF is /etc/stunnel/stunnel-openvpn.conf"
if grep -q 'OPENVPN_STUNNEL_CONF="/etc/stunnel/stunnel-openvpn.conf"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 6: Variables — SoftEther VPN
# ===========================================================================

# ---- Test 25: SOFTETHER_REMOTE_PORT defined ----
test_name="SOFTETHER_REMOTE_PORT is defined as 5555"
if grep -q 'SOFTETHER_REMOTE_PORT=5555' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 26: SOFTETHER_SSTP_PORT defined ----
test_name="SOFTETHER_SSTP_PORT is defined as 4433"
if grep -q 'SOFTETHER_SSTP_PORT=4433' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 27: SOFTETHER_OPENVPN_TCP_PORT defined ----
test_name="SOFTETHER_OPENVPN_TCP_PORT is defined as 1194"
if grep -q 'SOFTETHER_OPENVPN_TCP_PORT=1194' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 28: SOFTETHER_OPENVPN_TLS_PORT defined ----
test_name="SOFTETHER_OPENVPN_TLS_PORT is defined as 1195"
if grep -q 'SOFTETHER_OPENVPN_TLS_PORT=1195' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 29: SOFTETHER_L2TP_PORT1 defined ----
test_name="SOFTETHER_L2TP_PORT1 is defined as 500"
if grep -q 'SOFTETHER_L2TP_PORT1=500' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 30: SOFTETHER_L2TP_PORT2 defined ----
test_name="SOFTETHER_L2TP_PORT2 is defined as 1701"
if grep -q 'SOFTETHER_L2TP_PORT2=1701' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 31: SOFTETHER_L2TP_PORT3 defined ----
test_name="SOFTETHER_L2TP_PORT3 is defined as 4500"
if grep -q 'SOFTETHER_L2TP_PORT3=4500' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 32: SOFTETHER_INSTALL_DIR defined ----
test_name="SOFTETHER_INSTALL_DIR is /usr/local/softether"
if grep -q 'SOFTETHER_INSTALL_DIR="/usr/local/softether"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 33: SOFTETHER_BIN defined ----
test_name="SOFTETHER_BIN is /usr/local/softether/vpnserver"
if grep -q 'SOFTETHER_BIN="/usr/local/softether/vpnserver"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 7: Variables — WARP
# ===========================================================================

# ---- Test 34: WARP_PORT defined ----
test_name="WARP_PORT is defined as 51820"
if grep -q 'WARP_PORT=51820' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 35: WARP_CONFIG_DIR defined ----
test_name="WARP_CONFIG_DIR is /etc/warp"
if grep -q 'WARP_CONFIG_DIR="/etc/warp"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 36: WARP_CONFIG defined ----
test_name="WARP_CONFIG is /etc/warp/warp.conf"
if grep -q 'WARP_CONFIG=.*warp.conf' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 8: Variables — SlowDNS/DNSTT
# ===========================================================================

# ---- Test 37: SLOWDNS_DNS_PORT defined ----
test_name="SLOWDNS_DNS_PORT is defined as 53"
if grep -q 'SLOWDNS_DNS_PORT=53' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 38: SLOWDNS_ALT_PORT defined ----
test_name="SLOWDNS_ALT_PORT is defined as 5300"
if grep -q 'SLOWDNS_ALT_PORT=5300' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 39: SLOWDNS_SSH_PORT defined ----
test_name="SLOWDNS_SSH_PORT is defined as 2222"
if grep -q 'SLOWDNS_SSH_PORT=2222' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 40: SLOWDNS_BIN defined ----
test_name="SLOWDNS_BIN is /usr/local/bin/dns-server"
if grep -q 'SLOWDNS_BIN="/usr/local/bin/dns-server"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 41: SLOWDNS_KEY_DIR defined ----
test_name="SLOWDNS_KEY_DIR is /etc/slowdns"
if grep -q 'SLOWDNS_KEY_DIR="/etc/slowdns"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 9: Variables — UDP Custom
# ===========================================================================

# ---- Test 42: UDP_CUSTOM_BIN defined ----
test_name="UDP_CUSTOM_BIN is /usr/local/bin/udp-custom"
if grep -q 'UDP_CUSTOM_BIN="/usr/local/bin/udp-custom"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 43: UDP_CUSTOM_CONFIG defined ----
test_name="UDP_CUSTOM_CONFIG is /etc/udp-custom/config.json"
if grep -q 'UDP_CUSTOM_CONFIG=.*/etc/udp-custom/config.json' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 10: Prerequisite Check Functions
# ===========================================================================

# ---- Test 44: Script contains check_root function ----
test_name="Script contains check_root function"
if grep -q 'check_root()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 45: Script contains check_os function ----
test_name="Script contains check_os function"
if grep -q 'check_os()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 46: Script contains check_arch function ----
test_name="Script contains check_arch function"
if grep -q 'check_arch()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 47: Script contains check_virt function ----
test_name="Script contains check_virt function"
if grep -q 'check_virt()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 48: Script contains check_tahap4 function ----
test_name="Script contains check_tahap4 function"
if grep -q 'check_tahap4()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 49-51: Script supports Ubuntu versions ----
for ver in "20.04" "22.04" "24.04"; do
    test_name="Script supports Ubuntu $ver"
    if grep -q "$ver" "$SCRIPT_PATH"; then
        assert_eq "$test_name" "true" "true"
    else
        assert_eq "$test_name" "true" "false"
    fi
done

# ---- Test 52-54: Script supports Debian versions ----
for ver in 10 11 12; do
    test_name="Script supports Debian $ver"
    if grep -A5 'debian)' "$SCRIPT_PATH" | grep -q "$ver"; then
        assert_eq "$test_name" "true" "true"
    else
        assert_eq "$test_name" "true" "false"
    fi
done

# ---- Test 55: Script checks for x86_64 architecture ----
test_name="Script checks for x86_64 architecture"
if grep -q 'x86_64' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 56: Script rejects OpenVZ ----
test_name="Script rejects OpenVZ virtualization"
if grep -q 'openvz' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 57: Script checks for domain file from previous stages ----
test_name="Script checks for domain file from previous stages"
if grep -q '/etc/xray/domain' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 58: Script verifies Nginx is installed ----
test_name="Script verifies Nginx is installed"
if grep -q 'command -v nginx' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 59: Script verifies Xray is installed ----
test_name="Script verifies Xray is installed"
if grep -q 'command -v xray' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 11: Hysteria2 Functions
# ===========================================================================

# ---- Test 60: Script contains install_hysteria2 function ----
test_name="Script contains install_hysteria2 function"
if grep -q 'install_hysteria2()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 61: Script contains configure_hysteria2 function ----
test_name="Script contains configure_hysteria2 function"
if grep -q 'configure_hysteria2()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 62: Script contains create_hysteria2_service function ----
test_name="Script contains create_hysteria2_service function"
if grep -q 'create_hysteria2_service()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 63: Script contains start_hysteria2 function ----
test_name="Script contains start_hysteria2 function"
if grep -q 'start_hysteria2()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 64: Hysteria2 config references QUIC/UDP ----
test_name="Hysteria2 config uses QUIC protocol"
if grep -q 'quic' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 65: Hysteria2 downloads from apernet/hysteria ----
test_name="Hysteria2 downloads from apernet/hysteria GitHub"
if grep -q 'apernet/hysteria' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 66: Hysteria2 config references SSL cert ----
test_name="Hysteria2 config references SSL certificate"
if grep -q 'cert.*XRAY_CERT\|XRAY_CERT.*cert\|cert:.*xray.crt' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 67: Hysteria2 systemd service file created ----
test_name="Hysteria2 systemd service file path correct"
if grep -q 'hysteria2.service' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 68: Hysteria2 uses bandwidth settings ----
test_name="Hysteria2 config has bandwidth settings"
if grep -q 'bandwidth' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 12: Trojan-Go Functions
# ===========================================================================

# ---- Test 69: Script contains install_trojan_go function ----
test_name="Script contains install_trojan_go function"
if grep -q 'install_trojan_go()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 70: Script contains configure_trojan_go function ----
test_name="Script contains configure_trojan_go function"
if grep -q 'configure_trojan_go()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 71: Script contains create_trojan_go_service function ----
test_name="Script contains create_trojan_go_service function"
if grep -q 'create_trojan_go_service()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 72: Script contains start_trojan_go function ----
test_name="Script contains start_trojan_go function"
if grep -q 'start_trojan_go()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 73: Trojan-Go downloads from p4gefau1t/trojan-go ----
test_name="Trojan-Go downloads from p4gefau1t/trojan-go GitHub"
if grep -q 'p4gefau1t/trojan-go' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 74: Trojan-Go config has WebSocket support ----
test_name="Trojan-Go config has WebSocket support"
if grep -q 'websocket' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 75: Trojan-Go config has SSL/TLS section ----
test_name="Trojan-Go config has SSL/TLS section"
if grep -q '"ssl"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 76: Trojan-Go config uses /trojan-go path ----
test_name="Trojan-Go config uses /trojan-go WebSocket path"
if grep -q '/trojan-go' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 77: Trojan-Go systemd service created ----
test_name="Trojan-Go systemd service file path correct"
if grep -q 'trojan-go.service' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 13: OpenVPN Functions
# ===========================================================================

# ---- Test 78: Script contains install_openvpn function ----
test_name="Script contains install_openvpn function"
if grep -q 'install_openvpn()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 79: Script contains setup_openvpn_pki function ----
test_name="Script contains setup_openvpn_pki function"
if grep -q 'setup_openvpn_pki()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 80: Script contains configure_openvpn_tcp function ----
test_name="Script contains configure_openvpn_tcp function"
if grep -q 'configure_openvpn_tcp()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 81: Script contains configure_openvpn_udp function ----
test_name="Script contains configure_openvpn_udp function"
if grep -q 'configure_openvpn_udp()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 82: Script contains configure_openvpn_stunnel function ----
test_name="Script contains configure_openvpn_stunnel function"
if grep -q 'configure_openvpn_stunnel()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 83: Script contains create_openvpn_services function ----
test_name="Script contains create_openvpn_services function"
if grep -q 'create_openvpn_services()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 84: Script contains start_openvpn function ----
test_name="Script contains start_openvpn function"
if grep -q 'start_openvpn()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 85: OpenVPN TCP config uses port 1194 ----
test_name="OpenVPN TCP config uses port 1194"
if grep -q 'port.*1194\|1194.*port' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 86: OpenVPN TCP2 config uses port 2294 ----
test_name="OpenVPN TCP2 config uses port 2294"
if grep -q '2294' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 87: OpenVPN UDP config uses port 2200 ----
test_name="OpenVPN UDP config uses port 2200"
if grep -q '2200' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 88: OpenVPN UDP2 config uses port 2295 ----
test_name="OpenVPN UDP2 config uses port 2295"
if grep -q '2295' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 89: OpenVPN installs via apt-get ----
test_name="Script installs openvpn via apt-get"
if grep -q 'apt-get install.*openvpn' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 90: OpenVPN installs easy-rsa ----
test_name="Script installs easy-rsa via apt-get"
if grep -q 'easy-rsa' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 91: OpenVPN uses AES-256-GCM cipher ----
test_name="OpenVPN config uses AES-256-GCM cipher"
if grep -q 'AES-256-GCM' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 92: OpenVPN TCP server config file path ----
test_name="OpenVPN TCP server config is server-tcp.conf"
if grep -q 'server-tcp.conf' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 93: OpenVPN UDP server config file path ----
test_name="OpenVPN UDP server config is server-udp.conf"
if grep -q 'server-udp.conf' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 94: OpenVPN Stunnel port 2296 ----
test_name="OpenVPN Stunnel configured with port 2296"
if grep -q '2296' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 95: OpenVPN enables IP forwarding ----
test_name="Script enables IP forwarding for OpenVPN"
if grep -q 'net.ipv4.ip_forward' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 96: OpenVPN systemd service openvpn-tcp ----
test_name="OpenVPN systemd service openvpn-tcp.service exists"
if grep -q 'openvpn-tcp.service' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 97: OpenVPN systemd service openvpn-udp ----
test_name="OpenVPN systemd service openvpn-udp.service exists"
if grep -q 'openvpn-udp.service' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 98: OpenVPN uses NAT/masquerade ----
test_name="Script configures NAT/masquerade for OpenVPN"
if grep -q 'MASQUERADE' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 14: SoftEther VPN Functions
# ===========================================================================

# ---- Test 99: Script contains install_softether function ----
test_name="Script contains install_softether function"
if grep -q 'install_softether()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 100: Script contains configure_softether function ----
test_name="Script contains configure_softether function"
if grep -q 'configure_softether()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 101: Script contains create_softether_service function ----
test_name="Script contains create_softether_service function"
if grep -q 'create_softether_service()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 102: Script contains start_softether function ----
test_name="Script contains start_softether function"
if grep -q 'start_softether()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 103: SoftEther references GitHub repository ----
test_name="Script references SoftEtherVPN GitHub"
if grep -q 'SoftEtherVPN' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 104: SoftEther systemd service created ----
test_name="SoftEther systemd service file created"
if grep -q 'softether-vpnserver.service' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 105: SoftEther installs build dependencies ----
test_name="Script installs build-essential for SoftEther"
if grep -q 'build-essential' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 106: SoftEther config mentions SSTP port 4433 ----
test_name="SoftEther config mentions SSTP port 4433"
if grep -q '4433' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 15: Cloudflare WARP Functions
# ===========================================================================

# ---- Test 107: Script contains install_warp function ----
test_name="Script contains install_warp function"
if grep -q 'install_warp()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 108: Script contains configure_warp function ----
test_name="Script contains configure_warp function"
if grep -q 'configure_warp()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 109: Script contains start_warp function ----
test_name="Script contains start_warp function"
if grep -q 'start_warp()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 110: WARP uses cloudflare repository ----
test_name="Script references Cloudflare package repository"
if grep -q 'cloudflareclient\|cloudflare-warp' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 111: WARP uses warp-cli ----
test_name="Script uses warp-cli for WARP management"
if grep -q 'warp-cli' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 112: WARP port 51820 referenced ----
test_name="WARP references port 51820"
if grep -q '51820' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 16: SlowDNS/DNSTT Functions
# ===========================================================================

# ---- Test 113: Script contains install_slowdns function ----
test_name="Script contains install_slowdns function"
if grep -q 'install_slowdns()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 114: Script contains configure_slowdns function ----
test_name="Script contains configure_slowdns function"
if grep -q 'configure_slowdns()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 115: Script contains create_slowdns_service function ----
test_name="Script contains create_slowdns_service function"
if grep -q 'create_slowdns_service()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 116: Script contains start_slowdns function ----
test_name="Script contains start_slowdns function"
if grep -q 'start_slowdns()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 117: SlowDNS generates keypair ----
test_name="SlowDNS generates keypair via openssl"
if grep -q 'openssl.*genrsa\|openssl.*rsa' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 118: SlowDNS systemd service created ----
test_name="SlowDNS systemd service file created"
if grep -q 'slowdns.service' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 119: SlowDNS references DNS port 5300 ----
test_name="SlowDNS references port 5300"
if grep -q '5300' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 17: UDP Custom Functions
# ===========================================================================

# ---- Test 120: Script contains install_udp_custom function ----
test_name="Script contains install_udp_custom function"
if grep -q 'install_udp_custom()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 121: Script contains configure_udp_custom function ----
test_name="Script contains configure_udp_custom function"
if grep -q 'configure_udp_custom()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 122: Script contains create_udp_custom_service function ----
test_name="Script contains create_udp_custom_service function"
if grep -q 'create_udp_custom_service()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 123: Script contains start_udp_custom function ----
test_name="Script contains start_udp_custom function"
if grep -q 'start_udp_custom()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 124: UDP Custom systemd service created ----
test_name="UDP Custom systemd service file created"
if grep -q 'udp-custom.service' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 125: UDP Custom config uses port range 1-65535 ----
test_name="UDP Custom config supports port range 1-65535"
if grep -q '1-65535' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 18: SSL Integration & Helper Functions
# ===========================================================================

# ---- Test 126: Script contains integrate_ssl function ----
test_name="Script contains integrate_ssl function"
if grep -q 'integrate_ssl()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 127: Script contains get_domain helper ----
test_name="Script contains get_domain helper function"
if grep -q 'get_domain()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 128: Script contains get_public_ip helper ----
test_name="Script contains get_public_ip helper function"
if grep -q 'get_public_ip()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 129: SSL integration checks for certificate existence ----
test_name="SSL integration checks for certificate file"
if grep -q 'XRAY_CERT' "$SCRIPT_PATH" && grep -q 'XRAY_KEY' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 130: Script creates SSL symlinks ----
test_name="Script creates SSL symlinks for other protocols"
if grep -q 'ln -sf.*vpn-autoscript' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 19: Main Function & Script Structure
# ===========================================================================

# ---- Test 131: Script contains main function ----
test_name="Script contains main function"
if grep -q 'main()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 132: Script calls main "$@" at end ----
test_name="Script calls main at end"
if grep -q 'main "\$@"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 133: Script contains print_header function ----
test_name="Script contains print_header function"
if grep -q 'print_header()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 134: Script contains log utility functions ----
test_name="Script contains log utility function"
if grep -q '^log()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 135: Script contains log_warn function ----
test_name="Script contains log_warn function"
if grep -q 'log_warn()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 136: Script contains log_error function ----
test_name="Script contains log_error function"
if grep -q 'log_error()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 137: Script contains update_nginx_config function ----
test_name="Script contains update_nginx_config function"
if grep -q 'update_nginx_config()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 20: Systemd & Service Management
# ===========================================================================

# ---- Test 138: Script uses systemctl daemon-reload ----
test_name="Script uses systemctl daemon-reload"
if grep -q 'systemctl daemon-reload' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 139: Script uses systemctl enable ----
test_name="Script uses systemctl enable for services"
if grep -q 'systemctl enable' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 140: Script uses systemctl restart ----
test_name="Script uses systemctl restart for services"
if grep -q 'systemctl restart' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 141: Script checks systemctl is-active ----
test_name="Script checks service status with systemctl is-active"
if grep -q 'systemctl is-active' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 142: Script sets DEBIAN_FRONTEND=noninteractive ----
test_name="Script sets DEBIAN_FRONTEND=noninteractive"
if grep -q 'DEBIAN_FRONTEND=noninteractive' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 21: Configuration File Paths
# ===========================================================================

# ---- Test 143: Hysteria2 config at /etc/hysteria2/config.yaml ----
test_name="Script generates Hysteria2 config at /etc/hysteria2/config.yaml"
if grep -q '/etc/hysteria2/config.yaml' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 144: Trojan-Go config at /etc/trojan-go/config.json ----
test_name="Script generates Trojan-Go config at /etc/trojan-go/config.json"
if grep -q '/etc/trojan-go/config.json' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 145: OpenVPN TCP config at /etc/openvpn/server-tcp.conf ----
test_name="Script generates OpenVPN TCP config"
if grep -q '/etc/openvpn/server-tcp.conf' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 146: OpenVPN UDP config at /etc/openvpn/server-udp.conf ----
test_name="Script generates OpenVPN UDP config"
if grep -q '/etc/openvpn/server-udp.conf' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 147: OpenVPN Stunnel config at /etc/stunnel/stunnel-openvpn.conf ----
test_name="Script generates OpenVPN Stunnel config"
if grep -q '/etc/stunnel/stunnel-openvpn.conf' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 148: SoftEther config at /etc/softether/vpn_server.config ----
test_name="Script generates SoftEther config"
if grep -q 'vpn_server.config' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 149: WARP config at /etc/warp/warp.conf ----
test_name="Script generates WARP config"
if grep -q 'warp.conf' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 150: UDP Custom config at /etc/udp-custom/config.json ----
test_name="Script generates UDP Custom config"
if grep -q '/etc/udp-custom/config.json' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 22: Main Function Orchestration
# ===========================================================================

# ---- Test 151: Main calls install_hysteria2 ----
test_name="Main function calls install_hysteria2"
if grep -A100 '^main()' "$SCRIPT_PATH" | grep -q 'install_hysteria2'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 152: Main calls install_trojan_go ----
test_name="Main function calls install_trojan_go"
if grep -A100 '^main()' "$SCRIPT_PATH" | grep -q 'install_trojan_go'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 153: Main calls install_openvpn ----
test_name="Main function calls install_openvpn"
if grep -A100 '^main()' "$SCRIPT_PATH" | grep -q 'install_openvpn'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 154: Main calls install_softether ----
test_name="Main function calls install_softether"
if grep -A100 '^main()' "$SCRIPT_PATH" | grep -q 'install_softether'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 155: Main calls install_warp ----
test_name="Main function calls install_warp"
if grep -A100 '^main()' "$SCRIPT_PATH" | grep -q 'install_warp'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 156: Main calls install_slowdns ----
test_name="Main function calls install_slowdns"
if grep -A100 '^main()' "$SCRIPT_PATH" | grep -q 'install_slowdns'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 157: Main calls install_udp_custom ----
test_name="Main function calls install_udp_custom"
if grep -A100 '^main()' "$SCRIPT_PATH" | grep -q 'install_udp_custom'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 158: Main calls integrate_ssl ----
test_name="Main function calls integrate_ssl"
if grep -A100 '^main()' "$SCRIPT_PATH" | grep -q 'integrate_ssl'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 159: Main calls check_root ----
test_name="Main function calls check_root"
if grep -A30 '^main()' "$SCRIPT_PATH" | grep -q 'check_root'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 160: Main calls check_tahap4 ----
test_name="Main function calls check_tahap4"
if grep -A30 '^main()' "$SCRIPT_PATH" | grep -q 'check_tahap4'; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 23: Completion Output
# ===========================================================================

# ---- Test 161: Script prints Tahap 5 completion message ----
test_name="Script prints Tahap 5 completion message"
if grep -q 'Tahap 5 selesai' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 162: Script logs Tahap 5 completion ----
test_name="Script logs Tahap 5 completion to log file"
if grep -q 'Tahap 5 selesai.*Protokol tambahan' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 24: Shellcheck Validation
# ===========================================================================

# ---- Test 163: Script passes shellcheck ----
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
