#!/bin/bash
# ============================================================================
# Test suite untuk setup-domain.sh — Tahap 3: Domain, SSL, Nginx & Xray-core
# ============================================================================
# Menjalankan pengujian unit untuk fungsi-fungsi di setup-domain.sh
# tanpa menjalankan operasi berbahaya (install/service management).
#
# Penggunaan:
#   chmod +x tests/test_setup_domain.sh
#   ./tests/test_setup_domain.sh
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/setup-domain.sh"

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
echo "  Test Suite: setup-domain.sh (Tahap 3)"
echo "=============================================="
echo ""

# ===========================================================================
# Section 1: Basic File Tests
# ===========================================================================

# ---- Test 1: File setup-domain.sh ada ----
test_name="setup-domain.sh file exists"
if [[ -f "$SCRIPT_PATH" ]]; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 2: File setup-domain.sh executable ----
test_name="setup-domain.sh is executable"
if [[ -x "$SCRIPT_PATH" ]]; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 3: Bash syntax valid ----
test_name="setup-domain.sh has valid bash syntax"
if bash -n "$SCRIPT_PATH" 2>/dev/null; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 4: Shebang correct ----
test_name="setup-domain.sh has correct shebang (#!/bin/bash)"
first_line=$(head -1 "$SCRIPT_PATH")
assert_eq "$test_name" "#!/bin/bash" "$first_line"

# ---- Test 5: Script header mentions Tahap 3 ----
test_name="Script header mentions Tahap 3"
if grep -q 'Tahap 3' "$SCRIPT_PATH"; then
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

# ---- Test 7: DOMAIN variable from first argument ----
test_name="DOMAIN is read from first argument"
if grep -q 'DOMAIN="${1:-}"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 8: CF_API_KEY from second argument ----
test_name="CF_API_KEY is read from second argument"
if grep -q 'CF_API_KEY="${2:-}"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 9: XRAY_CERT path defined ----
test_name="XRAY_CERT path defined as /etc/xray/xray.crt"
if grep -q 'xray.crt' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 10: XRAY_KEY path defined ----
test_name="XRAY_KEY path defined as /etc/xray/xray.key"
if grep -q 'xray.key' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 11: NGINX_CONF path defined ----
test_name="NGINX_CONF path defined as /etc/nginx/conf.d/xray.conf"
if grep -q '/etc/nginx/conf.d/xray.conf' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 12: Domain file path defined ----
test_name="Domain file path at /etc/xray/domain"
if grep -q '/etc/xray/domain' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 3: Prerequisite Check Functions
# ===========================================================================

# ---- Test 13: Script contains check_root function ----
test_name="Script contains check_root function"
if grep -q 'check_root()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 14: Script contains check_os function ----
test_name="Script contains check_os function"
if grep -q 'check_os()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 15: Script contains check_arch function ----
test_name="Script contains check_arch function"
if grep -q 'check_arch()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 16: Script contains check_virt function ----
test_name="Script contains check_virt function"
if grep -q 'check_virt()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 17: Script contains check_domain_input function ----
test_name="Script contains check_domain_input function"
if grep -q 'check_domain_input()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 18: Script contains check_dependencies function ----
test_name="Script contains check_dependencies function"
if grep -q 'check_dependencies()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 19-21: Script supports Ubuntu versions ----
for ver in "20.04" "22.04" "24.04"; do
    test_name="Script supports Ubuntu $ver"
    if grep -q "$ver" "$SCRIPT_PATH"; then
        assert_eq "$test_name" "true" "true"
    else
        assert_eq "$test_name" "true" "false"
    fi
done

# ---- Test 22-24: Script supports Debian versions ----
for ver in 10 11 12; do
    test_name="Script supports Debian $ver"
    if grep -A5 'debian)' "$SCRIPT_PATH" | grep -q "$ver"; then
        assert_eq "$test_name" "true" "true"
    else
        assert_eq "$test_name" "true" "false"
    fi
done

# ---- Test 25: Script checks for x86_64 architecture ----
test_name="Script checks for x86_64 architecture"
if grep -q 'x86_64' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 26: Script rejects OpenVZ ----
test_name="Script rejects OpenVZ virtualization"
if grep -q 'openvz' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 4: Domain Setup Functions
# ===========================================================================

# ---- Test 27: Script contains setup_domain function ----
test_name="Script contains setup_domain function"
if grep -q 'setup_domain()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 28: Script contains validate_domain_dns function ----
test_name="Script contains validate_domain_dns function"
if grep -q 'validate_domain_dns()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 29: Script validates domain format ----
test_name="Script validates domain format with regex"
if grep -q 'grep.*-qP.*\^' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 30: Script uses dig for DNS resolution ----
test_name="Script uses dig for DNS resolution"
if grep -q 'dig.*+short' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 31: Script detects VPS public IP ----
test_name="Script detects VPS public IP (curl ifconfig.me)"
if grep -q 'ifconfig.me' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 5: Cloudflare Integration
# ===========================================================================

# ---- Test 32: Script contains setup_cloudflare_domain function ----
test_name="Script contains setup_cloudflare_domain function"
if grep -q 'setup_cloudflare_domain()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 33: Script uses Cloudflare API v4 ----
test_name="Script uses Cloudflare API v4 endpoint"
if grep -q 'api.cloudflare.com/client/v4' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 34: Script reads CF API Key from file ----
test_name="Script reads CF API Key from /etc/xray/cloudflare"
if grep -q '/etc/xray/cloudflare' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 35: Script creates/updates DNS A record ----
test_name="Script handles DNS A record creation and update"
if grep -q 'type.*A.*name.*content' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 6: SSL Certificate (acme.sh)
# ===========================================================================

# ---- Test 36: Script contains install_acme function ----
test_name="Script contains install_acme function"
if grep -q 'install_acme()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 37: Script contains issue_ssl_certificate function ----
test_name="Script contains issue_ssl_certificate function"
if grep -q 'issue_ssl_certificate()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 38: Script installs acme.sh ----
test_name="Script installs acme.sh from official source"
if grep -q 'get.acme.sh' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 39: Script sets Let's Encrypt as default CA ----
test_name="Script sets Let's Encrypt as default CA"
if grep -q 'letsencrypt' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 40: Script supports Cloudflare DNS verification ----
test_name="Script supports Cloudflare DNS verification (dns_cf)"
if grep -q 'dns_cf' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 41: Script supports standalone HTTP verification ----
test_name="Script supports standalone HTTP verification"
if grep -q '\-\-standalone' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 42: Script uses EC-256 key ----
test_name="Script uses EC-256 key length for SSL"
if grep -q 'ec-256' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 43: Script installs cert to Xray directory ----
test_name="Script installs cert with --fullchain-file and --key-file"
if grep -q '\-\-fullchain-file' "$SCRIPT_PATH" && grep -q '\-\-key-file' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 44: Script sets chmod 600 on SSL key ----
test_name="Script sets chmod 600 on SSL private key"
if grep -q 'chmod 600.*XRAY_KEY' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 45: Script installs socat ----
test_name="Script installs socat (acme.sh dependency)"
if grep -q 'socat' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 7: Nginx Installation & Configuration
# ===========================================================================

# ---- Test 46: Script contains install_nginx function ----
test_name="Script contains install_nginx function"
if grep -q 'install_nginx()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 47: Script contains configure_nginx function ----
test_name="Script contains configure_nginx function"
if grep -q 'configure_nginx()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 48: Script contains start_nginx function ----
test_name="Script contains start_nginx function"
if grep -q 'start_nginx()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 49: Nginx config has HTTPS on port 443 ----
test_name="Nginx config listens on port 443 (HTTPS)"
if grep -q 'listen.*443.*ssl' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 50: Nginx config has HTTP on port 80 ----
test_name="Nginx config listens on port 80 (HTTP)"
if grep -q 'listen.*80' "$SCRIPT_PATH" || grep -q 'NGINX_HTTP_PORT' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 51: Nginx config has port 81 ----
test_name="Nginx config includes port 81 (Alt HTTP)"
if grep -q '81' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 52: Nginx config has port 663 ----
test_name="Nginx config includes port 663 (Fallback)"
if grep -q '663' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 53: Nginx tests config before start ----
test_name="Script tests Nginx config (nginx -t)"
if grep -q 'nginx -t' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 54: Nginx writes main config ----
test_name="Script writes /etc/nginx/nginx.conf"
if grep -q '/etc/nginx/nginx.conf' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 55: Nginx uses TLS 1.2 and 1.3 ----
test_name="Nginx config uses TLSv1.2 and TLSv1.3"
if grep -q 'TLSv1.2 TLSv1.3' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 56: Nginx disables server_tokens ----
test_name="Nginx config disables server_tokens"
if grep -q 'server_tokens off' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 8: Nginx WebSocket & gRPC Paths (from README)
# ===========================================================================

# ---- Test 57-67: All Xray paths present in Nginx config ----
ws_paths=("/vmessws" "/vlessws" "/trojanws" "/ssws" "/socksws" "/vmess-httpupgrade" "/vless-httpupgrade" "/trojan-httpupgrade" "/ssh" "/trojan-go")
for path in "${ws_paths[@]}"; do
    test_name="Nginx config includes WebSocket path: $path"
    if grep -q "location $path" "$SCRIPT_PATH"; then
        assert_eq "$test_name" "true" "true"
    else
        assert_eq "$test_name" "true" "false"
    fi
done

# ---- Test 68-72: gRPC service names ----
grpc_services=("vmess-grpc" "vless-grpc" "trojan-grpc" "ss-grpc" "socks-grpc")
for svc in "${grpc_services[@]}"; do
    test_name="Nginx config includes gRPC service: $svc"
    if grep -q "$svc" "$SCRIPT_PATH"; then
        assert_eq "$test_name" "true" "true"
    else
        assert_eq "$test_name" "true" "false"
    fi
done

# ---- Test 73: Nginx uses grpc_pass ----
test_name="Nginx config uses grpc_pass for gRPC proxying"
if grep -q 'grpc_pass' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 74: Nginx uses proxy_pass for WebSocket ----
test_name="Nginx uses proxy_pass for WebSocket proxying"
if grep -q 'proxy_pass' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 75: Nginx sets WebSocket upgrade headers ----
test_name="Nginx config sets WebSocket upgrade headers"
if grep -q 'proxy_set_header Upgrade' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 9: Xray-core Installation
# ===========================================================================

# ---- Test 76: Script contains install_xray function ----
test_name="Script contains install_xray function"
if grep -q 'install_xray()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 77: Script contains create_xray_config function ----
test_name="Script contains create_xray_config function"
if grep -q 'create_xray_config()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 78: Script contains create_xray_service function ----
test_name="Script contains create_xray_service function"
if grep -q 'create_xray_service()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 79: Script contains start_xray function ----
test_name="Script contains start_xray function"
if grep -q 'start_xray()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 80: Script uses official Xray install script ----
test_name="Script uses official Xray install script from XTLS"
if grep -q 'XTLS/Xray-install' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 81: Script has manual Xray download fallback ----
test_name="Script has manual Xray download fallback"
if grep -q 'Xray-linux-64.zip' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 82: Xray config at /etc/xray/config.json ----
test_name="Xray config path is /etc/xray/config.json"
if grep -q '/etc/xray/config.json' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 83: Script creates systemd service for Xray ----
test_name="Script creates Xray systemd service file"
if grep -q '/etc/systemd/system/xray.service' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 84: Script runs systemctl daemon-reload ----
test_name="Script runs systemctl daemon-reload"
if grep -q 'systemctl daemon-reload' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 85: Script enables Xray service ----
test_name="Script enables Xray service"
if grep -q 'systemctl enable xray' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 10: Xray Config — Protocols & Paths
# ===========================================================================

# ---- Test 86: Xray config has VMess protocol ----
test_name="Xray config includes VMess protocol"
if grep -q '"protocol": "vmess"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 87: Xray config has VLESS protocol ----
test_name="Xray config includes VLESS protocol"
if grep -q '"protocol": "vless"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 88: Xray config has Trojan protocol ----
test_name="Xray config includes Trojan protocol"
if grep -q '"protocol": "trojan"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 89: Xray config has Shadowsocks protocol ----
test_name="Xray config includes Shadowsocks protocol"
if grep -q '"protocol": "shadowsocks"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 90: Xray config has Socks protocol ----
test_name="Xray config includes Socks protocol"
if grep -q '"protocol": "socks"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 91: Xray config has WebSocket transport ----
test_name="Xray config includes WebSocket transport"
if grep -q '"network": "ws"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 92: Xray config has gRPC transport ----
test_name="Xray config includes gRPC transport"
if grep -q '"network": "grpc"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 93: Xray config has HTTP Upgrade transport ----
test_name="Xray config includes HTTP Upgrade transport"
if grep -q '"network": "httpupgrade"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 94: Xray config blocks BitTorrent ----
test_name="Xray config blocks BitTorrent protocol"
if grep -q 'bittorrent' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 95: Xray config has stats enabled ----
test_name="Xray config has statistics/stats enabled"
if grep -q '"stats"' "$SCRIPT_PATH" && grep -q 'StatsService' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 96: Xray config has user traffic tracking ----
test_name="Xray config enables per-user traffic stats"
if grep -q 'statsUserUplink' "$SCRIPT_PATH" && grep -q 'statsUserDownlink' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 97: Xray config has freedom outbound ----
test_name="Xray config has freedom outbound (direct)"
if grep -q '"protocol": "freedom"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 98: Xray config has blackhole outbound ----
test_name="Xray config has blackhole outbound (blocked)"
if grep -q '"protocol": "blackhole"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 99: Xray creates log directory ----
test_name="Script creates Xray log directory /var/log/xray"
if grep -q '/var/log/xray' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 11: Main Function & Flow
# ===========================================================================

# ---- Test 100: Script contains main function ----
test_name="Script contains main function"
if grep -q 'main()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 101: Script writes to log file ----
test_name="Script writes to log file"
if grep -q 'LOG_FILE' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 102: Default page in /home/vps/public_html ----
test_name="Script creates default index.html page"
if grep -q '/home/vps/public_html/index.html' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 103: Script redirects HTTP to HTTPS ----
test_name="Nginx config redirects HTTP to HTTPS (301)"
if grep -q 'return 301' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 104: Script enables nginx service ----
test_name="Script enables nginx service"
if grep -q 'systemctl enable nginx' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 105: Script passes shellcheck ----
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
