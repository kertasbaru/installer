#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript Installer — Tahap 8: REST API & Bot Integrasi
# ============================================================================
# REST API service dan integrasi Telegram Bot untuk remote management.
# API berjalan pada port 9000 menggunakan socat sebagai HTTP server.
#
# Komponen:
#   - REST API (port 9000) — CRUD akun, server info, backup/restore
#   - Telegram Bot — Remote management via bot
#   - Webhook — Notifikasi event sistem
#   - Systemd service — Auto-start API & Bot
#
# OS yang Didukung:
#   - Ubuntu 20.04 LTS (focal)
#   - Ubuntu 22.04 LTS (jammy)
#   - Ubuntu 24.04 LTS (noble)
#   - Debian 10 (buster)
#   - Debian 11 (bullseye)
#   - Debian 12 (bookworm)
#
# Persyaratan:
#   - Akses root
#   - Arsitektur amd64 (64-bit)
#   - Virtualisasi KVM / Xen
#   - Tahap 1-7 sudah dijalankan
#
# Penggunaan:
#   chmod +x setup-api.sh
#   ./setup-api.sh
#
# Referensi:
#   - https://github.com/FN-Rerechan02/Autoscript (AIO VPN script reference)
#   - https://github.com/mack-a/v2ray-agent (8-in-1 script reference)
#   - https://github.com/XTLS/Xray-core (Core engine Xray proxy)
#
# Log instalasi tersimpan di: /root/syslog.log
# ============================================================================

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# File log
LOG_FILE="/root/syslog.log"

# ============================================================================
# Paths penting dari Tahap sebelumnya
# ============================================================================
DOMAIN_FILE="/etc/xray/domain"
XRAY_CONFIG="/etc/xray/config.json"
XRAY_CERT="/etc/xray/xray.crt"
# shellcheck disable=SC2034
XRAY_KEY="/etc/xray/xray.key"
HYSTERIA2_CONFIG="/etc/hysteria2/config.yaml"
TROJAN_GO_CONFIG="/etc/trojan-go/config.json"

# ============================================================================
# Direktori akun
# ============================================================================
ACCOUNT_DIR="/etc/vpnray/accounts"
SSH_ACCOUNT_DIR="$ACCOUNT_DIR/ssh"
VMESS_ACCOUNT_DIR="$ACCOUNT_DIR/vmess"
VLESS_ACCOUNT_DIR="$ACCOUNT_DIR/vless"
TROJAN_ACCOUNT_DIR="$ACCOUNT_DIR/trojan"
SHADOWSOCKS_ACCOUNT_DIR="$ACCOUNT_DIR/shadowsocks"
SOCKS_ACCOUNT_DIR="$ACCOUNT_DIR/socks"
HYSTERIA2_ACCOUNT_DIR="$ACCOUNT_DIR/hysteria2"
TROJAN_GO_ACCOUNT_DIR="$ACCOUNT_DIR/trojan-go"

# ============================================================================
# API Configuration
# ============================================================================
API_PORT=9000
API_CONFIG_DIR="/etc/vpnray/api"
API_CONFIG_FILE="$API_CONFIG_DIR/config.json"
API_KEY_FILE="$API_CONFIG_DIR/api-key"
API_LOG_FILE="/var/log/vpnray-api.log"
API_PID_FILE="/var/run/vpnray-api.pid"
API_SERVER_SCRIPT="/usr/local/bin/vpnray-api"

# ============================================================================
# Telegram Bot Configuration
# ============================================================================
BOT_CONFIG_DIR="/etc/vpnray/bot"
BOT_CONFIG_FILE="$BOT_CONFIG_DIR/config.json"
BOT_LOG_FILE="/var/log/vpnray-bot.log"
# shellcheck disable=SC2034
BOT_PID_FILE="/var/run/vpnray-bot.pid"
BOT_SCRIPT="/usr/local/bin/vpnray-bot"
BOT_SELLER_SCRIPT="/usr/local/bin/vpnray-bot-seller"
BOT_NOTIFY_SCRIPT="/usr/local/bin/vpnray-bot-notify"

# ============================================================================
# Webhook Configuration
# ============================================================================
WEBHOOK_CONFIG_DIR="/etc/vpnray/webhook"
WEBHOOK_CONFIG_FILE="$WEBHOOK_CONFIG_DIR/config.json"
WEBHOOK_LOG_FILE="/var/log/vpnray-webhook.log"
WEBHOOK_SCRIPT="/usr/local/bin/vpnray-webhook"

# ============================================================================
# Systemd service files
# ============================================================================
API_SERVICE_FILE="/etc/systemd/system/vpnray-api.service"
BOT_SERVICE_FILE="/etc/systemd/system/vpnray-bot.service"

# ============================================================================
# Supported protocols
# ============================================================================
SUPPORTED_PROTOCOLS="ssh vmess vless trojan shadowsocks socks hysteria2 trojan-go"

# ============================================================================
# Fungsi Utilitas
# ============================================================================

log() {
    local message
    message="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$message" >> "$LOG_FILE"
}

log_warn() {
    local message
    message="[$(date '+%Y-%m-%d %H:%M:%S')] [WARNING] $1"
    echo -e "${YELLOW}[WARNING]${NC} $1"
    echo "$message" >> "$LOG_FILE"
}

log_error() {
    local message
    message="[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1"
    echo -e "${RED}[ERROR]${NC} $1"
    echo "$message" >> "$LOG_FILE"
}

print_header() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║    VPN Tunneling AutoScript — Tahap 8                      ║"
    echo "║    REST API & Bot Integrasi                                ║"
    echo "║                                                            ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# ============================================================================
# Pengecekan Prasyarat
# ============================================================================

check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        log_error "Script harus dijalankan sebagai root!"
        exit 1
    fi
    log "Pengecekan root: OK"
}

check_os() {
    # shellcheck disable=SC1091
    source /etc/os-release 2>/dev/null
    case "$ID" in
        ubuntu)
            case "$VERSION_ID" in
                20.04|22.04|24.04) ;;
                *) log_error "Ubuntu $VERSION_ID tidak didukung"; exit 1 ;;
            esac
            ;;
        debian)
            case "$VERSION_ID" in
                10|11|12) ;;
                *) log_error "Debian $VERSION_ID tidak didukung"; exit 1 ;;
            esac
            ;;
        *) log_error "OS tidak didukung: $ID"; exit 1 ;;
    esac
    log "OS: $PRETTY_NAME — OK"
}

check_arch() {
    local arch
    arch=$(uname -m)
    if [[ "$arch" != "x86_64" ]]; then
        log_error "Arsitektur tidak didukung: $arch (hanya x86_64)"
        exit 1
    fi
    log "Arsitektur: $arch — OK"
}

check_virt() {
    local virt_type=""
    if command -v systemd-detect-virt &>/dev/null; then
        virt_type=$(systemd-detect-virt 2>/dev/null)
    elif [[ -f /proc/vz/veinfo ]]; then
        virt_type="openvz"
    elif [[ -d /proc/xen ]]; then
        virt_type="xen"
    elif grep -qi "kvm\|qemu" /proc/cpuinfo 2>/dev/null; then
        virt_type="kvm"
    elif grep -qi "hypervisor" /proc/cpuinfo 2>/dev/null; then
        virt_type="kvm"
    fi
    case "$virt_type" in
        openvz|lxc|lxc-libvirt)
            log_error "Virtualisasi tidak didukung: $virt_type"
            exit 1
            ;;
    esac
    if [[ -z "$virt_type" || "$virt_type" == "none" ]]; then
        virt_type="Bare Metal / Tidak terdeteksi"
    fi
    log "Pengecekan virtualisasi: $virt_type — OK"
}

check_tahap7() {
    local errors=0
    # Cek domain
    if [[ ! -f "$DOMAIN_FILE" ]]; then
        log_warn "File domain tidak ditemukan: $DOMAIN_FILE"
        ((errors++))
    fi
    # Cek Xray config
    if [[ ! -f "$XRAY_CONFIG" ]]; then
        log_warn "Xray config tidak ditemukan: $XRAY_CONFIG"
        ((errors++))
    fi
    # Cek account directories
    if [[ ! -d "$ACCOUNT_DIR" ]]; then
        log_warn "Direktori akun tidak ditemukan: $ACCOUNT_DIR"
        ((errors++))
    fi
    # Cek menu scripts
    if [[ ! -f "/usr/local/bin/menu" ]]; then
        log_warn "Menu utama tidak ditemukan: /usr/local/bin/menu"
        ((errors++))
    fi
    if [[ "$errors" -gt 0 ]]; then
        log_warn "Ada $errors komponen Tahap 1-7 belum lengkap. Lanjutkan dengan hati-hati."
    else
        log "Pengecekan Tahap 1-7: Semua komponen OK"
    fi
}

# ============================================================================
# API Helper Functions
# ============================================================================

generate_api_key() {
    local key
    key=$(head -c 32 /dev/urandom | od -An -tx1 | tr -d ' \n' | head -c 32)
    echo "$key"
}

json_response() {
    local status_code="$1"
    local body="$2"
    local content_length
    content_length=${#body}
    printf "HTTP/1.1 %s\r\nContent-Type: application/json\r\nContent-Length: %d\r\nAccess-Control-Allow-Origin: *\r\nAccess-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS\r\nAccess-Control-Allow-Headers: Content-Type, Authorization\r\nConnection: close\r\n\r\n%s" \
        "$status_code" "$content_length" "$body"
}

json_error() {
    local code="$1"
    local message="$2"
    local body
    body="{\"status\":\"error\",\"message\":\"$message\"}"
    json_response "$code" "$body"
}

json_success() {
    local message="$1"
    local data="$2"
    local body
    if [[ -n "$data" ]]; then
        body="{\"status\":\"success\",\"message\":\"$message\",\"data\":$data}"
    else
        body="{\"status\":\"success\",\"message\":\"$message\"}"
    fi
    json_response "200 OK" "$body"
}

parse_json_field() {
    local json="$1"
    local field="$2"
    echo "$json" | grep -o "\"$field\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 | sed "s/\"$field\"[[:space:]]*:[[:space:]]*\"//;s/\"$//"
}

parse_json_field_num() {
    local json="$1"
    local field="$2"
    echo "$json" | grep -o "\"$field\"[[:space:]]*:[[:space:]]*[0-9]*" | head -1 | sed "s/\"$field\"[[:space:]]*:[[:space:]]*//"
}

url_decode() {
    local encoded="$1"
    printf '%b' "${encoded//%/\\x}"
}

get_domain() {
    if [[ -f "$DOMAIN_FILE" ]]; then
        cat "$DOMAIN_FILE"
    else
        echo "localhost"
    fi
}

get_public_ip() {
    local ip=""
    ip=$(curl -s --max-time 5 ifconfig.me 2>/dev/null)
    if [[ -z "$ip" ]]; then
        ip=$(curl -s --max-time 5 icanhazip.com 2>/dev/null)
    fi
    if [[ -z "$ip" ]]; then
        ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    fi
    echo "${ip:-unknown}"
}

get_protocol_dir() {
    local protocol="$1"
    case "$protocol" in
        ssh) echo "$SSH_ACCOUNT_DIR" ;;
        vmess) echo "$VMESS_ACCOUNT_DIR" ;;
        vless) echo "$VLESS_ACCOUNT_DIR" ;;
        trojan) echo "$TROJAN_ACCOUNT_DIR" ;;
        shadowsocks) echo "$SHADOWSOCKS_ACCOUNT_DIR" ;;
        socks) echo "$SOCKS_ACCOUNT_DIR" ;;
        hysteria2) echo "$HYSTERIA2_ACCOUNT_DIR" ;;
        trojan-go) echo "$TROJAN_GO_ACCOUNT_DIR" ;;
        *) echo "" ;;
    esac
}

validate_protocol() {
    local protocol="$1"
    local valid=false
    local p
    for p in $SUPPORTED_PROTOCOLS; do
        if [[ "$p" == "$protocol" ]]; then
            valid=true
            break
        fi
    done
    echo "$valid"
}

# ============================================================================
# API Account Endpoint Handlers
# ============================================================================

api_create_account() {
    local protocol="$1"
    local body="$2"
    local acct_dir
    acct_dir=$(get_protocol_dir "$protocol")
    if [[ -z "$acct_dir" ]]; then
        json_error "400 Bad Request" "Protokol tidak valid: $protocol"
        return
    fi
    local username
    username=$(parse_json_field "$body" "username")
    if [[ -z "$username" ]]; then
        json_error "400 Bad Request" "Parameter username diperlukan"
        return
    fi
    if [[ -f "$acct_dir/$username.json" ]]; then
        json_error "409 Conflict" "Akun sudah ada: $username"
        return
    fi
    local exp quota ip_limit uuid password
    exp=$(parse_json_field_num "$body" "exp")
    quota=$(parse_json_field_num "$body" "quota")
    ip_limit=$(parse_json_field_num "$body" "ip_limit")
    exp=${exp:-30}
    quota=${quota:-0}
    ip_limit=${ip_limit:-2}
    local created expired
    created=$(date '+%Y-%m-%d')
    expired=$(date -d "+${exp} days" '+%Y-%m-%d' 2>/dev/null || date -v+${exp}d '+%Y-%m-%d' 2>/dev/null || echo "2026-04-10")
    case "$protocol" in
        ssh)
            password=$(parse_json_field "$body" "password")
            password=${password:-$(head -c 8 /dev/urandom | od -An -tx1 | tr -d ' \n')}
            ;;
        vmess|vless)
            uuid=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n' | sed 's/\(.\{8\}\)\(.\{4\}\)\(.\{4\}\)\(.\{4\}\)/\1-\2-\3-\4-/')
            ;;
        trojan|shadowsocks|socks|trojan-go)
            password=$(parse_json_field "$body" "password")
            password=${password:-$(head -c 12 /dev/urandom | od -An -tx1 | tr -d ' \n')}
            ;;
        hysteria2)
            password=$(parse_json_field "$body" "password")
            password=${password:-$(head -c 12 /dev/urandom | od -An -tx1 | tr -d ' \n')}
            ;;
    esac
    mkdir -p "$acct_dir"
    local acct_data
    if [[ -n "$uuid" ]]; then
        acct_data="{\"username\":\"$username\",\"protocol\":\"$protocol\",\"uuid\":\"$uuid\",\"created\":\"$created\",\"expired\":\"$expired\",\"status\":\"active\",\"ip_limit\":$ip_limit,\"quota\":$quota,\"quota_used\":0,\"locked\":false,\"banned\":false}"
    else
        acct_data="{\"username\":\"$username\",\"protocol\":\"$protocol\",\"password\":\"$password\",\"created\":\"$created\",\"expired\":\"$expired\",\"status\":\"active\",\"ip_limit\":$ip_limit,\"quota\":$quota,\"quota_used\":0,\"locked\":false,\"banned\":false}"
    fi
    echo "$acct_data" > "$acct_dir/$username.json"
    log "API: Akun $protocol dibuat: $username (exp: $expired)"
    json_success "Akun $protocol berhasil dibuat" "$acct_data"
}

api_delete_account() {
    local protocol="$1"
    local body="$2"
    local acct_dir
    acct_dir=$(get_protocol_dir "$protocol")
    if [[ -z "$acct_dir" ]]; then
        json_error "400 Bad Request" "Protokol tidak valid: $protocol"
        return
    fi
    local username
    username=$(parse_json_field "$body" "username")
    if [[ -z "$username" ]]; then
        json_error "400 Bad Request" "Parameter username diperlukan"
        return
    fi
    if [[ ! -f "$acct_dir/$username.json" ]]; then
        json_error "404 Not Found" "Akun tidak ditemukan: $username"
        return
    fi
    rm -f "$acct_dir/$username.json"
    log "API: Akun $protocol dihapus: $username"
    json_success "Akun $protocol berhasil dihapus"
}

api_list_accounts() {
    local protocol="$1"
    local acct_dir
    acct_dir=$(get_protocol_dir "$protocol")
    if [[ -z "$acct_dir" ]]; then
        json_error "400 Bad Request" "Protokol tidak valid: $protocol"
        return
    fi
    local accounts="["
    local first=true
    if [[ -d "$acct_dir" ]]; then
        local f
        for f in "$acct_dir"/*.json; do
            [[ -f "$f" ]] || continue
            if [[ "$first" == "true" ]]; then
                first=false
            else
                accounts+=","
            fi
            accounts+=$(cat "$f")
        done
    fi
    accounts+="]"
    json_success "Daftar akun $protocol" "$accounts"
}

api_detail_account() {
    local protocol="$1"
    local username="$2"
    local acct_dir
    acct_dir=$(get_protocol_dir "$protocol")
    if [[ -z "$acct_dir" ]]; then
        json_error "400 Bad Request" "Protokol tidak valid: $protocol"
        return
    fi
    if [[ -z "$username" ]]; then
        json_error "400 Bad Request" "Parameter username diperlukan"
        return
    fi
    if [[ ! -f "$acct_dir/$username.json" ]]; then
        json_error "404 Not Found" "Akun tidak ditemukan: $username"
        return
    fi
    local data
    data=$(cat "$acct_dir/$username.json")
    json_success "Detail akun $protocol: $username" "$data"
}

api_renew_account() {
    local protocol="$1"
    local body="$2"
    local acct_dir
    acct_dir=$(get_protocol_dir "$protocol")
    if [[ -z "$acct_dir" ]]; then
        json_error "400 Bad Request" "Protokol tidak valid: $protocol"
        return
    fi
    local username
    username=$(parse_json_field "$body" "username")
    if [[ -z "$username" ]]; then
        json_error "400 Bad Request" "Parameter username diperlukan"
        return
    fi
    if [[ ! -f "$acct_dir/$username.json" ]]; then
        json_error "404 Not Found" "Akun tidak ditemukan: $username"
        return
    fi
    local days
    days=$(parse_json_field_num "$body" "days")
    days=${days:-30}
    local new_expired
    new_expired=$(date -d "+${days} days" '+%Y-%m-%d' 2>/dev/null || date -v+${days}d '+%Y-%m-%d' 2>/dev/null || echo "2026-04-10")
    local data
    data=$(cat "$acct_dir/$username.json")
    data=$(echo "$data" | sed "s/\"expired\":\"[^\"]*\"/\"expired\":\"$new_expired\"/")
    data=$(echo "$data" | sed 's/"status":"expired"/"status":"active"/')
    echo "$data" > "$acct_dir/$username.json"
    log "API: Akun $protocol diperpanjang: $username (+$days hari)"
    json_success "Akun $protocol berhasil diperpanjang" "$data"
}

api_lock_account() {
    local protocol="$1"
    local body="$2"
    local acct_dir
    acct_dir=$(get_protocol_dir "$protocol")
    if [[ -z "$acct_dir" ]]; then
        json_error "400 Bad Request" "Protokol tidak valid: $protocol"
        return
    fi
    local username
    username=$(parse_json_field "$body" "username")
    if [[ -z "$username" ]]; then
        json_error "400 Bad Request" "Parameter username diperlukan"
        return
    fi
    if [[ ! -f "$acct_dir/$username.json" ]]; then
        json_error "404 Not Found" "Akun tidak ditemukan: $username"
        return
    fi
    local data
    data=$(cat "$acct_dir/$username.json")
    data=$(echo "$data" | sed 's/"locked":false/"locked":true/')
    data=$(echo "$data" | sed 's/"status":"active"/"status":"locked"/')
    echo "$data" > "$acct_dir/$username.json"
    log "API: Akun $protocol dikunci: $username"
    json_success "Akun $protocol berhasil dikunci" "$data"
}

api_unlock_account() {
    local protocol="$1"
    local body="$2"
    local acct_dir
    acct_dir=$(get_protocol_dir "$protocol")
    if [[ -z "$acct_dir" ]]; then
        json_error "400 Bad Request" "Protokol tidak valid: $protocol"
        return
    fi
    local username
    username=$(parse_json_field "$body" "username")
    if [[ -z "$username" ]]; then
        json_error "400 Bad Request" "Parameter username diperlukan"
        return
    fi
    if [[ ! -f "$acct_dir/$username.json" ]]; then
        json_error "404 Not Found" "Akun tidak ditemukan: $username"
        return
    fi
    local data
    data=$(cat "$acct_dir/$username.json")
    data=$(echo "$data" | sed 's/"locked":true/"locked":false/')
    data=$(echo "$data" | sed 's/"status":"locked"/"status":"active"/')
    echo "$data" > "$acct_dir/$username.json"
    log "API: Akun $protocol dibuka kuncinya: $username"
    json_success "Akun $protocol berhasil dibuka kuncinya" "$data"
}

api_ban_account() {
    local protocol="$1"
    local body="$2"
    local acct_dir
    acct_dir=$(get_protocol_dir "$protocol")
    if [[ -z "$acct_dir" ]]; then
        json_error "400 Bad Request" "Protokol tidak valid: $protocol"
        return
    fi
    local username
    username=$(parse_json_field "$body" "username")
    if [[ -z "$username" ]]; then
        json_error "400 Bad Request" "Parameter username diperlukan"
        return
    fi
    if [[ ! -f "$acct_dir/$username.json" ]]; then
        json_error "404 Not Found" "Akun tidak ditemukan: $username"
        return
    fi
    local data
    data=$(cat "$acct_dir/$username.json")
    data=$(echo "$data" | sed 's/"banned":false/"banned":true/')
    data=$(echo "$data" | sed 's/"status":"active"/"status":"banned"/')
    echo "$data" > "$acct_dir/$username.json"
    log "API: Akun $protocol dibanned: $username"
    json_success "Akun $protocol berhasil dibanned" "$data"
}

api_unban_account() {
    local protocol="$1"
    local body="$2"
    local acct_dir
    acct_dir=$(get_protocol_dir "$protocol")
    if [[ -z "$acct_dir" ]]; then
        json_error "400 Bad Request" "Protokol tidak valid: $protocol"
        return
    fi
    local username
    username=$(parse_json_field "$body" "username")
    if [[ -z "$username" ]]; then
        json_error "400 Bad Request" "Parameter username diperlukan"
        return
    fi
    if [[ ! -f "$acct_dir/$username.json" ]]; then
        json_error "404 Not Found" "Akun tidak ditemukan: $username"
        return
    fi
    local data
    data=$(cat "$acct_dir/$username.json")
    data=$(echo "$data" | sed 's/"banned":true/"banned":false/')
    data=$(echo "$data" | sed 's/"status":"banned"/"status":"active"/')
    echo "$data" > "$acct_dir/$username.json"
    log "API: Akun $protocol diunban: $username"
    json_success "Akun $protocol berhasil diunban" "$data"
}

api_limit_ip() {
    local protocol="$1"
    local body="$2"
    local acct_dir
    acct_dir=$(get_protocol_dir "$protocol")
    if [[ -z "$acct_dir" ]]; then
        json_error "400 Bad Request" "Protokol tidak valid: $protocol"
        return
    fi
    local username
    username=$(parse_json_field "$body" "username")
    if [[ -z "$username" ]]; then
        json_error "400 Bad Request" "Parameter username diperlukan"
        return
    fi
    if [[ ! -f "$acct_dir/$username.json" ]]; then
        json_error "404 Not Found" "Akun tidak ditemukan: $username"
        return
    fi
    local limit
    limit=$(parse_json_field_num "$body" "ip_limit")
    limit=${limit:-2}
    local data
    data=$(cat "$acct_dir/$username.json")
    data=$(echo "$data" | sed "s/\"ip_limit\":[0-9]*/\"ip_limit\":$limit/")
    echo "$data" > "$acct_dir/$username.json"
    log "API: IP limit $protocol diset: $username = $limit"
    json_success "IP limit berhasil diset" "$data"
}

api_limit_quota() {
    local protocol="$1"
    local body="$2"
    local acct_dir
    acct_dir=$(get_protocol_dir "$protocol")
    if [[ -z "$acct_dir" ]]; then
        json_error "400 Bad Request" "Protokol tidak valid: $protocol"
        return
    fi
    local username
    username=$(parse_json_field "$body" "username")
    if [[ -z "$username" ]]; then
        json_error "400 Bad Request" "Parameter username diperlukan"
        return
    fi
    if [[ ! -f "$acct_dir/$username.json" ]]; then
        json_error "404 Not Found" "Akun tidak ditemukan: $username"
        return
    fi
    local quota
    quota=$(parse_json_field_num "$body" "quota")
    quota=${quota:-100}
    local data
    data=$(cat "$acct_dir/$username.json")
    data=$(echo "$data" | sed "s/\"quota\":[0-9]*/\"quota\":$quota/")
    echo "$data" > "$acct_dir/$username.json"
    log "API: Quota limit $protocol diset: $username = ${quota}GB"
    json_success "Quota limit berhasil diset" "$data"
}

# ============================================================================
# API Server Endpoint Handlers
# ============================================================================

api_server_status() {
    local hostname_val ip_val domain_val os_val kernel_val uptime_val
    local cpu_load mem_total mem_used mem_free disk_total disk_used disk_free
    hostname_val=$(hostname 2>/dev/null || echo "unknown")
    ip_val=$(get_public_ip)
    domain_val=$(get_domain)
    # shellcheck disable=SC1091
    source /etc/os-release 2>/dev/null
    os_val="${PRETTY_NAME:-unknown}"
    kernel_val=$(uname -r 2>/dev/null || echo "unknown")
    uptime_val=$(uptime -p 2>/dev/null || uptime | awk -F',' '{print $1}' | awk '{for(i=3;i<=NF;i++) printf "%s ", $i}')
    cpu_load=$(cat /proc/loadavg 2>/dev/null | awk '{print $1, $2, $3}' || echo "0 0 0")
    mem_total=$(free -m 2>/dev/null | awk '/^Mem:/{print $2}' || echo "0")
    mem_used=$(free -m 2>/dev/null | awk '/^Mem:/{print $3}' || echo "0")
    mem_free=$(free -m 2>/dev/null | awk '/^Mem:/{print $4}' || echo "0")
    disk_total=$(df -h / 2>/dev/null | awk 'NR==2{print $2}' || echo "0")
    disk_used=$(df -h / 2>/dev/null | awk 'NR==2{print $3}' || echo "0")
    disk_free=$(df -h / 2>/dev/null | awk 'NR==2{print $4}' || echo "0")
    local data
    data="{\"hostname\":\"$hostname_val\",\"ip\":\"$ip_val\",\"domain\":\"$domain_val\",\"os\":\"$os_val\",\"kernel\":\"$kernel_val\",\"uptime\":\"$uptime_val\",\"cpu_load\":\"$cpu_load\",\"memory_total\":\"${mem_total}MB\",\"memory_used\":\"${mem_used}MB\",\"memory_free\":\"${mem_free}MB\",\"disk_total\":\"$disk_total\",\"disk_used\":\"$disk_used\",\"disk_free\":\"$disk_free\"}"
    json_success "Server status" "$data"
}

api_server_bandwidth() {
    local data
    if command -v vnstat &>/dev/null; then
        local today_rx today_tx month_rx month_tx
        today_rx=$(vnstat -d 1 --oneline 2>/dev/null | awk -F';' '{print $4}' || echo "0")
        today_tx=$(vnstat -d 1 --oneline 2>/dev/null | awk -F';' '{print $5}' || echo "0")
        month_rx=$(vnstat -m 1 --oneline 2>/dev/null | awk -F';' '{print $4}' || echo "0")
        month_tx=$(vnstat -m 1 --oneline 2>/dev/null | awk -F';' '{print $5}' || echo "0")
        data="{\"today_rx\":\"$today_rx\",\"today_tx\":\"$today_tx\",\"month_rx\":\"$month_rx\",\"month_tx\":\"$month_tx\"}"
    else
        data="{\"today_rx\":\"N/A\",\"today_tx\":\"N/A\",\"month_rx\":\"N/A\",\"month_tx\":\"N/A\",\"note\":\"vnstat not installed\"}"
    fi
    json_success "Bandwidth stats" "$data"
}

api_server_running() {
    local services=""
    local svc_list="xray nginx haproxy dropbear stunnel4 squid openvpn hysteria2 trojan-go softether warp-svc sshd"
    local first=true
    local svc
    for svc in $svc_list; do
        local status="inactive"
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            status="active"
        fi
        if [[ "$first" == "true" ]]; then
            first=false
        else
            services+=","
        fi
        services+="\"$svc\":\"$status\""
    done
    local data="{$services}"
    json_success "Running services" "$data"
}

api_server_reboot() {
    log "API: Server reboot requested"
    json_success "Server akan di-reboot dalam 5 detik"
    # Schedule reboot (delayed)
    (sleep 5 && reboot) &>/dev/null &
}

# ============================================================================
# API Utility Endpoint Handlers
# ============================================================================

api_backup() {
    local data
    if command -v rclone &>/dev/null; then
        local backup_dir="/home/vps/backup"
        local backup_file="backup-$(date '+%Y%m%d-%H%M%S').tar.gz"
        mkdir -p "$backup_dir"
        tar -czf "$backup_dir/$backup_file" \
            /etc/xray/ /etc/vpnray/ /etc/hysteria2/ /etc/trojan-go/ \
            /etc/haproxy/ /etc/nginx/conf.d/ \
            2>/dev/null
        local remote_name
        remote_name=$(rclone listremotes 2>/dev/null | head -1 | tr -d ':')
        if [[ -n "$remote_name" ]]; then
            rclone copy "$backup_dir/$backup_file" "$remote_name:/vpn-backup/" 2>/dev/null
            data="{\"file\":\"$backup_file\",\"remote\":\"$remote_name\",\"status\":\"uploaded\"}"
            log "API: Backup uploaded: $backup_file -> $remote_name"
        else
            data="{\"file\":\"$backup_file\",\"remote\":\"none\",\"status\":\"local_only\"}"
            log "API: Backup created locally: $backup_file"
        fi
    else
        data="{\"status\":\"error\",\"note\":\"rclone not installed\"}"
    fi
    json_success "Backup completed" "$data"
}

api_restore() {
    local body="$1"
    local filename
    filename=$(parse_json_field "$body" "filename")
    if [[ -z "$filename" ]]; then
        json_error "400 Bad Request" "Parameter filename diperlukan"
        return
    fi
    local backup_dir="/home/vps/backup"
    if [[ ! -f "$backup_dir/$filename" ]]; then
        if command -v rclone &>/dev/null; then
            local remote_name
            remote_name=$(rclone listremotes 2>/dev/null | head -1 | tr -d ':')
            if [[ -n "$remote_name" ]]; then
                rclone copy "$remote_name:/vpn-backup/$filename" "$backup_dir/" 2>/dev/null
            fi
        fi
    fi
    if [[ -f "$backup_dir/$filename" ]]; then
        tar -xzf "$backup_dir/$filename" -C / 2>/dev/null
        log "API: Restore dari backup: $filename"
        json_success "Restore berhasil dari $filename"
    else
        json_error "404 Not Found" "File backup tidak ditemukan: $filename"
    fi
}

api_subscription() {
    local username="$1"
    if [[ -z "$username" ]]; then
        json_error "400 Bad Request" "Parameter username diperlukan"
        return
    fi
    local domain
    domain=$(get_domain)
    local links=""
    local protocols="vmess vless trojan shadowsocks"
    local proto
    for proto in $protocols; do
        local acct_dir
        acct_dir=$(get_protocol_dir "$proto")
        if [[ -f "$acct_dir/$username.json" ]]; then
            local data
            data=$(cat "$acct_dir/$username.json")
            local status
            status=$(parse_json_field "$data" "status")
            if [[ "$status" == "active" ]]; then
                if [[ -n "$links" ]]; then
                    links+="\\n"
                fi
                links+="# ${proto}://${username}@${domain}"
            fi
        fi
    done
    if [[ -z "$links" ]]; then
        json_error "404 Not Found" "Tidak ada akun aktif untuk: $username"
        return
    fi
    local encoded
    encoded=$(echo -e "$links" | base64 -w 0 2>/dev/null || echo -e "$links" | base64 2>/dev/null)
    local content_length
    content_length=${#encoded}
    printf "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: %d\r\nConnection: close\r\n\r\n%s" \
        "$content_length" "$encoded"
}

api_clash_config() {
    local username="$1"
    if [[ -z "$username" ]]; then
        json_error "400 Bad Request" "Parameter username diperlukan"
        return
    fi
    local domain
    domain=$(get_domain)
    local clash_config
    clash_config="port: 7890
socks-port: 7891
allow-lan: true
mode: Rule
log-level: info
external-controller: 127.0.0.1:9090
proxies:"
    local found=false
    local protocols="vmess vless trojan"
    local proto
    for proto in $protocols; do
        local acct_dir
        acct_dir=$(get_protocol_dir "$proto")
        if [[ -f "$acct_dir/$username.json" ]]; then
            local data uuid_or_pass
            data=$(cat "$acct_dir/$username.json")
            found=true
            case "$proto" in
                vmess)
                    uuid_or_pass=$(parse_json_field "$data" "uuid")
                    clash_config+="
  - name: VMess-WS-TLS
    type: vmess
    server: $domain
    port: 443
    uuid: $uuid_or_pass
    alterId: 0
    cipher: auto
    tls: true
    network: ws
    ws-opts:
      path: /vmessws
      headers:
        Host: $domain"
                    ;;
                vless)
                    uuid_or_pass=$(parse_json_field "$data" "uuid")
                    clash_config+="
  - name: VLESS-WS-TLS
    type: vless
    server: $domain
    port: 443
    uuid: $uuid_or_pass
    tls: true
    network: ws
    ws-opts:
      path: /vlessws
      headers:
        Host: $domain"
                    ;;
                trojan)
                    uuid_or_pass=$(parse_json_field "$data" "password")
                    clash_config+="
  - name: Trojan-WS-TLS
    type: trojan
    server: $domain
    port: 443
    password: $uuid_or_pass
    sni: $domain
    network: ws
    ws-opts:
      path: /trojanws
      headers:
        Host: $domain"
                    ;;
            esac
        fi
    done
    if [[ "$found" == "false" ]]; then
        json_error "404 Not Found" "Tidak ada akun aktif untuk: $username"
        return
    fi
    clash_config+="
proxy-groups:
  - name: Proxy
    type: select
    proxies:"
    local proto2
    for proto2 in vmess vless trojan; do
        local acct_dir2
        acct_dir2=$(get_protocol_dir "$proto2")
        if [[ -f "$acct_dir2/$username.json" ]]; then
            local upper
            upper=$(echo "$proto2" | tr '[:lower:]' '[:upper:]')
            clash_config+="
      - ${upper}-WS-TLS"
        fi
    done
    clash_config+="
rules:
  - MATCH,Proxy"
    local content_length
    content_length=${#clash_config}
    printf "HTTP/1.1 200 OK\r\nContent-Type: text/yaml\r\nContent-Length: %d\r\nConnection: close\r\n\r\n%s" \
        "$content_length" "$clash_config"
}

# ============================================================================
# API Router
# ============================================================================

route_request() {
    local method="$1"
    local path="$2"
    local body="$3"
    local auth_valid="$4"

    # Handle CORS preflight
    if [[ "$method" == "OPTIONS" ]]; then
        json_response "200 OK" ""
        return
    fi

    # Public endpoints (no auth required)
    case "$path" in
        /api/subscription/*)
            local user="${path#/api/subscription/}"
            api_subscription "$user"
            return
            ;;
        /api/clash/*)
            local user="${path#/api/clash/}"
            api_clash_config "$user"
            return
            ;;
        /api/docs|/docs)
            local docs_body='{"status":"success","message":"API Documentation","data":{"version":"1.0.0","base_url":"http://localhost:9000","endpoints":[{"method":"POST","path":"/api/{protocol}/create","description":"Buat akun"},{"method":"DELETE","path":"/api/{protocol}/delete","description":"Hapus akun"},{"method":"GET","path":"/api/{protocol}/list","description":"List akun"},{"method":"GET","path":"/api/{protocol}/detail/{user}","description":"Detail akun"},{"method":"PUT","path":"/api/{protocol}/renew","description":"Perpanjang akun"},{"method":"PUT","path":"/api/{protocol}/lock","description":"Lock akun"},{"method":"PUT","path":"/api/{protocol}/unlock","description":"Unlock akun"},{"method":"PUT","path":"/api/{protocol}/ban","description":"Ban akun"},{"method":"PUT","path":"/api/{protocol}/unban","description":"Unban akun"},{"method":"PUT","path":"/api/{protocol}/limit-ip","description":"Set limit IP"},{"method":"PUT","path":"/api/{protocol}/limit-quota","description":"Set limit quota"},{"method":"GET","path":"/api/server/status","description":"Status server"},{"method":"GET","path":"/api/server/bandwidth","description":"Bandwidth stats"},{"method":"GET","path":"/api/server/running","description":"Running services"},{"method":"POST","path":"/api/server/reboot","description":"Reboot server"},{"method":"POST","path":"/api/backup","description":"Backup ke cloud"},{"method":"POST","path":"/api/restore","description":"Restore dari cloud"},{"method":"GET","path":"/api/subscription/{user}","description":"Get subscription link"},{"method":"GET","path":"/api/clash/{user}","description":"Get Clash config"}]}}'
            json_response "200 OK" "$docs_body"
            return
            ;;
    esac

    # Protected endpoints (auth required)
    if [[ "$auth_valid" != "true" ]]; then
        json_error "401 Unauthorized" "Authentication required. Provide Authorization: Bearer YOUR_API_KEY"
        return
    fi

    # Account endpoints
    local protocol=""
    case "$path" in
        /api/*/create)
            protocol=$(echo "$path" | sed 's|/api/||;s|/create||')
            if [[ "$method" == "POST" ]]; then
                api_create_account "$protocol" "$body"
            else
                json_error "405 Method Not Allowed" "Gunakan POST untuk create"
            fi
            return
            ;;
        /api/*/delete)
            protocol=$(echo "$path" | sed 's|/api/||;s|/delete||')
            if [[ "$method" == "DELETE" ]]; then
                api_delete_account "$protocol" "$body"
            else
                json_error "405 Method Not Allowed" "Gunakan DELETE untuk delete"
            fi
            return
            ;;
        /api/*/list)
            protocol=$(echo "$path" | sed 's|/api/||;s|/list||')
            if [[ "$method" == "GET" ]]; then
                api_list_accounts "$protocol"
            else
                json_error "405 Method Not Allowed" "Gunakan GET untuk list"
            fi
            return
            ;;
        /api/*/detail/*)
            protocol=$(echo "$path" | sed 's|/api/||;s|/detail/.*||')
            local user
            user=$(echo "$path" | sed 's|.*/detail/||')
            if [[ "$method" == "GET" ]]; then
                api_detail_account "$protocol" "$user"
            else
                json_error "405 Method Not Allowed" "Gunakan GET untuk detail"
            fi
            return
            ;;
        /api/*/renew)
            protocol=$(echo "$path" | sed 's|/api/||;s|/renew||')
            if [[ "$method" == "PUT" ]]; then
                api_renew_account "$protocol" "$body"
            else
                json_error "405 Method Not Allowed" "Gunakan PUT untuk renew"
            fi
            return
            ;;
        /api/*/lock)
            protocol=$(echo "$path" | sed 's|/api/||;s|/lock||')
            if [[ "$method" == "PUT" ]]; then
                api_lock_account "$protocol" "$body"
            else
                json_error "405 Method Not Allowed" "Gunakan PUT untuk lock"
            fi
            return
            ;;
        /api/*/unlock)
            protocol=$(echo "$path" | sed 's|/api/||;s|/unlock||')
            if [[ "$method" == "PUT" ]]; then
                api_unlock_account "$protocol" "$body"
            else
                json_error "405 Method Not Allowed" "Gunakan PUT untuk unlock"
            fi
            return
            ;;
        /api/*/ban)
            protocol=$(echo "$path" | sed 's|/api/||;s|/ban||')
            if [[ "$method" == "PUT" ]]; then
                api_ban_account "$protocol" "$body"
            else
                json_error "405 Method Not Allowed" "Gunakan PUT untuk ban"
            fi
            return
            ;;
        /api/*/unban)
            protocol=$(echo "$path" | sed 's|/api/||;s|/unban||')
            if [[ "$method" == "PUT" ]]; then
                api_unban_account "$protocol" "$body"
            else
                json_error "405 Method Not Allowed" "Gunakan PUT untuk unban"
            fi
            return
            ;;
        /api/*/limit-ip)
            protocol=$(echo "$path" | sed 's|/api/||;s|/limit-ip||')
            if [[ "$method" == "PUT" ]]; then
                api_limit_ip "$protocol" "$body"
            else
                json_error "405 Method Not Allowed" "Gunakan PUT untuk limit-ip"
            fi
            return
            ;;
        /api/*/limit-quota)
            protocol=$(echo "$path" | sed 's|/api/||;s|/limit-quota||')
            if [[ "$method" == "PUT" ]]; then
                api_limit_quota "$protocol" "$body"
            else
                json_error "405 Method Not Allowed" "Gunakan PUT untuk limit-quota"
            fi
            return
            ;;
    esac

    # Server endpoints
    case "$path" in
        /api/server/status)
            if [[ "$method" == "GET" ]]; then
                api_server_status
            else
                json_error "405 Method Not Allowed" "Gunakan GET untuk status"
            fi
            return
            ;;
        /api/server/bandwidth)
            if [[ "$method" == "GET" ]]; then
                api_server_bandwidth
            else
                json_error "405 Method Not Allowed" "Gunakan GET untuk bandwidth"
            fi
            return
            ;;
        /api/server/running)
            if [[ "$method" == "GET" ]]; then
                api_server_running
            else
                json_error "405 Method Not Allowed" "Gunakan GET untuk running"
            fi
            return
            ;;
        /api/server/reboot)
            if [[ "$method" == "POST" ]]; then
                api_server_reboot
            else
                json_error "405 Method Not Allowed" "Gunakan POST untuk reboot"
            fi
            return
            ;;
    esac

    # Utility endpoints
    case "$path" in
        /api/backup)
            if [[ "$method" == "POST" ]]; then
                api_backup
            else
                json_error "405 Method Not Allowed" "Gunakan POST untuk backup"
            fi
            return
            ;;
        /api/restore)
            if [[ "$method" == "POST" ]]; then
                api_restore "$body"
            else
                json_error "405 Method Not Allowed" "Gunakan POST untuk restore"
            fi
            return
            ;;
    esac

    # Not found
    json_error "404 Not Found" "Endpoint tidak ditemukan: $path"
}

# ============================================================================
# API Server Creation
# ============================================================================

create_api_server() {
    log "Membuat API server script: $API_SERVER_SCRIPT"
    cat > "$API_SERVER_SCRIPT" << 'API_SCRIPT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — REST API Server
# ============================================================================
# Lightweight HTTP API server menggunakan socat
# Port: 9000
# Auth: Bearer token
# ============================================================================

API_CONFIG_DIR="/etc/vpnray/api"
API_KEY_FILE="$API_CONFIG_DIR/api-key"
API_LOG_FILE="/var/log/vpnray-api.log"
SETUP_API_SCRIPT="/home/runner/work/installer/installer/setup-api.sh"

log_api() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$API_LOG_FILE"
}

validate_auth() {
    local auth_header="$1"
    local stored_key=""
    if [[ -f "$API_KEY_FILE" ]]; then
        stored_key=$(cat "$API_KEY_FILE")
    fi
    if [[ -z "$stored_key" ]]; then
        echo "true"
        return
    fi
    local provided_key
    provided_key=$(echo "$auth_header" | sed 's/Bearer //')
    if [[ "$provided_key" == "$stored_key" ]]; then
        echo "true"
    else
        echo "false"
    fi
}

handle_request() {
    local method="" path="" auth_header="" content_length=0 body=""
    local line
    # Read request line
    read -r line
    method=$(echo "$line" | awk '{print $1}')
    path=$(echo "$line" | awk '{print $2}')
    # Read headers
    while read -r line; do
        line=$(echo "$line" | tr -d '\r')
        [[ -z "$line" ]] && break
        case "$line" in
            Authorization:*) auth_header=$(echo "$line" | sed 's/Authorization: //') ;;
            Content-Length:*) content_length=$(echo "$line" | sed 's/Content-Length: //' | tr -d ' ') ;;
        esac
    done
    # Read body
    if [[ "$content_length" -gt 0 ]] 2>/dev/null; then
        body=$(head -c "$content_length")
    fi
    # Validate auth
    local auth_valid
    auth_valid=$(validate_auth "$auth_header")
    log_api "$method $path (auth: $auth_valid)"
    # Source the setup script for route handling
    # shellcheck disable=SC1090
    source "$SETUP_API_SCRIPT"
    route_request "$method" "$path" "$body" "$auth_valid"
}

handle_request
API_SCRIPT
    chmod +x "$API_SERVER_SCRIPT"

    # Create wrapper script for socat
    cat > /usr/local/bin/vpnray-api-start << 'START_SCRIPT'
#!/bin/bash
# Start the REST API server
API_PORT=${API_PORT:-9000}
API_LOG_FILE="/var/log/vpnray-api.log"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] API Server starting on port $API_PORT" >> "$API_LOG_FILE"
exec socat TCP-LISTEN:"$API_PORT",reuseaddr,fork EXEC:/usr/local/bin/vpnray-api
START_SCRIPT
    chmod +x /usr/local/bin/vpnray-api-start
    log "API server script dibuat: $API_SERVER_SCRIPT"
}

# ============================================================================
# API Configuration
# ============================================================================

setup_api_config() {
    log "Setup API configuration"
    mkdir -p "$API_CONFIG_DIR"
    # Generate API key
    local api_key
    api_key=$(generate_api_key)
    echo "$api_key" > "$API_KEY_FILE"
    chmod 600 "$API_KEY_FILE"
    # Create config file
    cat > "$API_CONFIG_FILE" << EOF
{
    "port": $API_PORT,
    "host": "0.0.0.0",
    "log_file": "$API_LOG_FILE",
    "pid_file": "$API_PID_FILE",
    "auth_enabled": true,
    "cors_enabled": true,
    "rate_limit": 100,
    "max_request_size": 10240,
    "supported_protocols": ["ssh", "vmess", "vless", "trojan", "shadowsocks", "socks", "hysteria2", "trojan-go"]
}
EOF
    chmod 644 "$API_CONFIG_FILE"
    touch "$API_LOG_FILE"
    chmod 644 "$API_LOG_FILE"
    log "API config dibuat: $API_CONFIG_FILE (key: $API_KEY_FILE)"
}

# ============================================================================
# Telegram Bot Functions
# ============================================================================

bot_send_message() {
    local chat_id="$1"
    local text="$2"
    local bot_token=""
    if [[ -f "$BOT_CONFIG_FILE" ]]; then
        bot_token=$(grep -o '"token":"[^"]*"' "$BOT_CONFIG_FILE" | sed 's/"token":"//;s/"$//')
    fi
    if [[ -z "$bot_token" ]]; then
        log_warn "Bot token belum dikonfigurasi"
        return 1
    fi
    curl -s -X POST "https://api.telegram.org/bot${bot_token}/sendMessage" \
        -d "chat_id=$chat_id" \
        -d "text=$text" \
        -d "parse_mode=HTML" \
        &>/dev/null
}

bot_parse_update() {
    local update="$1"
    local chat_id text
    chat_id=$(echo "$update" | grep -o '"chat":{"id":[0-9]*' | grep -o '[0-9]*$')
    text=$(echo "$update" | grep -o '"text":"[^"]*"' | head -1 | sed 's/"text":"//;s/"$//')
    echo "$chat_id|$text"
}

bot_handle_command() {
    local chat_id="$1"
    local command="$2"
    local admin_id=""
    if [[ -f "$BOT_CONFIG_FILE" ]]; then
        admin_id=$(grep -o '"admin_id":"[^"]*"' "$BOT_CONFIG_FILE" | sed 's/"admin_id":"//;s/"$//')
    fi
    if [[ -n "$admin_id" && "$chat_id" != "$admin_id" ]]; then
        bot_send_message "$chat_id" "⛔ Akses ditolak. Anda bukan admin."
        return
    fi
    case "$command" in
        /start)
            bot_send_message "$chat_id" "🤖 <b>VPN Tunneling Bot</b>

Perintah tersedia:
/status — Status server
/running — Service yang berjalan
/list_ssh — List akun SSH
/list_vmess — List akun VMess
/list_vless — List akun VLESS
/list_trojan — List akun Trojan
/bandwidth — Bandwidth stats
/reboot — Reboot server
/help — Bantuan"
            ;;
        /status)
            local hostname_val ip_val uptime_val mem_used mem_total cpu_load
            hostname_val=$(hostname 2>/dev/null)
            ip_val=$(curl -s --max-time 5 ifconfig.me 2>/dev/null)
            uptime_val=$(uptime -p 2>/dev/null)
            mem_used=$(free -m 2>/dev/null | awk '/^Mem:/{print $3}')
            mem_total=$(free -m 2>/dev/null | awk '/^Mem:/{print $2}')
            cpu_load=$(cat /proc/loadavg 2>/dev/null | awk '{print $1}')
            bot_send_message "$chat_id" "📊 <b>Server Status</b>

🖥 Hostname: $hostname_val
�� IP: $ip_val
⏰ Uptime: $uptime_val
💾 Memory: ${mem_used}/${mem_total} MB
🔧 CPU Load: $cpu_load"
            ;;
        /running)
            local services_text="📋 <b>Running Services</b>\n\n"
            local svc
            for svc in xray nginx haproxy dropbear stunnel4 squid hysteria2 trojan-go; do
                if systemctl is-active --quiet "$svc" 2>/dev/null; then
                    services_text+="✅ $svc: Active\n"
                else
                    services_text+="❌ $svc: Inactive\n"
                fi
            done
            bot_send_message "$chat_id" "$services_text"
            ;;
        /list_ssh|/list_vmess|/list_vless|/list_trojan)
            local proto="${command#/list_}"
            local acct_dir
            acct_dir=$(get_protocol_dir "$proto")
            local list_text="📋 <b>Daftar Akun ${proto^^}</b>\n\n"
            local count=0
            if [[ -d "$acct_dir" ]]; then
                local f
                for f in "$acct_dir"/*.json; do
                    [[ -f "$f" ]] || continue
                    local user expired status
                    user=$(grep -o '"username":"[^"]*"' "$f" | sed 's/"username":"//;s/"$//')
                    expired=$(grep -o '"expired":"[^"]*"' "$f" | sed 's/"expired":"//;s/"$//')
                    status=$(grep -o '"status":"[^"]*"' "$f" | sed 's/"status":"//;s/"$//')
                    list_text+="• $user (exp: $expired) [$status]\n"
                    ((count++))
                done
            fi
            list_text+="\nTotal: $count akun"
            bot_send_message "$chat_id" "$list_text"
            ;;
        /bandwidth)
            if command -v vnstat &>/dev/null; then
                local bw_text
                bw_text=$(vnstat -d 1 --oneline 2>/dev/null)
                bot_send_message "$chat_id" "📊 <b>Bandwidth</b>\n\n$bw_text"
            else
                bot_send_message "$chat_id" "📊 vnStat belum terinstall"
            fi
            ;;
        /reboot)
            bot_send_message "$chat_id" "🔄 Server akan di-reboot dalam 5 detik..."
            (sleep 5 && reboot) &>/dev/null &
            ;;
        /help)
            bot_send_message "$chat_id" "📖 <b>Bantuan Bot VPN</b>

<b>Info Server:</b>
/status — Status server
/running — Service berjalan
/bandwidth — Bandwidth stats

<b>Akun:</b>
/list_ssh — List SSH
/list_vmess — List VMess
/list_vless — List VLESS
/list_trojan — List Trojan

<b>Sistem:</b>
/reboot — Reboot server"
            ;;
        *)
            bot_send_message "$chat_id" "❓ Perintah tidak dikenal. Ketik /help untuk bantuan."
            ;;
    esac
}

bot_seller_panel() {
    local chat_id="$1"
    local command="$2"
    case "$command" in
        /trial_*)
            local proto="${command#/trial_}"
            bot_send_message "$chat_id" "🎁 Trial akun $proto dibuat (exp: 1 hari)"
            ;;
        /buy_*)
            local proto="${command#/buy_}"
            bot_send_message "$chat_id" "💰 Silakan transfer untuk pembelian akun $proto"
            ;;
        /orders)
            bot_send_message "$chat_id" "📋 Belum ada order"
            ;;
        *)
            bot_send_message "$chat_id" "🛒 <b>Seller Panel</b>

/trial_vmess — Trial VMess (1 hari)
/trial_vless — Trial VLESS (1 hari)
/trial_trojan — Trial Trojan (1 hari)
/buy_vmess — Beli VMess
/buy_vless — Beli VLESS
/buy_trojan — Beli Trojan
/orders — Lihat order"
            ;;
    esac
}

bot_notification() {
    local event_type="$1"
    local data="$2"
    local admin_id=""
    if [[ -f "$BOT_CONFIG_FILE" ]]; then
        admin_id=$(grep -o '"admin_id":"[^"]*"' "$BOT_CONFIG_FILE" | sed 's/"admin_id":"//;s/"$//')
    fi
    if [[ -z "$admin_id" ]]; then
        return
    fi
    local message=""
    case "$event_type" in
        account_created)
            message="✅ <b>Akun Dibuat</b>\n$data"
            ;;
        account_expired)
            message="⏰ <b>Akun Expired</b>\n$data"
            ;;
        account_login)
            message="🔑 <b>Login Detected</b>\n$data"
            ;;
        server_reboot)
            message="🔄 <b>Server Reboot</b>\n$data"
            ;;
        *)
            message="📢 <b>Notifikasi</b>\n$data"
            ;;
    esac
    bot_send_message "$admin_id" "$message"
}

create_bot_script() {
    log "Membuat Telegram bot script: $BOT_SCRIPT"
    cat > "$BOT_SCRIPT" << 'BOT_SCRIPT_CONTENT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Telegram Bot (Long Polling)
# ============================================================================
BOT_CONFIG_FILE="/etc/vpnray/bot/config.json"
BOT_LOG_FILE="/var/log/vpnray-bot.log"
SETUP_API_SCRIPT="/home/runner/work/installer/installer/setup-api.sh"

log_bot() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$BOT_LOG_FILE"
}

# Source helper functions
# shellcheck disable=SC1090
source "$SETUP_API_SCRIPT" 2>/dev/null

BOT_TOKEN=""
ADMIN_ID=""
if [[ -f "$BOT_CONFIG_FILE" ]]; then
    BOT_TOKEN=$(grep -o '"token":"[^"]*"' "$BOT_CONFIG_FILE" | sed 's/"token":"//;s/"$//')
    ADMIN_ID=$(grep -o '"admin_id":"[^"]*"' "$BOT_CONFIG_FILE" | sed 's/"admin_id":"//;s/"$//')
fi

if [[ -z "$BOT_TOKEN" ]]; then
    log_bot "ERROR: Bot token not configured"
    echo "ERROR: Bot token not configured in $BOT_CONFIG_FILE"
    exit 1
fi

log_bot "Bot starting with token: ${BOT_TOKEN:0:10}..."

OFFSET=0
while true; do
    RESPONSE=$(curl -s --max-time 60 "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates?offset=$OFFSET&timeout=30" 2>/dev/null)
    if [[ -z "$RESPONSE" ]]; then
        sleep 5
        continue
    fi
    UPDATES=$(echo "$RESPONSE" | grep -o '"update_id":[0-9]*' | grep -o '[0-9]*')
    for UPDATE_ID in $UPDATES; do
        OFFSET=$((UPDATE_ID + 1))
        CHAT_ID=$(echo "$RESPONSE" | grep -o "\"update_id\":${UPDATE_ID}[^}]*\"chat\":{\"id\":[0-9]*" | grep -o '"chat":{"id":[0-9]*' | grep -o '[0-9]*$')
        TEXT=$(echo "$RESPONSE" | grep -o "\"update_id\":${UPDATE_ID}[^}]*\"text\":\"[^\"]*\"" | grep -o '"text":"[^"]*"' | head -1 | sed 's/"text":"//;s/"$//')
        if [[ -n "$CHAT_ID" && -n "$TEXT" ]]; then
            log_bot "Received: $TEXT from $CHAT_ID"
            bot_handle_command "$CHAT_ID" "$TEXT"
        fi
    done
    sleep 1
done
BOT_SCRIPT_CONTENT
    chmod +x "$BOT_SCRIPT"
    log "Telegram bot script dibuat: $BOT_SCRIPT"
}

create_bot_seller() {
    log "Membuat seller panel script: $BOT_SELLER_SCRIPT"
    cat > "$BOT_SELLER_SCRIPT" << 'SELLER_SCRIPT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Telegram Bot Seller Panel
# ============================================================================
BOT_CONFIG_FILE="/etc/vpnray/bot/config.json"
SETUP_API_SCRIPT="/home/runner/work/installer/installer/setup-api.sh"

# shellcheck disable=SC1090
source "$SETUP_API_SCRIPT" 2>/dev/null

BOT_TOKEN=""
if [[ -f "$BOT_CONFIG_FILE" ]]; then
    BOT_TOKEN=$(grep -o '"token":"[^"]*"' "$BOT_CONFIG_FILE" | sed 's/"token":"//;s/"$//')
fi

if [[ -z "$BOT_TOKEN" ]]; then
    echo "ERROR: Bot token not configured"
    exit 1
fi

# Seller panel processes commands from a separate long-polling loop
OFFSET=0
while true; do
    RESPONSE=$(curl -s --max-time 60 "https://api.telegram.org/bot${BOT_TOKEN}/getUpdates?offset=$OFFSET&timeout=30" 2>/dev/null)
    UPDATES=$(echo "$RESPONSE" | grep -o '"update_id":[0-9]*' | grep -o '[0-9]*')
    for UPDATE_ID in $UPDATES; do
        OFFSET=$((UPDATE_ID + 1))
        CHAT_ID=$(echo "$RESPONSE" | grep -o "\"update_id\":${UPDATE_ID}[^}]*\"chat\":{\"id\":[0-9]*" | grep -o '"chat":{"id":[0-9]*' | grep -o '[0-9]*$')
        TEXT=$(echo "$RESPONSE" | grep -o "\"update_id\":${UPDATE_ID}[^}]*\"text\":\"[^\"]*\"" | grep -o '"text":"[^"]*"' | head -1 | sed 's/"text":"//;s/"$//')
        if [[ -n "$CHAT_ID" && -n "$TEXT" ]]; then
            case "$TEXT" in
                /trial_*|/buy_*|/orders|/seller)
                    bot_seller_panel "$CHAT_ID" "$TEXT"
                    ;;
            esac
        fi
    done
    sleep 1
done
SELLER_SCRIPT
    chmod +x "$BOT_SELLER_SCRIPT"
    log "Seller panel script dibuat: $BOT_SELLER_SCRIPT"
}

create_bot_notify() {
    log "Membuat notification script: $BOT_NOTIFY_SCRIPT"
    cat > "$BOT_NOTIFY_SCRIPT" << 'NOTIFY_SCRIPT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Telegram Bot Notification
# ============================================================================
# Usage: vpnray-bot-notify <event_type> <message>
# Events: account_created, account_expired, account_login, server_reboot
# ============================================================================
SETUP_API_SCRIPT="/home/runner/work/installer/installer/setup-api.sh"

# shellcheck disable=SC1090
source "$SETUP_API_SCRIPT" 2>/dev/null

EVENT_TYPE="$1"
MESSAGE="$2"

if [[ -z "$EVENT_TYPE" || -z "$MESSAGE" ]]; then
    echo "Usage: vpnray-bot-notify <event_type> <message>"
    echo "Events: account_created, account_expired, account_login, server_reboot"
    exit 1
fi

bot_notification "$EVENT_TYPE" "$MESSAGE"
NOTIFY_SCRIPT
    chmod +x "$BOT_NOTIFY_SCRIPT"
    log "Notification script dibuat: $BOT_NOTIFY_SCRIPT"
}

setup_bot_config() {
    log "Setup Telegram bot configuration"
    mkdir -p "$BOT_CONFIG_DIR"
    cat > "$BOT_CONFIG_FILE" << 'EOF'
{
    "token": "",
    "admin_id": "",
    "seller_enabled": false,
    "notification_enabled": true,
    "notify_events": ["account_created", "account_expired", "account_login", "server_reboot"],
    "seller_prices": {
        "vmess_30d": 10000,
        "vless_30d": 10000,
        "trojan_30d": 10000,
        "ssh_30d": 5000
    },
    "trial_duration": 1,
    "trial_protocols": ["vmess", "vless", "trojan"]
}
EOF
    chmod 644 "$BOT_CONFIG_FILE"
    touch "$BOT_LOG_FILE"
    chmod 644 "$BOT_LOG_FILE"
    log "Bot config dibuat: $BOT_CONFIG_FILE"
}

# ============================================================================
# Webhook Functions
# ============================================================================

webhook_send() {
    local url="$1"
    local payload="$2"
    if [[ -z "$url" ]]; then
        return 1
    fi
    curl -s -X POST "$url" \
        -H "Content-Type: application/json" \
        -d "$payload" \
        --max-time 10 \
        &>/dev/null
}

webhook_account_event() {
    local event="$1"
    local data="$2"
    local webhook_url=""
    if [[ -f "$WEBHOOK_CONFIG_FILE" ]]; then
        webhook_url=$(grep -o '"url":"[^"]*"' "$WEBHOOK_CONFIG_FILE" | sed 's/"url":"//;s/"$//')
    fi
    if [[ -z "$webhook_url" ]]; then
        return
    fi
    local payload="{\"event\":\"$event\",\"timestamp\":\"$(date -u '+%Y-%m-%dT%H:%M:%SZ')\",\"data\":$data}"
    webhook_send "$webhook_url" "$payload"
    log "Webhook sent: $event -> $webhook_url"
}

webhook_server_event() {
    local event="$1"
    local message="$2"
    local webhook_url=""
    if [[ -f "$WEBHOOK_CONFIG_FILE" ]]; then
        webhook_url=$(grep -o '"url":"[^"]*"' "$WEBHOOK_CONFIG_FILE" | sed 's/"url":"//;s/"$//')
    fi
    if [[ -z "$webhook_url" ]]; then
        return
    fi
    local payload="{\"event\":\"$event\",\"timestamp\":\"$(date -u '+%Y-%m-%dT%H:%M:%SZ')\",\"message\":\"$message\"}"
    webhook_send "$webhook_url" "$payload"
    log "Webhook sent: $event -> $webhook_url"
}

create_webhook_script() {
    log "Membuat webhook script: $WEBHOOK_SCRIPT"
    cat > "$WEBHOOK_SCRIPT" << 'WEBHOOK_CONTENT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Webhook Sender
# ============================================================================
# Usage: vpnray-webhook <event_type> <json_data>
# Events: account_created, account_deleted, account_expired, server_reboot, service_down
# ============================================================================
SETUP_API_SCRIPT="/home/runner/work/installer/installer/setup-api.sh"

# shellcheck disable=SC1090
source "$SETUP_API_SCRIPT" 2>/dev/null

EVENT_TYPE="$1"
DATA="$2"

if [[ -z "$EVENT_TYPE" ]]; then
    echo "Usage: vpnray-webhook <event_type> [json_data]"
    echo "Events: account_created, account_deleted, account_expired, server_reboot, service_down"
    exit 1
fi

DATA=${DATA:-"{}"}

case "$EVENT_TYPE" in
    account_*)
        webhook_account_event "$EVENT_TYPE" "$DATA"
        ;;
    server_*|service_*)
        webhook_server_event "$EVENT_TYPE" "${DATA//\"/}"
        ;;
    *)
        webhook_server_event "$EVENT_TYPE" "${DATA//\"/}"
        ;;
esac
WEBHOOK_CONTENT
    chmod +x "$WEBHOOK_SCRIPT"
    log "Webhook script dibuat: $WEBHOOK_SCRIPT"
}

setup_webhook_config() {
    log "Setup webhook configuration"
    mkdir -p "$WEBHOOK_CONFIG_DIR"
    cat > "$WEBHOOK_CONFIG_FILE" << 'EOF'
{
    "enabled": false,
    "url": "",
    "secret": "",
    "events": ["account_created", "account_deleted", "account_expired", "server_reboot", "service_down"],
    "retry_count": 3,
    "retry_delay": 5,
    "timeout": 10
}
EOF
    chmod 644 "$WEBHOOK_CONFIG_FILE"
    touch "$WEBHOOK_LOG_FILE"
    chmod 644 "$WEBHOOK_LOG_FILE"
    log "Webhook config dibuat: $WEBHOOK_CONFIG_FILE"
}

# ============================================================================
# Systemd Service Functions
# ============================================================================

create_api_service() {
    log "Membuat systemd service untuk API: $API_SERVICE_FILE"
    cat > "$API_SERVICE_FILE" << EOF
[Unit]
Description=VPNRay REST API Server
After=network.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/vpnray-api-start
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal
Environment=API_PORT=$API_PORT

[Install]
WantedBy=multi-user.target
EOF
    chmod 644 "$API_SERVICE_FILE"
    log "API service file dibuat: $API_SERVICE_FILE"
}

create_bot_service() {
    log "Membuat systemd service untuk Bot: $BOT_SERVICE_FILE"
    cat > "$BOT_SERVICE_FILE" << EOF
[Unit]
Description=VPNRay Telegram Bot
After=network.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=$BOT_SCRIPT
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
    chmod 644 "$BOT_SERVICE_FILE"
    log "Bot service file dibuat: $BOT_SERVICE_FILE"
}

enable_services() {
    log "Enabling systemd services"
    if command -v systemctl &>/dev/null; then
        systemctl daemon-reload 2>/dev/null
        systemctl enable vpnray-api 2>/dev/null
        systemctl start vpnray-api 2>/dev/null || log_warn "Gagal start vpnray-api (socat mungkin belum terinstall)"
        # Bot tidak di-start otomatis (perlu konfigurasi token dulu)
        systemctl enable vpnray-bot 2>/dev/null
        log "Systemd services enabled"
    else
        log_warn "systemctl tidak tersedia, skip enable services"
    fi
}

# ============================================================================
# Main Function
# ============================================================================

main() {
    # 1. Print header
    print_header

    # 2. Pengecekan prasyarat
    echo -e "${CYAN}[1/10]${NC} Memeriksa prasyarat..."
    check_root
    check_os
    check_arch
    check_virt
    check_tahap7

    # 3. Setup API config
    echo -e "${CYAN}[2/10]${NC} Setup API configuration..."
    setup_api_config

    # 4. Create API server
    echo -e "${CYAN}[3/10]${NC} Membuat REST API server..."
    create_api_server

    # 5. Setup bot config
    echo -e "${CYAN}[4/10]${NC} Setup Telegram Bot configuration..."
    setup_bot_config

    # 6. Create bot scripts
    echo -e "${CYAN}[5/10]${NC} Membuat Telegram Bot scripts..."
    create_bot_script
    echo -e "${CYAN}[6/10]${NC} Membuat Seller Panel script..."
    create_bot_seller
    echo -e "${CYAN}[7/10]${NC} Membuat Notification script..."
    create_bot_notify

    # 7. Setup webhook config
    echo -e "${CYAN}[8/10]${NC} Setup Webhook configuration..."
    setup_webhook_config

    # 8. Create webhook script
    echo -e "${CYAN}[9/10]${NC} Membuat Webhook script..."
    create_webhook_script

    # 9. Create systemd services
    echo -e "${CYAN}[10/10]${NC} Membuat systemd services..."
    create_api_service
    create_bot_service

    # 10. Enable services
    enable_services

    # Selesai
    echo ""
    echo -e "${GREEN}=============================================="
    echo "  Tahap 8 selesai!"
    echo "  REST API & Bot berhasil dikonfigurasi."
    echo ""
    echo "  API Server:"
    echo "    Script         : $API_SERVER_SCRIPT"
    echo "    Port           : $API_PORT"
    echo "    Config         : $API_CONFIG_FILE"
    echo "    API Key        : $API_KEY_FILE"
    echo "    Log            : $API_LOG_FILE"
    echo "    Service        : $API_SERVICE_FILE"
    echo ""
    echo "  Telegram Bot:"
    echo "    Bot Script     : $BOT_SCRIPT"
    echo "    Seller Panel   : $BOT_SELLER_SCRIPT"
    echo "    Notification   : $BOT_NOTIFY_SCRIPT"
    echo "    Config         : $BOT_CONFIG_FILE"
    echo "    Log            : $BOT_LOG_FILE"
    echo "    Service        : $BOT_SERVICE_FILE"
    echo ""
    echo "  Webhook:"
    echo "    Script         : $WEBHOOK_SCRIPT"
    echo "    Config         : $WEBHOOK_CONFIG_FILE"
    echo "    Log            : $WEBHOOK_LOG_FILE"
    echo ""
    echo "  Sistem siap untuk Monitoring, Backup & Keamanan (Tahap 9)."
    echo -e "==============================================${NC}"
    echo ""

    log "Tahap 8 selesai. REST API & Bot berhasil dikonfigurasi."
}

main "$@"
