#!/bin/bash
# ============================================================================
# Test suite untuk setup-api.sh — Tahap 8: REST API & Bot Integrasi
# ============================================================================
# Menjalankan pengujian unit untuk fungsi-fungsi di setup-api.sh
# tanpa menjalankan operasi berbahaya (install/service management).
#
# Penggunaan:
#   chmod +x tests/test_setup_api.sh
#   ./tests/test_setup_api.sh
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/setup-api.sh"

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

assert_not_empty() {
    local test_name="$1"
    local value="$2"

    if [[ -n "$value" ]]; then
        echo -e "${GREEN}[PASS]${NC} $test_name"
        ((PASS++))
    else
        echo -e "${RED}[FAIL]${NC} $test_name"
        echo "  Value is empty"
        ((FAIL++))
    fi
}

echo "=============================================="
echo "  Test Suite: setup-api.sh (Tahap 8)"
echo "=============================================="
echo ""

# ===========================================================================
# Section 1: Basic File Tests
# ===========================================================================

# ---- Test 1: File exists ----
test_name="setup-api.sh file exists"
if [[ -f "$SCRIPT_PATH" ]]; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 2: File executable ----
test_name="setup-api.sh is executable"
if [[ -x "$SCRIPT_PATH" ]]; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 3: Bash syntax valid ----
test_name="setup-api.sh has valid bash syntax"
if bash -n "$SCRIPT_PATH" 2>/dev/null; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 4: Shebang line ----
test_name="setup-api.sh has correct shebang"
shebang=$(head -1 "$SCRIPT_PATH")
assert_eq "$test_name" "#!/bin/bash" "$shebang"

# ---- Test 5: Contains Tahap 8 reference ----
test_name="setup-api.sh contains Tahap 8 reference"
if grep -q "Tahap 8" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ===========================================================================
# Section 2: Script Variables
# ===========================================================================

# ---- Test 6: LOG_FILE defined ----
test_name="LOG_FILE variable defined"
if grep -q 'LOG_FILE="/root/syslog.log"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 7: API_PORT defined ----
test_name="API_PORT variable defined as 9000"
if grep -q 'API_PORT=9000' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 8: DOMAIN_FILE defined ----
test_name="DOMAIN_FILE variable defined"
if grep -q 'DOMAIN_FILE="/etc/xray/domain"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 9: XRAY_CONFIG defined ----
test_name="XRAY_CONFIG variable defined"
if grep -q 'XRAY_CONFIG="/etc/xray/config.json"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 10: API_CONFIG_DIR defined ----
test_name="API_CONFIG_DIR variable defined"
if grep -q 'API_CONFIG_DIR="/etc/vpnray/api"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 11: API_SERVER_SCRIPT defined ----
test_name="API_SERVER_SCRIPT variable defined"
if grep -q 'API_SERVER_SCRIPT="/usr/local/bin/vpnray-api"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 12: BOT_SCRIPT defined ----
test_name="BOT_SCRIPT variable defined"
if grep -q 'BOT_SCRIPT="/usr/local/bin/vpnray-bot"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 13: BOT_SELLER_SCRIPT defined ----
test_name="BOT_SELLER_SCRIPT variable defined"
if grep -q 'BOT_SELLER_SCRIPT="/usr/local/bin/vpnray-bot-seller"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 14: BOT_NOTIFY_SCRIPT defined ----
test_name="BOT_NOTIFY_SCRIPT variable defined"
if grep -q 'BOT_NOTIFY_SCRIPT="/usr/local/bin/vpnray-bot-notify"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 15: WEBHOOK_SCRIPT defined ----
test_name="WEBHOOK_SCRIPT variable defined"
if grep -q 'WEBHOOK_SCRIPT="/usr/local/bin/vpnray-webhook"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 16: API_SERVICE_FILE defined ----
test_name="API_SERVICE_FILE variable defined"
if grep -q 'API_SERVICE_FILE="/etc/systemd/system/vpnray-api.service"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 17: BOT_SERVICE_FILE defined ----
test_name="BOT_SERVICE_FILE variable defined"
if grep -q 'BOT_SERVICE_FILE="/etc/systemd/system/vpnray-bot.service"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 18: SUPPORTED_PROTOCOLS defined ----
test_name="SUPPORTED_PROTOCOLS variable defined"
if grep -q 'SUPPORTED_PROTOCOLS=' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 19: Account directories defined ----
test_name="Account directories defined for all protocols"
result="true"
for proto in SSH VMESS VLESS TROJAN SHADOWSOCKS SOCKS HYSTERIA2; do
    if ! grep -q "${proto}_ACCOUNT_DIR=" "$SCRIPT_PATH"; then
        result="false"
        break
    fi
done
assert_eq "$test_name" "true" "$result"

# ---- Test 20: WEBHOOK_CONFIG_FILE defined ----
test_name="WEBHOOK_CONFIG_FILE variable defined"
if grep -q 'WEBHOOK_CONFIG_FILE=' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

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
    "check_tahap7"
    "generate_api_key"
    "json_response"
    "json_error"
    "json_success"
    "parse_json_field"
    "parse_json_field_num"
    "url_decode"
    "get_domain"
    "get_public_ip"
    "get_protocol_dir"
    "validate_protocol"
    "api_create_account"
    "api_delete_account"
    "api_list_accounts"
    "api_detail_account"
    "api_renew_account"
    "api_lock_account"
    "api_unlock_account"
    "api_ban_account"
    "api_unban_account"
    "api_limit_ip"
    "api_limit_quota"
    "api_server_status"
    "api_server_bandwidth"
    "api_server_running"
    "api_server_reboot"
    "api_backup"
    "api_restore"
    "api_subscription"
    "api_clash_config"
    "route_request"
    "create_api_server"
    "setup_api_config"
    "bot_send_message"
    "bot_parse_update"
    "bot_handle_command"
    "bot_seller_panel"
    "bot_notification"
    "create_bot_script"
    "create_bot_seller"
    "create_bot_notify"
    "setup_bot_config"
    "webhook_send"
    "webhook_account_event"
    "webhook_server_event"
    "create_webhook_script"
    "setup_webhook_config"
    "create_api_service"
    "create_bot_service"
    "enable_services"
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
# Section 4: Source Script and Test Functions
# ===========================================================================

# Source script with main() disabled
# Create a temp copy without the final main "$@" call
TEMP_SOURCE=$(mktemp)
sed '$ s/^main "\$@"/# main "$@"/' "$SCRIPT_PATH" > "$TEMP_SOURCE"
# Override dangerous functions before sourcing
check_root() { :; }
check_os() { :; }
check_arch() { :; }
check_virt() { :; }
check_tahap7() { :; }
# shellcheck disable=SC2034
EUID=0
print_header() { :; }
enable_services() { :; }
# shellcheck disable=SC1090
source "$TEMP_SOURCE" 2>/dev/null
rm -f "$TEMP_SOURCE"
# Re-override main to prevent accidental calls
main() { :; }

# ---- Test: generate_api_key ----
test_name="generate_api_key returns 32 char key"
key=$(generate_api_key)
key_len=${#key}
if [[ "$key_len" -eq 32 ]]; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "32" "$key_len"
fi

# ---- Test: generate_api_key uniqueness ----
test_name="generate_api_key returns unique keys"
key2=$(generate_api_key)
if [[ "$key" != "$key2" ]]; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: parse_json_field ----
test_name="parse_json_field extracts string field"
json='{"username":"testuser","exp":"30"}'
result=$(parse_json_field "$json" "username")
assert_eq "$test_name" "testuser" "$result"

# ---- Test: parse_json_field_num ----
test_name="parse_json_field_num extracts numeric field"
json='{"username":"testuser","exp":30,"quota":100}'
result=$(parse_json_field_num "$json" "exp")
assert_eq "$test_name" "30" "$result"

# ---- Test: parse_json_field_num quota ----
test_name="parse_json_field_num extracts quota"
result=$(parse_json_field_num "$json" "quota")
assert_eq "$test_name" "100" "$result"

# ---- Test: url_decode ----
test_name="url_decode decodes URL-encoded string"
result=$(url_decode "hello%20world")
assert_eq "$test_name" "hello world" "$result"

# ---- Test: validate_protocol ssh ----
test_name="validate_protocol accepts ssh"
result=$(validate_protocol "ssh")
assert_eq "$test_name" "true" "$result"

# ---- Test: validate_protocol vmess ----
test_name="validate_protocol accepts vmess"
result=$(validate_protocol "vmess")
assert_eq "$test_name" "true" "$result"

# ---- Test: validate_protocol vless ----
test_name="validate_protocol accepts vless"
result=$(validate_protocol "vless")
assert_eq "$test_name" "true" "$result"

# ---- Test: validate_protocol trojan ----
test_name="validate_protocol accepts trojan"
result=$(validate_protocol "trojan")
assert_eq "$test_name" "true" "$result"

# ---- Test: validate_protocol shadowsocks ----
test_name="validate_protocol accepts shadowsocks"
result=$(validate_protocol "shadowsocks")
assert_eq "$test_name" "true" "$result"

# ---- Test: validate_protocol socks ----
test_name="validate_protocol accepts socks"
result=$(validate_protocol "socks")
assert_eq "$test_name" "true" "$result"

# ---- Test: validate_protocol hysteria2 ----
test_name="validate_protocol accepts hysteria2"
result=$(validate_protocol "hysteria2")
assert_eq "$test_name" "true" "$result"

# ---- Test: validate_protocol trojan-go ----
test_name="validate_protocol accepts trojan-go"
result=$(validate_protocol "trojan-go")
assert_eq "$test_name" "true" "$result"

# ---- Test: validate_protocol invalid ----
test_name="validate_protocol rejects invalid protocol"
result=$(validate_protocol "invalid")
assert_eq "$test_name" "false" "$result"

# ---- Test: get_protocol_dir ssh ----
test_name="get_protocol_dir returns SSH dir"
result=$(get_protocol_dir "ssh")
assert_contains "$test_name" "ssh" "$result"

# ---- Test: get_protocol_dir vmess ----
test_name="get_protocol_dir returns VMess dir"
result=$(get_protocol_dir "vmess")
assert_contains "$test_name" "vmess" "$result"

# ---- Test: get_protocol_dir invalid ----
test_name="get_protocol_dir returns empty for invalid"
result=$(get_protocol_dir "invalid")
assert_eq "$test_name" "" "$result"

# ---- Test: json_response format ----
test_name="json_response returns HTTP response"
result=$(json_response "200 OK" '{"test":true}')
assert_contains "$test_name" "HTTP/1.1 200 OK" "$result"

# ---- Test: json_response Content-Type ----
test_name="json_response has Content-Type header"
assert_contains "$test_name" "Content-Type: application/json" "$result"

# ---- Test: json_error format ----
test_name="json_error returns error response"
result=$(json_error "400 Bad Request" "Test error")
assert_contains "$test_name" "400 Bad Request" "$result"

# ---- Test: json_error contains error status ----
test_name="json_error contains error status"
assert_contains "$test_name" '"status":"error"' "$result"

# ---- Test: json_success format ----
test_name="json_success returns success response"
result=$(json_success "Test success" '{"foo":"bar"}')
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: json_success with data ----
test_name="json_success contains data"
assert_contains "$test_name" '"foo":"bar"' "$result"

# ===========================================================================
# Section 5: API Account Operations (with temp dir)
# ===========================================================================

# Setup temp account dirs
TEMP_DIR=$(mktemp -d)
ACCOUNT_DIR="$TEMP_DIR/accounts"
SSH_ACCOUNT_DIR="$ACCOUNT_DIR/ssh"
VMESS_ACCOUNT_DIR="$ACCOUNT_DIR/vmess"
VLESS_ACCOUNT_DIR="$ACCOUNT_DIR/vless"
TROJAN_ACCOUNT_DIR="$ACCOUNT_DIR/trojan"
SHADOWSOCKS_ACCOUNT_DIR="$ACCOUNT_DIR/shadowsocks"
SOCKS_ACCOUNT_DIR="$ACCOUNT_DIR/socks"
HYSTERIA2_ACCOUNT_DIR="$ACCOUNT_DIR/hysteria2"
TROJAN_GO_ACCOUNT_DIR="$ACCOUNT_DIR/trojan-go"
mkdir -p "$SSH_ACCOUNT_DIR" "$VMESS_ACCOUNT_DIR" "$VLESS_ACCOUNT_DIR" \
    "$TROJAN_ACCOUNT_DIR" "$SHADOWSOCKS_ACCOUNT_DIR" "$SOCKS_ACCOUNT_DIR" \
    "$HYSTERIA2_ACCOUNT_DIR" "$TROJAN_GO_ACCOUNT_DIR"
LOG_FILE="/dev/null"

# ---- Test: Create SSH account ----
test_name="api_create_account creates SSH account"
result=$(api_create_account "ssh" '{"username":"testuser01","exp":30,"ip_limit":2}')
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: SSH account file exists ----
test_name="SSH account file created"
if [[ -f "$SSH_ACCOUNT_DIR/testuser01.json" ]]; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Create VMess account ----
test_name="api_create_account creates VMess account"
result=$(api_create_account "vmess" '{"username":"vmessuser01","exp":30,"quota":100,"ip_limit":3}')
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: VMess account has uuid ----
test_name="VMess account has uuid"
if [[ -f "$VMESS_ACCOUNT_DIR/vmessuser01.json" ]]; then
    contents=$(cat "$VMESS_ACCOUNT_DIR/vmessuser01.json")
    assert_contains "$test_name" '"uuid"' "$contents"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Create VLESS account ----
test_name="api_create_account creates VLESS account"
result=$(api_create_account "vless" '{"username":"vlessuser01","exp":30}')
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Create Trojan account ----
test_name="api_create_account creates Trojan account"
result=$(api_create_account "trojan" '{"username":"trojanuser01","exp":30}')
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Create Shadowsocks account ----
test_name="api_create_account creates Shadowsocks account"
result=$(api_create_account "shadowsocks" '{"username":"ssuser01","exp":30}')
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Create Socks account ----
test_name="api_create_account creates Socks account"
result=$(api_create_account "socks" '{"username":"socksuser01","exp":30}')
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Create Hysteria2 account ----
test_name="api_create_account creates Hysteria2 account"
result=$(api_create_account "hysteria2" '{"username":"h2user01","exp":30}')
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Create Trojan-Go account ----
test_name="api_create_account creates Trojan-Go account"
result=$(api_create_account "trojan-go" '{"username":"tguser01","exp":30}')
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Duplicate account fails ----
test_name="api_create_account rejects duplicate"
result=$(api_create_account "ssh" '{"username":"testuser01"}')
assert_contains "$test_name" '"status":"error"' "$result"

# ---- Test: Missing username fails ----
test_name="api_create_account rejects missing username"
result=$(api_create_account "ssh" '{"exp":30}')
assert_contains "$test_name" '"status":"error"' "$result"

# ---- Test: Invalid protocol fails ----
test_name="api_create_account rejects invalid protocol"
result=$(api_create_account "invalid" '{"username":"user1"}')
assert_contains "$test_name" '"status":"error"' "$result"

# ---- Test: List accounts ----
test_name="api_list_accounts returns accounts"
result=$(api_list_accounts "ssh")
assert_contains "$test_name" '"status":"success"' "$result"
assert_contains "api_list_accounts contains username" "testuser01" "$result"

# ---- Test: Detail account ----
test_name="api_detail_account returns account details"
result=$(api_detail_account "ssh" "testuser01")
assert_contains "$test_name" '"status":"success"' "$result"
assert_contains "api_detail_account has username" "testuser01" "$result"

# ---- Test: Detail nonexistent account ----
test_name="api_detail_account fails for nonexistent"
result=$(api_detail_account "ssh" "nonexistent")
assert_contains "$test_name" '"status":"error"' "$result"

# ---- Test: Renew account ----
test_name="api_renew_account renews account"
result=$(api_renew_account "ssh" '{"username":"testuser01","days":60}')
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Lock account ----
test_name="api_lock_account locks account"
result=$(api_lock_account "ssh" '{"username":"testuser01"}')
assert_contains "$test_name" '"status":"success"' "$result"
assert_contains "api_lock_account has locked:true" '"locked":true' "$result"

# ---- Test: Unlock account ----
test_name="api_unlock_account unlocks account"
result=$(api_unlock_account "ssh" '{"username":"testuser01"}')
assert_contains "$test_name" '"status":"success"' "$result"
assert_contains "api_unlock_account has locked:false" '"locked":false' "$result"

# ---- Test: Ban account ----
test_name="api_ban_account bans account"
result=$(api_ban_account "ssh" '{"username":"testuser01"}')
assert_contains "$test_name" '"status":"success"' "$result"
assert_contains "api_ban_account has banned:true" '"banned":true' "$result"

# ---- Test: Unban account ----
test_name="api_unban_account unbans account"
result=$(api_unban_account "ssh" '{"username":"testuser01"}')
assert_contains "$test_name" '"status":"success"' "$result"
assert_contains "api_unban_account has banned:false" '"banned":false' "$result"

# ---- Test: Limit IP ----
test_name="api_limit_ip sets IP limit"
result=$(api_limit_ip "ssh" '{"username":"testuser01","ip_limit":5}')
assert_contains "$test_name" '"status":"success"' "$result"
assert_contains "api_limit_ip has ip_limit:5" '"ip_limit":5' "$result"

# ---- Test: Limit Quota ----
test_name="api_limit_quota sets quota limit"
result=$(api_limit_quota "vmess" '{"username":"vmessuser01","quota":200}')
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Delete account ----
test_name="api_delete_account deletes account"
result=$(api_delete_account "ssh" '{"username":"testuser01"}')
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Account file removed ----
test_name="Account file removed after delete"
if [[ ! -f "$SSH_ACCOUNT_DIR/testuser01.json" ]]; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Delete nonexistent account fails ----
test_name="api_delete_account fails for nonexistent"
result=$(api_delete_account "ssh" '{"username":"nonexistent"}')
assert_contains "$test_name" '"status":"error"' "$result"

# ===========================================================================
# Section 6: API Server Endpoint Tests
# ===========================================================================

# ---- Test: Server status ----
test_name="api_server_status returns status"
result=$(api_server_status)
assert_contains "$test_name" '"status":"success"' "$result"
assert_contains "api_server_status has hostname" "hostname" "$result"

# ---- Test: Server bandwidth ----
test_name="api_server_bandwidth returns bandwidth"
result=$(api_server_bandwidth)
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Server running ----
test_name="api_server_running returns services"
result=$(api_server_running)
assert_contains "$test_name" '"status":"success"' "$result"

# ===========================================================================
# Section 7: Route Request Tests
# ===========================================================================

# ---- Test: Route OPTIONS (CORS) ----
test_name="route_request handles OPTIONS"
result=$(route_request "OPTIONS" "/" "" "false")
assert_contains "$test_name" "200 OK" "$result"

# ---- Test: Route GET /api/docs ----
test_name="route_request handles GET /api/docs"
result=$(route_request "GET" "/api/docs" "" "false")
assert_contains "$test_name" '"status":"success"' "$result"
assert_contains "route docs has endpoints" "endpoints" "$result"

# ---- Test: Route without auth ----
test_name="route_request rejects unauthenticated request"
result=$(route_request "GET" "/api/server/status" "" "false")
assert_contains "$test_name" "401" "$result"

# ---- Test: Route with auth ----
test_name="route_request accepts authenticated request"
result=$(route_request "GET" "/api/server/status" "" "true")
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Route POST create ----
test_name="route_request handles POST create"
result=$(route_request "POST" "/api/ssh/create" '{"username":"routetest01","exp":30}' "true")
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Route GET list ----
test_name="route_request handles GET list"
result=$(route_request "GET" "/api/ssh/list" "" "true")
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Route GET detail ----
test_name="route_request handles GET detail"
result=$(route_request "GET" "/api/ssh/detail/routetest01" "" "true")
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Route PUT renew ----
test_name="route_request handles PUT renew"
result=$(route_request "PUT" "/api/ssh/renew" '{"username":"routetest01","days":30}' "true")
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Route PUT lock ----
test_name="route_request handles PUT lock"
result=$(route_request "PUT" "/api/ssh/lock" '{"username":"routetest01"}' "true")
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Route PUT unlock ----
test_name="route_request handles PUT unlock"
result=$(route_request "PUT" "/api/ssh/unlock" '{"username":"routetest01"}' "true")
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Route PUT ban ----
test_name="route_request handles PUT ban"
result=$(route_request "PUT" "/api/ssh/ban" '{"username":"routetest01"}' "true")
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Route PUT unban ----
test_name="route_request handles PUT unban"
result=$(route_request "PUT" "/api/ssh/unban" '{"username":"routetest01"}' "true")
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Route PUT limit-ip ----
test_name="route_request handles PUT limit-ip"
result=$(route_request "PUT" "/api/ssh/limit-ip" '{"username":"routetest01","ip_limit":3}' "true")
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Route PUT limit-quota ----
test_name="route_request handles PUT limit-quota"
result=$(route_request "PUT" "/api/ssh/limit-quota" '{"username":"routetest01","quota":50}' "true")
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Route DELETE delete ----
test_name="route_request handles DELETE delete"
result=$(route_request "DELETE" "/api/ssh/delete" '{"username":"routetest01"}' "true")
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Route POST backup (auth) ----
test_name="route_request handles POST backup"
result=$(route_request "POST" "/api/backup" "" "true")
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Route GET server/bandwidth ----
test_name="route_request handles GET bandwidth"
result=$(route_request "GET" "/api/server/bandwidth" "" "true")
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Route GET server/running ----
test_name="route_request handles GET running"
result=$(route_request "GET" "/api/server/running" "" "true")
assert_contains "$test_name" '"status":"success"' "$result"

# ---- Test: Route 404 ----
test_name="route_request returns 404 for unknown path"
result=$(route_request "GET" "/api/unknown" "" "true")
assert_contains "$test_name" "404" "$result"

# ---- Test: Route wrong method ----
test_name="route_request returns 405 for wrong method"
result=$(route_request "GET" "/api/ssh/create" "" "true")
assert_contains "$test_name" "405" "$result"

# ===========================================================================
# Section 8: Script Content Checks
# ===========================================================================

# ---- Test: Contains color definitions ----
test_name="Script has color definitions"
if grep -q "RED=" "$SCRIPT_PATH" && grep -q "GREEN=" "$SCRIPT_PATH" && grep -q "NC=" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Contains socat reference ----
test_name="Script references socat for API server"
if grep -q "socat" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Contains systemd service creation ----
test_name="Script creates systemd service"
if grep -q "vpnray-api.service" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Contains Telegram Bot API reference ----
test_name="Script references Telegram Bot API"
if grep -q "api.telegram.org" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Contains bot commands ----
for cmd in "/start" "/status" "/running" "/help" "/reboot"; do
    test_name="Script handles bot command: $cmd"
    if grep -q "$cmd" "$SCRIPT_PATH"; then
        assert_eq "$test_name" "true" "true"
    else
        assert_eq "$test_name" "true" "false"
    fi
done

# ---- Test: Contains webhook integration ----
test_name="Script has webhook send function"
if grep -q "webhook_send" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Contains main function with steps ----
test_name="Main function has numbered steps"
if grep -q "\[1/10\]" "$SCRIPT_PATH" && grep -q "\[10/10\]" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Contains completion message ----
test_name="Script has Tahap 8 completion message"
if grep -q "Tahap 8 selesai" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Contains Tahap 9 readiness message ----
test_name="Script mentions Tahap 9 readiness"
if grep -q "Tahap 9" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Contains CORS headers ----
test_name="Script has CORS headers in response"
if grep -q "Access-Control-Allow-Origin" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: Contains API documentation endpoint ----
test_name="Script has /api/docs endpoint"
if grep -q "/api/docs" "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test: main "$@" at end ----
test_name="Script ends with main call"
last_line=$(tail -1 "$SCRIPT_PATH")
assert_eq "$test_name" 'main "$@"' "$last_line"

# ===========================================================================
# Section 9: Shellcheck Validation
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

# Cleanup
rm -rf "$TEMP_DIR"

# ---- Hasil ----
echo ""
echo "=============================================="
echo "  Hasil: $PASS passed, $FAIL failed, $SKIP skipped"
echo "=============================================="

if [[ "$FAIL" -gt 0 ]]; then
    exit 1
fi

exit 0
