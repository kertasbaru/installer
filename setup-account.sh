#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript Installer — Tahap 6: Manajemen Akun & User
# ============================================================================
# Script manajemen akun untuk semua protokol. Setiap protokol memiliki
# operasi CRUD lengkap: create, delete, extend, lock/unlock, ban/unban.
#
# Protokol yang didukung:
#   - SSH (Linux user), VMess (UUID), VLESS (UUID), Trojan (password),
#     Shadowsocks (password), Socks (user/pass), Hysteria2, Trojan-Go
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
#   - Tahap 1-5 sudah dijalankan
#
# Penggunaan:
#   chmod +x setup-account.sh
#   ./setup-account.sh
#
# Referensi:
#   - https://github.com/XTLS/Xray-core (Core engine Xray proxy)
#   - https://github.com/apernet/hysteria (Hysteria2 protocol engine)
#   - https://github.com/p4gefau1t/trojan-go (Trojan-Go engine)
#   - https://github.com/FN-Rerechan02/Autoscript (AIO VPN script reference)
#
# Log instalasi tersimpan di: /root/syslog.log
# ============================================================================

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# File log
LOG_FILE="/root/syslog.log"

# ============================================================================
# Paths penting dari Tahap sebelumnya
# ============================================================================
XRAY_CERT="/etc/xray/xray.crt"
export XRAY_KEY="/etc/xray/xray.key"
DOMAIN_FILE="/etc/xray/domain"
XRAY_CONFIG="/etc/xray/config.json"
HYSTERIA2_CONFIG="/etc/hysteria2/config.yaml"
TROJAN_GO_CONFIG="/etc/trojan-go/config.json"

# ============================================================================
# Direktori akun (sesuai README — Struktur Direktori)
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
SSH_LOCKED_DIR="/etc/vpnray/ssh-locked"
SSH_BANNED_DIR="/etc/vpnray/ssh-banned"

# ============================================================================
# Paths utility scripts (sesuai README — /usr/local/bin/)
# ============================================================================
XP_SSH_BIN="/usr/local/bin/xp-ssh"
XP_XRAY_BIN="/usr/local/bin/xp-xray"
AUTO_DELETE_BIN="/usr/local/bin/auto-delete-expired"
AUTO_DISCONNECT_BIN="/usr/local/bin/auto-disconnect-duplicate"
LIMIT_IP_SSH_BIN="/usr/local/bin/limit-ip-ssh"
LIMIT_IP_XRAY_BIN="/usr/local/bin/limit-ip-xray"
LIMIT_QUOTA_XRAY_BIN="/usr/local/bin/limit-quota-xray"
LOCK_SSH_BIN="/usr/local/bin/lock-ssh"
LOCK_XRAY_BIN="/usr/local/bin/lock-xray"

# ============================================================================
# Cronjob paths
# ============================================================================
CRON_DELETE_EXPIRED="/etc/cron.d/auto-delete-expired"
CRON_DISCONNECT_DUP="/etc/cron.d/auto-disconnect-duplicate"

# ============================================================================
# Fungsi Utilitas
# ============================================================================

log() {
    local message
    message="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$message" >> "$LOG_FILE"
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    local message
    message="[$(date '+%Y-%m-%d %H:%M:%S')] WARNING: $1"
    echo "$message" >> "$LOG_FILE"
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    local message
    message="[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1"
    echo "$message" >> "$LOG_FILE"
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${CYAN}"
    echo "=============================================="
    echo "  VPN Tunneling AutoScript Installer"
    echo "  Tahap 6: Manajemen Akun & User"
    echo "=============================================="
    echo -e "${NC}"
}

# ============================================================================
# Pengecekan Prasyarat
# ============================================================================

check_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        log_error "Script ini harus dijalankan sebagai root!"
        echo -e "${RED}Gunakan: sudo ./setup-account.sh${NC}"
        exit 1
    fi
    log "Pengecekan root: OK"
}

check_os() {
    if [[ ! -f /etc/os-release ]]; then
        log_error "File /etc/os-release tidak ditemukan. OS tidak didukung."
        exit 1
    fi

    # shellcheck source=/dev/null
    source /etc/os-release

    local supported=false

    case "$ID" in
        ubuntu)
            case "$VERSION_ID" in
                20.04|22.04|24.04)
                    supported=true
                    ;;
            esac
            ;;
        debian)
            case "$VERSION_ID" in
                10|11|12)
                    supported=true
                    ;;
            esac
            ;;
    esac

    if [[ "$supported" != true ]]; then
        log_error "OS tidak didukung: $PRETTY_NAME"
        echo -e "${RED}OS yang didukung:${NC}"
        echo "  - Ubuntu 20.04 LTS (focal)"
        echo "  - Ubuntu 22.04 LTS (jammy)"
        echo "  - Ubuntu 24.04 LTS (noble)"
        echo "  - Debian 10 (buster)"
        echo "  - Debian 11 (bullseye)"
        echo "  - Debian 12 (bookworm)"
        exit 1
    fi

    log "Pengecekan OS: $PRETTY_NAME — OK"
}

check_arch() {
    local arch
    arch=$(uname -m)

    if [[ "$arch" != "x86_64" ]]; then
        log_error "Arsitektur tidak didukung: $arch"
        echo -e "${RED}Script ini hanya mendukung arsitektur amd64 (x86_64).${NC}"
        exit 1
    fi

    log "Pengecekan arsitektur: $arch — OK"
}

check_virt() {
    local virt_type=""

    # Deteksi tipe virtualisasi
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

    # OpenVZ dan LXC tidak didukung
    case "$virt_type" in
        openvz|lxc|lxc-libvirt)
            log_error "Virtualisasi tidak didukung: $virt_type"
            echo -e "${RED}Script ini hanya mendukung KVM / Xen.${NC}"
            echo -e "${RED}OpenVZ dan LXC tidak didukung.${NC}"
            exit 1
            ;;
    esac

    if [[ -z "$virt_type" || "$virt_type" == "none" ]]; then
        virt_type="Bare Metal / Tidak terdeteksi"
    fi

    log "Pengecekan virtualisasi: $virt_type — OK"
}

check_tahap5() {
    local missing=false

    # Cek domain file (Tahap 3)
    if [[ ! -f "$DOMAIN_FILE" ]]; then
        log_error "File domain tidak ditemukan: $DOMAIN_FILE"
        missing=true
    fi

    # Cek SSL certificate (Tahap 3)
    if [[ ! -f "$XRAY_CERT" ]]; then
        log_warn "SSL certificate tidak ditemukan: $XRAY_CERT"
    fi

    # Cek Nginx (Tahap 3)
    if ! command -v nginx &>/dev/null; then
        log_error "Nginx tidak terinstall. Tahap 3 belum dijalankan."
        missing=true
    fi

    # Cek Xray (Tahap 3)
    if ! command -v xray &>/dev/null && [[ ! -f /usr/local/bin/xray ]]; then
        log_error "Xray-core tidak terinstall. Tahap 3 belum dijalankan."
        missing=true
    fi

    # Cek Xray config (Tahap 3)
    if [[ ! -f "$XRAY_CONFIG" ]]; then
        log_warn "Xray config tidak ditemukan: $XRAY_CONFIG"
    fi

    # Cek Dropbear (Tahap 4)
    if ! command -v dropbear &>/dev/null; then
        log_warn "Dropbear tidak terinstall. Tahap 4 mungkin belum dijalankan."
    fi

    # Cek HAProxy (Tahap 4)
    if ! command -v haproxy &>/dev/null; then
        log_warn "HAProxy tidak terinstall. Tahap 4 mungkin belum dijalankan."
    fi

    # Cek Hysteria2 (Tahap 5)
    if [[ ! -f /usr/local/bin/hysteria ]]; then
        log_warn "Hysteria2 tidak terinstall. Tahap 5 mungkin belum dijalankan."
    fi

    # Cek Trojan-Go (Tahap 5)
    if [[ ! -f /usr/local/bin/trojan-go ]]; then
        log_warn "Trojan-Go tidak terinstall. Tahap 5 mungkin belum dijalankan."
    fi

    # Cek OpenVPN (Tahap 5)
    if ! command -v openvpn &>/dev/null; then
        log_warn "OpenVPN tidak terinstall. Tahap 5 mungkin belum dijalankan."
    fi

    if [[ "$missing" == true ]]; then
        log_error "Pastikan Tahap 1-5 sudah dijalankan sebelum melanjutkan."
        exit 1
    fi

    log "Pengecekan Tahap 5: OK"
}

# ============================================================================
# Helper Functions
# ============================================================================

get_domain() {
    local domain=""
    if [[ -f "$DOMAIN_FILE" ]]; then
        domain=$(head -1 "$DOMAIN_FILE" 2>/dev/null | tr -d '[:space:]')
    fi
    echo "$domain"
}

get_public_ip() {
    local ip=""
    ip=$(curl -s --max-time 5 ifconfig.me 2>/dev/null)
    if [[ -z "$ip" ]]; then
        ip=$(curl -s --max-time 5 icanhazip.com 2>/dev/null)
    fi
    if [[ -z "$ip" ]]; then
        ip=$(curl -s --max-time 5 ip.me 2>/dev/null)
    fi
    echo "$ip"
}

generate_uuid() {
    local uuid=""
    if command -v xray &>/dev/null; then
        uuid=$(xray uuid 2>/dev/null)
    fi
    if [[ -z "$uuid" ]] && command -v uuidgen &>/dev/null; then
        uuid=$(uuidgen 2>/dev/null)
    fi
    if [[ -z "$uuid" ]] && [[ -f /proc/sys/kernel/random/uuid ]]; then
        uuid=$(cat /proc/sys/kernel/random/uuid)
    fi
    echo "$uuid"
}

generate_password() {
    local length="${1:-16}"
    tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "$length"
}

get_current_date() {
    date '+%Y-%m-%d'
}

get_expiry_date() {
    local days="${1:-30}"
    date -d "+${days} days" '+%Y-%m-%d'
}

is_expired() {
    local expiry_date="$1"
    local today
    today=$(date '+%Y-%m-%d')
    if [[ "$expiry_date" < "$today" ]]; then
        return 0
    fi
    return 1
}

# ============================================================================
# Setup Direktori Akun
# ============================================================================

setup_account_directories() {
    log "Membuat direktori akun..."

    local dirs=(
        "$ACCOUNT_DIR"
        "$SSH_ACCOUNT_DIR"
        "$VMESS_ACCOUNT_DIR"
        "$VLESS_ACCOUNT_DIR"
        "$TROJAN_ACCOUNT_DIR"
        "$SHADOWSOCKS_ACCOUNT_DIR"
        "$SOCKS_ACCOUNT_DIR"
        "$HYSTERIA2_ACCOUNT_DIR"
        "$TROJAN_GO_ACCOUNT_DIR"
        "$SSH_LOCKED_DIR"
        "$SSH_BANNED_DIR"
    )

    for dir in "${dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            chmod 700 "$dir"
            log "Direktori dibuat: $dir"
        fi
    done

    log "Semua direktori akun berhasil dibuat."
}

# ============================================================================
# SSH Account Management
# ============================================================================

create_ssh_account() {
    local username="$1"
    local password="$2"
    local days="${3:-30}"

    if [[ -z "$username" || -z "$password" ]]; then
        log_error "Usage: create_ssh_account <username> <password> [days]"
        return 1
    fi

    if id "$username" &>/dev/null; then
        log_warn "User SSH sudah ada: $username"
        return 1
    fi

    local expiry
    expiry=$(get_expiry_date "$days")

    useradd -m -s /bin/false -e "$expiry" "$username" >> "$LOG_FILE" 2>&1
    echo "$username:$password" | chpasswd >> "$LOG_FILE" 2>&1

    # Simpan data akun
    cat > "$SSH_ACCOUNT_DIR/${username}.json" <<ACCOUNT_JSON
{
    "username": "$username",
    "password": "$password",
    "created": "$(get_current_date)",
    "expiry": "$expiry",
    "ip_limit": 2,
    "status": "active",
    "protocol": "ssh"
}
ACCOUNT_JSON
    chmod 600 "$SSH_ACCOUNT_DIR/${username}.json"

    log "Akun SSH dibuat: $username (expired: $expiry)"
}

delete_ssh_account() {
    local username="$1"

    if [[ -z "$username" ]]; then
        log_error "Usage: delete_ssh_account <username>"
        return 1
    fi

    # Kill semua session user
    pkill -u "$username" 2>/dev/null || true

    userdel -r "$username" >> "$LOG_FILE" 2>&1 || true
    rm -f "$SSH_ACCOUNT_DIR/${username}.json"
    rm -f "$SSH_LOCKED_DIR/${username}"
    rm -f "$SSH_BANNED_DIR/${username}"

    log "Akun SSH dihapus: $username"
}

extend_ssh_account() {
    local username="$1"
    local days="${2:-30}"

    if [[ -z "$username" ]]; then
        log_error "Usage: extend_ssh_account <username> [days]"
        return 1
    fi

    local new_expiry
    new_expiry=$(get_expiry_date "$days")

    chage -E "$new_expiry" "$username" >> "$LOG_FILE" 2>&1

    # Update account file
    if [[ -f "$SSH_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file
        tmp_file=$(mktemp)
        jq --arg exp "$new_expiry" '.expiry = $exp' "$SSH_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$SSH_ACCOUNT_DIR/${username}.json"
        chmod 600 "$SSH_ACCOUNT_DIR/${username}.json"
    fi

    log "Akun SSH diperpanjang: $username (expired: $new_expiry)"
}

lock_ssh_account() {
    local username="$1"

    if [[ -z "$username" ]]; then
        log_error "Usage: lock_ssh_account <username>"
        return 1
    fi

    passwd -l "$username" >> "$LOG_FILE" 2>&1
    touch "$SSH_LOCKED_DIR/${username}"

    # Update status in account file
    if [[ -f "$SSH_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file
        tmp_file=$(mktemp)
        jq '.status = "locked"' "$SSH_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$SSH_ACCOUNT_DIR/${username}.json"
        chmod 600 "$SSH_ACCOUNT_DIR/${username}.json"
    fi

    log "Akun SSH dikunci: $username"
}

unlock_ssh_account() {
    local username="$1"

    if [[ -z "$username" ]]; then
        log_error "Usage: unlock_ssh_account <username>"
        return 1
    fi

    passwd -u "$username" >> "$LOG_FILE" 2>&1
    rm -f "$SSH_LOCKED_DIR/${username}"

    if [[ -f "$SSH_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file
        tmp_file=$(mktemp)
        jq '.status = "active"' "$SSH_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$SSH_ACCOUNT_DIR/${username}.json"
        chmod 600 "$SSH_ACCOUNT_DIR/${username}.json"
    fi

    log "Akun SSH dibuka: $username"
}

ban_ssh_account() {
    local username="$1"

    if [[ -z "$username" ]]; then
        log_error "Usage: ban_ssh_account <username>"
        return 1
    fi

    # Kill sessions & lock
    pkill -u "$username" 2>/dev/null || true
    passwd -l "$username" >> "$LOG_FILE" 2>&1
    touch "$SSH_BANNED_DIR/${username}"

    if [[ -f "$SSH_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file
        tmp_file=$(mktemp)
        jq '.status = "banned"' "$SSH_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$SSH_ACCOUNT_DIR/${username}.json"
        chmod 600 "$SSH_ACCOUNT_DIR/${username}.json"
    fi

    log "Akun SSH di-ban: $username"
}

unban_ssh_account() {
    local username="$1"

    if [[ -z "$username" ]]; then
        log_error "Usage: unban_ssh_account <username>"
        return 1
    fi

    passwd -u "$username" >> "$LOG_FILE" 2>&1
    rm -f "$SSH_BANNED_DIR/${username}"

    if [[ -f "$SSH_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file
        tmp_file=$(mktemp)
        jq '.status = "active"' "$SSH_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$SSH_ACCOUNT_DIR/${username}.json"
        chmod 600 "$SSH_ACCOUNT_DIR/${username}.json"
    fi

    log "Akun SSH di-unban: $username"
}

check_ssh_login() {
    local username="$1"

    if [[ -z "$username" ]]; then
        # Tampilkan semua login aktif
        who 2>/dev/null
    else
        who 2>/dev/null | grep "$username"
    fi
}

limit_ip_ssh() {
    local username="$1"
    local max_ip="${2:-2}"

    if [[ -z "$username" ]]; then
        log_error "Usage: limit_ip_ssh <username> [max_ip]"
        return 1
    fi

    if [[ -f "$SSH_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file
        tmp_file=$(mktemp)
        jq --argjson limit "$max_ip" '.ip_limit = $limit' "$SSH_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$SSH_ACCOUNT_DIR/${username}.json"
        chmod 600 "$SSH_ACCOUNT_DIR/${username}.json"
    fi

    log "Limit IP SSH diset: $username = $max_ip"
}

list_ssh_accounts() {
    log "Daftar akun SSH:"
    if [[ -d "$SSH_ACCOUNT_DIR" ]]; then
        for f in "$SSH_ACCOUNT_DIR"/*.json; do
            [[ -f "$f" ]] || continue
            if command -v jq &>/dev/null; then
                jq -r '"\(.username)\t\(.expiry)\t\(.status)"' "$f" 2>/dev/null
            else
                basename "$f" .json
            fi
        done
    fi
}

# ============================================================================
# Xray Account Management — VMess
# ============================================================================

create_vmess_account() {
    local username="$1"
    local days="${2:-30}"

    if [[ -z "$username" ]]; then
        log_error "Usage: create_vmess_account <username> [days]"
        return 1
    fi

    local uuid
    uuid=$(generate_uuid)
    local expiry
    expiry=$(get_expiry_date "$days")
    local domain
    domain=$(get_domain)

    # Tambah ke Xray config
    if [[ -f "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
        local tmp_file
        tmp_file=$(mktemp)
        jq --arg id "$uuid" --arg email "$username" \
           '(.inbounds[] | select(.tag == "vmess-ws-tls") | .settings.clients) += [{"id": $id, "alterId": 0, "email": $email}]' \
           "$XRAY_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$XRAY_CONFIG"
    fi

    # Simpan data akun
    cat > "$VMESS_ACCOUNT_DIR/${username}.json" <<ACCOUNT_JSON
{
    "username": "$username",
    "uuid": "$uuid",
    "created": "$(get_current_date)",
    "expiry": "$expiry",
    "ip_limit": 2,
    "quota_limit": 0,
    "quota_used": 0,
    "status": "active",
    "protocol": "vmess",
    "domain": "$domain"
}
ACCOUNT_JSON
    chmod 600 "$VMESS_ACCOUNT_DIR/${username}.json"

    log "Akun VMess dibuat: $username (UUID: $uuid, expired: $expiry)"
}

delete_vmess_account() {
    local username="$1"

    if [[ -z "$username" ]]; then
        log_error "Usage: delete_vmess_account <username>"
        return 1
    fi

    # Hapus dari Xray config
    if [[ -f "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
        local tmp_file
        tmp_file=$(mktemp)
        jq --arg email "$username" \
           '(.inbounds[].settings.clients) |= map(select(.email != $email))' \
           "$XRAY_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$XRAY_CONFIG"
    fi

    rm -f "$VMESS_ACCOUNT_DIR/${username}.json"
    log "Akun VMess dihapus: $username"
}

extend_vmess_account() {
    local username="$1"
    local days="${2:-30}"

    if [[ -z "$username" ]]; then
        log_error "Usage: extend_vmess_account <username> [days]"
        return 1
    fi

    local new_expiry
    new_expiry=$(get_expiry_date "$days")

    if [[ -f "$VMESS_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file
        tmp_file=$(mktemp)
        jq --arg exp "$new_expiry" '.expiry = $exp' "$VMESS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$VMESS_ACCOUNT_DIR/${username}.json"
        chmod 600 "$VMESS_ACCOUNT_DIR/${username}.json"
    fi

    log "Akun VMess diperpanjang: $username (expired: $new_expiry)"
}

lock_vmess_account() {
    local username="$1"

    if [[ -z "$username" ]]; then
        log_error "Usage: lock_vmess_account <username>"
        return 1
    fi

    # Hapus dari Xray config (lock = remove from active)
    if [[ -f "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
        local tmp_file
        tmp_file=$(mktemp)
        jq --arg email "$username" \
           '(.inbounds[].settings.clients) |= map(select(.email != $email))' \
           "$XRAY_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$XRAY_CONFIG"
    fi

    if [[ -f "$VMESS_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file
        tmp_file=$(mktemp)
        jq '.status = "locked"' "$VMESS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$VMESS_ACCOUNT_DIR/${username}.json"
        chmod 600 "$VMESS_ACCOUNT_DIR/${username}.json"
    fi

    log "Akun VMess dikunci: $username"
}

unlock_vmess_account() {
    local username="$1"

    if [[ -z "$username" ]]; then
        log_error "Usage: unlock_vmess_account <username>"
        return 1
    fi

    # Re-add ke Xray config
    if [[ -f "$VMESS_ACCOUNT_DIR/${username}.json" && -f "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
        local uuid
        uuid=$(jq -r '.uuid' "$VMESS_ACCOUNT_DIR/${username}.json" 2>/dev/null)

        if [[ -n "$uuid" ]]; then
            local tmp_file
            tmp_file=$(mktemp)
            jq --arg id "$uuid" --arg email "$username" \
               '(.inbounds[] | select(.tag == "vmess-ws-tls") | .settings.clients) += [{"id": $id, "alterId": 0, "email": $email}]' \
               "$XRAY_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$XRAY_CONFIG"
        fi

        tmp_file=$(mktemp)
        jq '.status = "active"' "$VMESS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$VMESS_ACCOUNT_DIR/${username}.json"
        chmod 600 "$VMESS_ACCOUNT_DIR/${username}.json"
    fi

    log "Akun VMess dibuka: $username"
}

ban_vmess_account() {
    local username="$1"

    if [[ -z "$username" ]]; then
        log_error "Usage: ban_vmess_account <username>"
        return 1
    fi

    # Hapus dari config dan set status banned
    if [[ -f "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
        local tmp_file
        tmp_file=$(mktemp)
        jq --arg email "$username" \
           '(.inbounds[].settings.clients) |= map(select(.email != $email))' \
           "$XRAY_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$XRAY_CONFIG"
    fi

    if [[ -f "$VMESS_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file
        tmp_file=$(mktemp)
        jq '.status = "banned"' "$VMESS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$VMESS_ACCOUNT_DIR/${username}.json"
        chmod 600 "$VMESS_ACCOUNT_DIR/${username}.json"
    fi

    log "Akun VMess di-ban: $username"
}

unban_vmess_account() {
    local username="$1"

    if [[ -z "$username" ]]; then
        log_error "Usage: unban_vmess_account <username>"
        return 1
    fi

    unlock_vmess_account "$username"
    log "Akun VMess di-unban: $username"
}

limit_ip_vmess() {
    local username="$1"
    local max_ip="${2:-2}"

    if [[ -z "$username" ]]; then
        log_error "Usage: limit_ip_vmess <username> [max_ip]"
        return 1
    fi

    if [[ -f "$VMESS_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file
        tmp_file=$(mktemp)
        jq --argjson limit "$max_ip" '.ip_limit = $limit' "$VMESS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$VMESS_ACCOUNT_DIR/${username}.json"
        chmod 600 "$VMESS_ACCOUNT_DIR/${username}.json"
    fi

    log "Limit IP VMess diset: $username = $max_ip"
}

limit_quota_vmess() {
    local username="$1"
    local quota_gb="${2:-0}"

    if [[ -z "$username" ]]; then
        log_error "Usage: limit_quota_vmess <username> [quota_gb]"
        return 1
    fi

    local quota_bytes=0
    if [[ "$quota_gb" -gt 0 ]]; then
        quota_bytes=$((quota_gb * 1073741824))
    fi

    if [[ -f "$VMESS_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file
        tmp_file=$(mktemp)
        jq --argjson limit "$quota_bytes" '.quota_limit = $limit' "$VMESS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$VMESS_ACCOUNT_DIR/${username}.json"
        chmod 600 "$VMESS_ACCOUNT_DIR/${username}.json"
    fi

    log "Limit quota VMess diset: $username = ${quota_gb}GB"
}

list_vmess_accounts() {
    log "Daftar akun VMess:"
    if [[ -d "$VMESS_ACCOUNT_DIR" ]]; then
        for f in "$VMESS_ACCOUNT_DIR"/*.json; do
            [[ -f "$f" ]] || continue
            if command -v jq &>/dev/null; then
                jq -r '"\(.username)\t\(.uuid)\t\(.expiry)\t\(.status)"' "$f" 2>/dev/null
            else
                basename "$f" .json
            fi
        done
    fi
}

# ============================================================================
# Xray Account Management — VLESS
# ============================================================================

create_vless_account() {
    local username="$1"
    local days="${2:-30}"

    if [[ -z "$username" ]]; then
        log_error "Usage: create_vless_account <username> [days]"
        return 1
    fi

    local uuid
    uuid=$(generate_uuid)
    local expiry
    expiry=$(get_expiry_date "$days")
    local domain
    domain=$(get_domain)

    if [[ -f "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
        local tmp_file
        tmp_file=$(mktemp)
        jq --arg id "$uuid" --arg email "$username" \
           '(.inbounds[] | select(.tag == "vless-ws-tls") | .settings.clients) += [{"id": $id, "email": $email}]' \
           "$XRAY_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$XRAY_CONFIG"
    fi

    cat > "$VLESS_ACCOUNT_DIR/${username}.json" <<ACCOUNT_JSON
{
    "username": "$username",
    "uuid": "$uuid",
    "created": "$(get_current_date)",
    "expiry": "$expiry",
    "ip_limit": 2,
    "quota_limit": 0,
    "quota_used": 0,
    "status": "active",
    "protocol": "vless",
    "domain": "$domain"
}
ACCOUNT_JSON
    chmod 600 "$VLESS_ACCOUNT_DIR/${username}.json"

    log "Akun VLESS dibuat: $username (UUID: $uuid, expired: $expiry)"
}

delete_vless_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: delete_vless_account <username>"; return 1; fi

    if [[ -f "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
        local tmp_file
        tmp_file=$(mktemp)
        jq --arg email "$username" '(.inbounds[].settings.clients) |= map(select(.email != $email))' \
           "$XRAY_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$XRAY_CONFIG"
    fi
    rm -f "$VLESS_ACCOUNT_DIR/${username}.json"
    log "Akun VLESS dihapus: $username"
}

extend_vless_account() {
    local username="$1"; local days="${2:-30}"
    if [[ -z "$username" ]]; then log_error "Usage: extend_vless_account <username> [days]"; return 1; fi
    local new_expiry; new_expiry=$(get_expiry_date "$days")
    if [[ -f "$VLESS_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --arg exp "$new_expiry" '.expiry = $exp' "$VLESS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$VLESS_ACCOUNT_DIR/${username}.json"; chmod 600 "$VLESS_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun VLESS diperpanjang: $username (expired: $new_expiry)"
}

lock_vless_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: lock_vless_account <username>"; return 1; fi
    if [[ -f "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --arg email "$username" '(.inbounds[].settings.clients) |= map(select(.email != $email))' \
           "$XRAY_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$XRAY_CONFIG"
    fi
    if [[ -f "$VLESS_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq '.status = "locked"' "$VLESS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$VLESS_ACCOUNT_DIR/${username}.json"; chmod 600 "$VLESS_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun VLESS dikunci: $username"
}

unlock_vless_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: unlock_vless_account <username>"; return 1; fi
    if [[ -f "$VLESS_ACCOUNT_DIR/${username}.json" && -f "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
        local uuid; uuid=$(jq -r '.uuid' "$VLESS_ACCOUNT_DIR/${username}.json" 2>/dev/null)
        if [[ -n "$uuid" ]]; then
            local tmp_file; tmp_file=$(mktemp)
            jq --arg id "$uuid" --arg email "$username" \
               '(.inbounds[] | select(.tag == "vless-ws-tls") | .settings.clients) += [{"id": $id, "email": $email}]' \
               "$XRAY_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$XRAY_CONFIG"
        fi
        local tmp_file; tmp_file=$(mktemp)
        jq '.status = "active"' "$VLESS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$VLESS_ACCOUNT_DIR/${username}.json"; chmod 600 "$VLESS_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun VLESS dibuka: $username"
}

ban_vless_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: ban_vless_account <username>"; return 1; fi
    lock_vless_account "$username"
    if [[ -f "$VLESS_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq '.status = "banned"' "$VLESS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$VLESS_ACCOUNT_DIR/${username}.json"; chmod 600 "$VLESS_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun VLESS di-ban: $username"
}

unban_vless_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: unban_vless_account <username>"; return 1; fi
    unlock_vless_account "$username"
    log "Akun VLESS di-unban: $username"
}

limit_ip_vless() {
    local username="$1"; local max_ip="${2:-2}"
    if [[ -z "$username" ]]; then log_error "Usage: limit_ip_vless <username> [max_ip]"; return 1; fi
    if [[ -f "$VLESS_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --argjson limit "$max_ip" '.ip_limit = $limit' "$VLESS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$VLESS_ACCOUNT_DIR/${username}.json"; chmod 600 "$VLESS_ACCOUNT_DIR/${username}.json"
    fi
    log "Limit IP VLESS diset: $username = $max_ip"
}

limit_quota_vless() {
    local username="$1"; local quota_gb="${2:-0}"
    if [[ -z "$username" ]]; then log_error "Usage: limit_quota_vless <username> [quota_gb]"; return 1; fi
    local quota_bytes=0
    if [[ "$quota_gb" -gt 0 ]]; then quota_bytes=$((quota_gb * 1073741824)); fi
    if [[ -f "$VLESS_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --argjson limit "$quota_bytes" '.quota_limit = $limit' "$VLESS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$VLESS_ACCOUNT_DIR/${username}.json"; chmod 600 "$VLESS_ACCOUNT_DIR/${username}.json"
    fi
    log "Limit quota VLESS diset: $username = ${quota_gb}GB"
}

list_vless_accounts() {
    log "Daftar akun VLESS:"
    if [[ -d "$VLESS_ACCOUNT_DIR" ]]; then
        for f in "$VLESS_ACCOUNT_DIR"/*.json; do
            [[ -f "$f" ]] || continue
            if command -v jq &>/dev/null; then
                jq -r '"\(.username)\t\(.uuid)\t\(.expiry)\t\(.status)"' "$f" 2>/dev/null
            else
                basename "$f" .json
            fi
        done
    fi
}

# ============================================================================
# Xray Account Management — Trojan
# ============================================================================

create_trojan_account() {
    local username="$1"
    local days="${2:-30}"

    if [[ -z "$username" ]]; then log_error "Usage: create_trojan_account <username> [days]"; return 1; fi

    local password
    password=$(generate_password 16)
    local expiry; expiry=$(get_expiry_date "$days")
    local domain; domain=$(get_domain)

    if [[ -f "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --arg pw "$password" --arg email "$username" \
           '(.inbounds[] | select(.tag == "trojan-ws-tls") | .settings.clients) += [{"password": $pw, "email": $email}]' \
           "$XRAY_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$XRAY_CONFIG"
    fi

    cat > "$TROJAN_ACCOUNT_DIR/${username}.json" <<ACCOUNT_JSON
{
    "username": "$username",
    "password": "$password",
    "created": "$(get_current_date)",
    "expiry": "$expiry",
    "ip_limit": 2,
    "quota_limit": 0,
    "quota_used": 0,
    "status": "active",
    "protocol": "trojan",
    "domain": "$domain"
}
ACCOUNT_JSON
    chmod 600 "$TROJAN_ACCOUNT_DIR/${username}.json"
    log "Akun Trojan dibuat: $username (expired: $expiry)"
}

delete_trojan_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: delete_trojan_account <username>"; return 1; fi
    if [[ -f "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --arg email "$username" '(.inbounds[].settings.clients) |= map(select(.email != $email))' \
           "$XRAY_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$XRAY_CONFIG"
    fi
    rm -f "$TROJAN_ACCOUNT_DIR/${username}.json"
    log "Akun Trojan dihapus: $username"
}

extend_trojan_account() {
    local username="$1"; local days="${2:-30}"
    if [[ -z "$username" ]]; then log_error "Usage: extend_trojan_account <username> [days]"; return 1; fi
    local new_expiry; new_expiry=$(get_expiry_date "$days")
    if [[ -f "$TROJAN_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --arg exp "$new_expiry" '.expiry = $exp' "$TROJAN_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$TROJAN_ACCOUNT_DIR/${username}.json"; chmod 600 "$TROJAN_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun Trojan diperpanjang: $username (expired: $new_expiry)"
}

lock_trojan_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: lock_trojan_account <username>"; return 1; fi
    if [[ -f "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --arg email "$username" '(.inbounds[].settings.clients) |= map(select(.email != $email))' \
           "$XRAY_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$XRAY_CONFIG"
    fi
    if [[ -f "$TROJAN_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq '.status = "locked"' "$TROJAN_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$TROJAN_ACCOUNT_DIR/${username}.json"; chmod 600 "$TROJAN_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun Trojan dikunci: $username"
}

unlock_trojan_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: unlock_trojan_account <username>"; return 1; fi
    if [[ -f "$TROJAN_ACCOUNT_DIR/${username}.json" && -f "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
        local pw; pw=$(jq -r '.password' "$TROJAN_ACCOUNT_DIR/${username}.json" 2>/dev/null)
        if [[ -n "$pw" ]]; then
            local tmp_file; tmp_file=$(mktemp)
            jq --arg pw "$pw" --arg email "$username" \
               '(.inbounds[] | select(.tag == "trojan-ws-tls") | .settings.clients) += [{"password": $pw, "email": $email}]' \
               "$XRAY_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$XRAY_CONFIG"
        fi
        local tmp_file; tmp_file=$(mktemp)
        jq '.status = "active"' "$TROJAN_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$TROJAN_ACCOUNT_DIR/${username}.json"; chmod 600 "$TROJAN_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun Trojan dibuka: $username"
}

ban_trojan_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: ban_trojan_account <username>"; return 1; fi
    lock_trojan_account "$username"
    if [[ -f "$TROJAN_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq '.status = "banned"' "$TROJAN_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$TROJAN_ACCOUNT_DIR/${username}.json"; chmod 600 "$TROJAN_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun Trojan di-ban: $username"
}

unban_trojan_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: unban_trojan_account <username>"; return 1; fi
    unlock_trojan_account "$username"
    log "Akun Trojan di-unban: $username"
}

limit_ip_trojan() {
    local username="$1"; local max_ip="${2:-2}"
    if [[ -z "$username" ]]; then log_error "Usage: limit_ip_trojan <username> [max_ip]"; return 1; fi
    if [[ -f "$TROJAN_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --argjson limit "$max_ip" '.ip_limit = $limit' "$TROJAN_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$TROJAN_ACCOUNT_DIR/${username}.json"; chmod 600 "$TROJAN_ACCOUNT_DIR/${username}.json"
    fi
    log "Limit IP Trojan diset: $username = $max_ip"
}

limit_quota_trojan() {
    local username="$1"; local quota_gb="${2:-0}"
    if [[ -z "$username" ]]; then log_error "Usage: limit_quota_trojan <username> [quota_gb]"; return 1; fi
    local quota_bytes=0
    if [[ "$quota_gb" -gt 0 ]]; then quota_bytes=$((quota_gb * 1073741824)); fi
    if [[ -f "$TROJAN_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --argjson limit "$quota_bytes" '.quota_limit = $limit' "$TROJAN_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$TROJAN_ACCOUNT_DIR/${username}.json"; chmod 600 "$TROJAN_ACCOUNT_DIR/${username}.json"
    fi
    log "Limit quota Trojan diset: $username = ${quota_gb}GB"
}

list_trojan_accounts() {
    log "Daftar akun Trojan:"
    if [[ -d "$TROJAN_ACCOUNT_DIR" ]]; then
        for f in "$TROJAN_ACCOUNT_DIR"/*.json; do
            [[ -f "$f" ]] || continue
            if command -v jq &>/dev/null; then
                jq -r '"\(.username)\t\(.expiry)\t\(.status)"' "$f" 2>/dev/null
            else basename "$f" .json; fi
        done
    fi
}

# ============================================================================
# Xray Account Management — Shadowsocks
# ============================================================================

create_shadowsocks_account() {
    local username="$1"
    local days="${2:-30}"

    if [[ -z "$username" ]]; then log_error "Usage: create_shadowsocks_account <username> [days]"; return 1; fi

    local password; password=$(generate_password 16)
    local expiry; expiry=$(get_expiry_date "$days")
    local domain; domain=$(get_domain)

    if [[ -f "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --arg pw "$password" --arg email "$username" \
           '(.inbounds[] | select(.tag == "shadowsocks-ws-tls") | .settings.clients) += [{"password": $pw, "email": $email, "method": "chacha20-ietf-poly1305"}]' \
           "$XRAY_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$XRAY_CONFIG"
    fi

    cat > "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json" <<ACCOUNT_JSON
{
    "username": "$username",
    "password": "$password",
    "method": "chacha20-ietf-poly1305",
    "created": "$(get_current_date)",
    "expiry": "$expiry",
    "ip_limit": 2,
    "quota_limit": 0,
    "quota_used": 0,
    "status": "active",
    "protocol": "shadowsocks",
    "domain": "$domain"
}
ACCOUNT_JSON
    chmod 600 "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json"
    log "Akun Shadowsocks dibuat: $username (expired: $expiry)"
}

delete_shadowsocks_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: delete_shadowsocks_account <username>"; return 1; fi
    if [[ -f "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --arg email "$username" '(.inbounds[].settings.clients) |= map(select(.email != $email))' \
           "$XRAY_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$XRAY_CONFIG"
    fi
    rm -f "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json"
    log "Akun Shadowsocks dihapus: $username"
}

extend_shadowsocks_account() {
    local username="$1"; local days="${2:-30}"
    if [[ -z "$username" ]]; then log_error "Usage: extend_shadowsocks_account <username> [days]"; return 1; fi
    local new_expiry; new_expiry=$(get_expiry_date "$days")
    if [[ -f "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --arg exp "$new_expiry" '.expiry = $exp' "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json"; chmod 600 "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun Shadowsocks diperpanjang: $username (expired: $new_expiry)"
}

lock_shadowsocks_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: lock_shadowsocks_account <username>"; return 1; fi
    if [[ -f "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --arg email "$username" '(.inbounds[].settings.clients) |= map(select(.email != $email))' \
           "$XRAY_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$XRAY_CONFIG"
    fi
    if [[ -f "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq '.status = "locked"' "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json"; chmod 600 "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun Shadowsocks dikunci: $username"
}

unlock_shadowsocks_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: unlock_shadowsocks_account <username>"; return 1; fi
    if [[ -f "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json" && -f "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
        local pw; pw=$(jq -r '.password' "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json" 2>/dev/null)
        if [[ -n "$pw" ]]; then
            local tmp_file; tmp_file=$(mktemp)
            jq --arg pw "$pw" --arg email "$username" \
               '(.inbounds[] | select(.tag == "shadowsocks-ws-tls") | .settings.clients) += [{"password": $pw, "email": $email, "method": "chacha20-ietf-poly1305"}]' \
               "$XRAY_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$XRAY_CONFIG"
        fi
        local tmp_file; tmp_file=$(mktemp)
        jq '.status = "active"' "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json"; chmod 600 "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun Shadowsocks dibuka: $username"
}

ban_shadowsocks_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: ban_shadowsocks_account <username>"; return 1; fi
    lock_shadowsocks_account "$username"
    if [[ -f "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq '.status = "banned"' "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json"; chmod 600 "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun Shadowsocks di-ban: $username"
}

unban_shadowsocks_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: unban_shadowsocks_account <username>"; return 1; fi
    unlock_shadowsocks_account "$username"; log "Akun Shadowsocks di-unban: $username"
}

limit_ip_shadowsocks() {
    local username="$1"; local max_ip="${2:-2}"
    if [[ -z "$username" ]]; then log_error "Usage: limit_ip_shadowsocks <username> [max_ip]"; return 1; fi
    if [[ -f "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --argjson limit "$max_ip" '.ip_limit = $limit' "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json"; chmod 600 "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json"
    fi
    log "Limit IP Shadowsocks diset: $username = $max_ip"
}

limit_quota_shadowsocks() {
    local username="$1"; local quota_gb="${2:-0}"
    if [[ -z "$username" ]]; then log_error "Usage: limit_quota_shadowsocks <username> [quota_gb]"; return 1; fi
    local quota_bytes=0; if [[ "$quota_gb" -gt 0 ]]; then quota_bytes=$((quota_gb * 1073741824)); fi
    if [[ -f "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --argjson limit "$quota_bytes" '.quota_limit = $limit' "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json"; chmod 600 "$SHADOWSOCKS_ACCOUNT_DIR/${username}.json"
    fi
    log "Limit quota Shadowsocks diset: $username = ${quota_gb}GB"
}

list_shadowsocks_accounts() {
    log "Daftar akun Shadowsocks:"
    if [[ -d "$SHADOWSOCKS_ACCOUNT_DIR" ]]; then
        for f in "$SHADOWSOCKS_ACCOUNT_DIR"/*.json; do
            [[ -f "$f" ]] || continue
            if command -v jq &>/dev/null; then jq -r '"\(.username)\t\(.expiry)\t\(.status)"' "$f" 2>/dev/null
            else basename "$f" .json; fi
        done
    fi
}

# ============================================================================
# Xray Account Management — Socks
# ============================================================================

create_socks_account() {
    local username="$1"
    local days="${2:-30}"

    if [[ -z "$username" ]]; then log_error "Usage: create_socks_account <username> [days]"; return 1; fi

    local password; password=$(generate_password 16)
    local expiry; expiry=$(get_expiry_date "$days")
    local domain; domain=$(get_domain)

    if [[ -f "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --arg user "$username" --arg pw "$password" --arg email "$username" \
           '(.inbounds[] | select(.tag == "socks-ws-tls") | .settings.accounts) += [{"user": $user, "pass": $pw}]' \
           "$XRAY_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$XRAY_CONFIG"
    fi

    cat > "$SOCKS_ACCOUNT_DIR/${username}.json" <<ACCOUNT_JSON
{
    "username": "$username",
    "password": "$password",
    "created": "$(get_current_date)",
    "expiry": "$expiry",
    "ip_limit": 2,
    "quota_limit": 0,
    "quota_used": 0,
    "status": "active",
    "protocol": "socks",
    "domain": "$domain"
}
ACCOUNT_JSON
    chmod 600 "$SOCKS_ACCOUNT_DIR/${username}.json"
    log "Akun Socks dibuat: $username (expired: $expiry)"
}

delete_socks_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: delete_socks_account <username>"; return 1; fi
    if [[ -f "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --arg user "$username" '(.inbounds[].settings.accounts) |= map(select(.user != $user))' \
           "$XRAY_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$XRAY_CONFIG"
    fi
    rm -f "$SOCKS_ACCOUNT_DIR/${username}.json"
    log "Akun Socks dihapus: $username"
}

extend_socks_account() {
    local username="$1"; local days="${2:-30}"
    if [[ -z "$username" ]]; then log_error "Usage: extend_socks_account <username> [days]"; return 1; fi
    local new_expiry; new_expiry=$(get_expiry_date "$days")
    if [[ -f "$SOCKS_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --arg exp "$new_expiry" '.expiry = $exp' "$SOCKS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$SOCKS_ACCOUNT_DIR/${username}.json"; chmod 600 "$SOCKS_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun Socks diperpanjang: $username (expired: $new_expiry)"
}

lock_socks_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: lock_socks_account <username>"; return 1; fi
    if [[ -f "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --arg user "$username" '(.inbounds[].settings.accounts) |= map(select(.user != $user))' \
           "$XRAY_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$XRAY_CONFIG"
    fi
    if [[ -f "$SOCKS_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq '.status = "locked"' "$SOCKS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$SOCKS_ACCOUNT_DIR/${username}.json"; chmod 600 "$SOCKS_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun Socks dikunci: $username"
}

unlock_socks_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: unlock_socks_account <username>"; return 1; fi
    if [[ -f "$SOCKS_ACCOUNT_DIR/${username}.json" && -f "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
        local pw; pw=$(jq -r '.password' "$SOCKS_ACCOUNT_DIR/${username}.json" 2>/dev/null)
        if [[ -n "$pw" ]]; then
            local tmp_file; tmp_file=$(mktemp)
            jq --arg user "$username" --arg pw "$pw" \
               '(.inbounds[] | select(.tag == "socks-ws-tls") | .settings.accounts) += [{"user": $user, "pass": $pw}]' \
               "$XRAY_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$XRAY_CONFIG"
        fi
        local tmp_file; tmp_file=$(mktemp)
        jq '.status = "active"' "$SOCKS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$SOCKS_ACCOUNT_DIR/${username}.json"; chmod 600 "$SOCKS_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun Socks dibuka: $username"
}

ban_socks_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: ban_socks_account <username>"; return 1; fi
    lock_socks_account "$username"
    if [[ -f "$SOCKS_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq '.status = "banned"' "$SOCKS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$SOCKS_ACCOUNT_DIR/${username}.json"; chmod 600 "$SOCKS_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun Socks di-ban: $username"
}

unban_socks_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: unban_socks_account <username>"; return 1; fi
    unlock_socks_account "$username"; log "Akun Socks di-unban: $username"
}

limit_ip_socks() {
    local username="$1"; local max_ip="${2:-2}"
    if [[ -z "$username" ]]; then log_error "Usage: limit_ip_socks <username> [max_ip]"; return 1; fi
    if [[ -f "$SOCKS_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --argjson limit "$max_ip" '.ip_limit = $limit' "$SOCKS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$SOCKS_ACCOUNT_DIR/${username}.json"; chmod 600 "$SOCKS_ACCOUNT_DIR/${username}.json"
    fi
    log "Limit IP Socks diset: $username = $max_ip"
}

limit_quota_socks() {
    local username="$1"; local quota_gb="${2:-0}"
    if [[ -z "$username" ]]; then log_error "Usage: limit_quota_socks <username> [quota_gb]"; return 1; fi
    local quota_bytes=0; if [[ "$quota_gb" -gt 0 ]]; then quota_bytes=$((quota_gb * 1073741824)); fi
    if [[ -f "$SOCKS_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --argjson limit "$quota_bytes" '.quota_limit = $limit' "$SOCKS_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$SOCKS_ACCOUNT_DIR/${username}.json"; chmod 600 "$SOCKS_ACCOUNT_DIR/${username}.json"
    fi
    log "Limit quota Socks diset: $username = ${quota_gb}GB"
}

list_socks_accounts() {
    log "Daftar akun Socks:"
    if [[ -d "$SOCKS_ACCOUNT_DIR" ]]; then
        for f in "$SOCKS_ACCOUNT_DIR"/*.json; do [[ -f "$f" ]] || continue
            if command -v jq &>/dev/null; then jq -r '"\(.username)\t\(.expiry)\t\(.status)"' "$f" 2>/dev/null
            else basename "$f" .json; fi
        done
    fi
}

# ============================================================================
# Hysteria2 Account Management
# ============================================================================

create_hysteria2_account() {
    local username="$1"
    local days="${2:-30}"

    if [[ -z "$username" ]]; then log_error "Usage: create_hysteria2_account <username> [days]"; return 1; fi

    local password; password=$(generate_password 16)
    local expiry; expiry=$(get_expiry_date "$days")
    local domain; domain=$(get_domain)

    # Tambah ke Hysteria2 config (YAML password list)
    if [[ -f "$HYSTERIA2_CONFIG" ]]; then
        if ! grep -q "^  ${username}:" "$HYSTERIA2_CONFIG" 2>/dev/null; then
            sed -i "/^auth:/a\\  ${username}: ${password}" "$HYSTERIA2_CONFIG" 2>/dev/null || true
        fi
    fi

    cat > "$HYSTERIA2_ACCOUNT_DIR/${username}.json" <<ACCOUNT_JSON
{
    "username": "$username",
    "password": "$password",
    "created": "$(get_current_date)",
    "expiry": "$expiry",
    "ip_limit": 2,
    "quota_limit": 0,
    "quota_used": 0,
    "status": "active",
    "protocol": "hysteria2",
    "domain": "$domain"
}
ACCOUNT_JSON
    chmod 600 "$HYSTERIA2_ACCOUNT_DIR/${username}.json"
    log "Akun Hysteria2 dibuat: $username (expired: $expiry)"
}

delete_hysteria2_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: delete_hysteria2_account <username>"; return 1; fi
    if [[ -f "$HYSTERIA2_CONFIG" ]]; then
        sed -i "/^  ${username}:/d" "$HYSTERIA2_CONFIG" 2>/dev/null || true
    fi
    rm -f "$HYSTERIA2_ACCOUNT_DIR/${username}.json"
    log "Akun Hysteria2 dihapus: $username"
}

extend_hysteria2_account() {
    local username="$1"; local days="${2:-30}"
    if [[ -z "$username" ]]; then log_error "Usage: extend_hysteria2_account <username> [days]"; return 1; fi
    local new_expiry; new_expiry=$(get_expiry_date "$days")
    if [[ -f "$HYSTERIA2_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --arg exp "$new_expiry" '.expiry = $exp' "$HYSTERIA2_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$HYSTERIA2_ACCOUNT_DIR/${username}.json"; chmod 600 "$HYSTERIA2_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun Hysteria2 diperpanjang: $username (expired: $new_expiry)"
}

lock_hysteria2_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: lock_hysteria2_account <username>"; return 1; fi
    if [[ -f "$HYSTERIA2_CONFIG" ]]; then
        sed -i "/^  ${username}:/d" "$HYSTERIA2_CONFIG" 2>/dev/null || true
    fi
    if [[ -f "$HYSTERIA2_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq '.status = "locked"' "$HYSTERIA2_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$HYSTERIA2_ACCOUNT_DIR/${username}.json"; chmod 600 "$HYSTERIA2_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun Hysteria2 dikunci: $username"
}

unlock_hysteria2_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: unlock_hysteria2_account <username>"; return 1; fi
    if [[ -f "$HYSTERIA2_ACCOUNT_DIR/${username}.json" && -f "$HYSTERIA2_CONFIG" ]] && command -v jq &>/dev/null; then
        local pw; pw=$(jq -r '.password' "$HYSTERIA2_ACCOUNT_DIR/${username}.json" 2>/dev/null)
        if [[ -n "$pw" ]]; then
            sed -i "/^auth:/a\\  ${username}: ${pw}" "$HYSTERIA2_CONFIG" 2>/dev/null || true
        fi
        local tmp_file; tmp_file=$(mktemp)
        jq '.status = "active"' "$HYSTERIA2_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$HYSTERIA2_ACCOUNT_DIR/${username}.json"; chmod 600 "$HYSTERIA2_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun Hysteria2 dibuka: $username"
}

ban_hysteria2_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: ban_hysteria2_account <username>"; return 1; fi
    lock_hysteria2_account "$username"
    if [[ -f "$HYSTERIA2_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq '.status = "banned"' "$HYSTERIA2_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$HYSTERIA2_ACCOUNT_DIR/${username}.json"; chmod 600 "$HYSTERIA2_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun Hysteria2 di-ban: $username"
}

unban_hysteria2_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: unban_hysteria2_account <username>"; return 1; fi
    unlock_hysteria2_account "$username"; log "Akun Hysteria2 di-unban: $username"
}

limit_ip_hysteria2() {
    local username="$1"; local max_ip="${2:-2}"
    if [[ -z "$username" ]]; then log_error "Usage: limit_ip_hysteria2 <username> [max_ip]"; return 1; fi
    if [[ -f "$HYSTERIA2_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --argjson limit "$max_ip" '.ip_limit = $limit' "$HYSTERIA2_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$HYSTERIA2_ACCOUNT_DIR/${username}.json"; chmod 600 "$HYSTERIA2_ACCOUNT_DIR/${username}.json"
    fi
    log "Limit IP Hysteria2 diset: $username = $max_ip"
}

limit_quota_hysteria2() {
    local username="$1"; local quota_gb="${2:-0}"
    if [[ -z "$username" ]]; then log_error "Usage: limit_quota_hysteria2 <username> [quota_gb]"; return 1; fi
    local quota_bytes=0; if [[ "$quota_gb" -gt 0 ]]; then quota_bytes=$((quota_gb * 1073741824)); fi
    if [[ -f "$HYSTERIA2_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --argjson limit "$quota_bytes" '.quota_limit = $limit' "$HYSTERIA2_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$HYSTERIA2_ACCOUNT_DIR/${username}.json"; chmod 600 "$HYSTERIA2_ACCOUNT_DIR/${username}.json"
    fi
    log "Limit quota Hysteria2 diset: $username = ${quota_gb}GB"
}

list_hysteria2_accounts() {
    log "Daftar akun Hysteria2:"
    if [[ -d "$HYSTERIA2_ACCOUNT_DIR" ]]; then
        for f in "$HYSTERIA2_ACCOUNT_DIR"/*.json; do [[ -f "$f" ]] || continue
            if command -v jq &>/dev/null; then jq -r '"\(.username)\t\(.expiry)\t\(.status)"' "$f" 2>/dev/null
            else basename "$f" .json; fi
        done
    fi
}

# ============================================================================
# Trojan-Go Account Management
# ============================================================================

create_trojan_go_account() {
    local username="$1"
    local days="${2:-30}"

    if [[ -z "$username" ]]; then log_error "Usage: create_trojan_go_account <username> [days]"; return 1; fi

    local password; password=$(generate_password 16)
    local expiry; expiry=$(get_expiry_date "$days")
    local domain; domain=$(get_domain)

    # Tambah ke Trojan-Go config
    if [[ -f "$TROJAN_GO_CONFIG" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --arg pw "$password" '.password += [$pw]' "$TROJAN_GO_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$TROJAN_GO_CONFIG"
    fi

    cat > "$TROJAN_GO_ACCOUNT_DIR/${username}.json" <<ACCOUNT_JSON
{
    "username": "$username",
    "password": "$password",
    "created": "$(get_current_date)",
    "expiry": "$expiry",
    "status": "active",
    "protocol": "trojan-go",
    "domain": "$domain"
}
ACCOUNT_JSON
    chmod 600 "$TROJAN_GO_ACCOUNT_DIR/${username}.json"
    log "Akun Trojan-Go dibuat: $username (expired: $expiry)"
}

delete_trojan_go_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: delete_trojan_go_account <username>"; return 1; fi
    if [[ -f "$TROJAN_GO_ACCOUNT_DIR/${username}.json" && -f "$TROJAN_GO_CONFIG" ]] && command -v jq &>/dev/null; then
        local pw; pw=$(jq -r '.password' "$TROJAN_GO_ACCOUNT_DIR/${username}.json" 2>/dev/null)
        if [[ -n "$pw" ]]; then
            local tmp_file; tmp_file=$(mktemp)
            jq --arg pw "$pw" '.password |= map(select(. != $pw))' "$TROJAN_GO_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$TROJAN_GO_CONFIG"
        fi
    fi
    rm -f "$TROJAN_GO_ACCOUNT_DIR/${username}.json"
    log "Akun Trojan-Go dihapus: $username"
}

extend_trojan_go_account() {
    local username="$1"; local days="${2:-30}"
    if [[ -z "$username" ]]; then log_error "Usage: extend_trojan_go_account <username> [days]"; return 1; fi
    local new_expiry; new_expiry=$(get_expiry_date "$days")
    if [[ -f "$TROJAN_GO_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq --arg exp "$new_expiry" '.expiry = $exp' "$TROJAN_GO_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$TROJAN_GO_ACCOUNT_DIR/${username}.json"; chmod 600 "$TROJAN_GO_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun Trojan-Go diperpanjang: $username (expired: $new_expiry)"
}

lock_trojan_go_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: lock_trojan_go_account <username>"; return 1; fi
    if [[ -f "$TROJAN_GO_ACCOUNT_DIR/${username}.json" && -f "$TROJAN_GO_CONFIG" ]] && command -v jq &>/dev/null; then
        local pw; pw=$(jq -r '.password' "$TROJAN_GO_ACCOUNT_DIR/${username}.json" 2>/dev/null)
        if [[ -n "$pw" ]]; then
            local tmp_file; tmp_file=$(mktemp)
            jq --arg pw "$pw" '.password |= map(select(. != $pw))' "$TROJAN_GO_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$TROJAN_GO_CONFIG"
        fi
        local tmp_file; tmp_file=$(mktemp)
        jq '.status = "locked"' "$TROJAN_GO_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$TROJAN_GO_ACCOUNT_DIR/${username}.json"; chmod 600 "$TROJAN_GO_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun Trojan-Go dikunci: $username"
}

unlock_trojan_go_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: unlock_trojan_go_account <username>"; return 1; fi
    if [[ -f "$TROJAN_GO_ACCOUNT_DIR/${username}.json" && -f "$TROJAN_GO_CONFIG" ]] && command -v jq &>/dev/null; then
        local pw; pw=$(jq -r '.password' "$TROJAN_GO_ACCOUNT_DIR/${username}.json" 2>/dev/null)
        if [[ -n "$pw" ]]; then
            local tmp_file; tmp_file=$(mktemp)
            jq --arg pw "$pw" '.password += [$pw]' "$TROJAN_GO_CONFIG" > "$tmp_file" 2>/dev/null && mv "$tmp_file" "$TROJAN_GO_CONFIG"
        fi
        local tmp_file; tmp_file=$(mktemp)
        jq '.status = "active"' "$TROJAN_GO_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$TROJAN_GO_ACCOUNT_DIR/${username}.json"; chmod 600 "$TROJAN_GO_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun Trojan-Go dibuka: $username"
}

ban_trojan_go_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: ban_trojan_go_account <username>"; return 1; fi
    lock_trojan_go_account "$username"
    if [[ -f "$TROJAN_GO_ACCOUNT_DIR/${username}.json" ]] && command -v jq &>/dev/null; then
        local tmp_file; tmp_file=$(mktemp)
        jq '.status = "banned"' "$TROJAN_GO_ACCOUNT_DIR/${username}.json" > "$tmp_file"
        mv "$tmp_file" "$TROJAN_GO_ACCOUNT_DIR/${username}.json"; chmod 600 "$TROJAN_GO_ACCOUNT_DIR/${username}.json"
    fi
    log "Akun Trojan-Go di-ban: $username"
}

unban_trojan_go_account() {
    local username="$1"
    if [[ -z "$username" ]]; then log_error "Usage: unban_trojan_go_account <username>"; return 1; fi
    unlock_trojan_go_account "$username"; log "Akun Trojan-Go di-unban: $username"
}

list_trojan_go_accounts() {
    log "Daftar akun Trojan-Go:"
    if [[ -d "$TROJAN_GO_ACCOUNT_DIR" ]]; then
        for f in "$TROJAN_GO_ACCOUNT_DIR"/*.json; do [[ -f "$f" ]] || continue
            if command -v jq &>/dev/null; then jq -r '"\(.username)\t\(.expiry)\t\(.status)"' "$f" 2>/dev/null
            else basename "$f" .json; fi
        done
    fi
}

# ============================================================================
# Bulk Create & Recover Expired
# ============================================================================

bulk_create_accounts() {
    local protocol="$1"
    local count="${2:-1}"
    local prefix="${3:-user}"
    local days="${4:-30}"

    if [[ -z "$protocol" ]]; then
        log_error "Usage: bulk_create_accounts <protocol> [count] [prefix] [days]"
        return 1
    fi

    log "Bulk create $count akun $protocol dengan prefix '$prefix'..."

    local i
    for ((i = 1; i <= count; i++)); do
        local username="${prefix}${i}"
        case "$protocol" in
            ssh)           create_ssh_account "$username" "$(generate_password 12)" "$days" ;;
            vmess)         create_vmess_account "$username" "$days" ;;
            vless)         create_vless_account "$username" "$days" ;;
            trojan)        create_trojan_account "$username" "$days" ;;
            shadowsocks)   create_shadowsocks_account "$username" "$days" ;;
            socks)         create_socks_account "$username" "$days" ;;
            hysteria2)     create_hysteria2_account "$username" "$days" ;;
            trojan-go)     create_trojan_go_account "$username" "$days" ;;
            *)
                log_error "Protokol tidak dikenal: $protocol"
                return 1
                ;;
        esac
    done

    log "Bulk create selesai: $count akun $protocol"
}

recover_expired_accounts() {
    local protocol="$1"
    local days="${2:-30}"

    if [[ -z "$protocol" ]]; then
        log_error "Usage: recover_expired_accounts <protocol> [days]"
        return 1
    fi

    local account_dir=""
    case "$protocol" in
        vmess)         account_dir="$VMESS_ACCOUNT_DIR" ;;
        vless)         account_dir="$VLESS_ACCOUNT_DIR" ;;
        trojan)        account_dir="$TROJAN_ACCOUNT_DIR" ;;
        shadowsocks)   account_dir="$SHADOWSOCKS_ACCOUNT_DIR" ;;
        socks)         account_dir="$SOCKS_ACCOUNT_DIR" ;;
        hysteria2)     account_dir="$HYSTERIA2_ACCOUNT_DIR" ;;
        trojan-go)     account_dir="$TROJAN_GO_ACCOUNT_DIR" ;;
        *)
            log_error "Protokol tidak dikenal: $protocol"
            return 1
            ;;
    esac

    log "Memulihkan akun expired untuk protokol: $protocol"

    if [[ -d "$account_dir" ]]; then
        for f in "$account_dir"/*.json; do
            [[ -f "$f" ]] || continue
            if command -v jq &>/dev/null; then
                local expiry username
                expiry=$(jq -r '.expiry' "$f" 2>/dev/null)
                username=$(jq -r '.username' "$f" 2>/dev/null)
                if is_expired "$expiry"; then
                    case "$protocol" in
                        vmess)       extend_vmess_account "$username" "$days" ;;
                        vless)       extend_vless_account "$username" "$days" ;;
                        trojan)      extend_trojan_account "$username" "$days" ;;
                        shadowsocks) extend_shadowsocks_account "$username" "$days" ;;
                        socks)       extend_socks_account "$username" "$days" ;;
                        hysteria2)   extend_hysteria2_account "$username" "$days" ;;
                        trojan-go)   extend_trojan_go_account "$username" "$days" ;;
                    esac
                    log "Akun dipulihkan: $username ($protocol)"
                fi
            fi
        done
    fi

    log "Recovery selesai untuk protokol: $protocol"
}

# ============================================================================
# Utility Scripts — Expiry Checker
# ============================================================================

create_xp_ssh_script() {
    log "Membuat script xp-ssh (SSH expiry checker)..."

    cat > "$XP_SSH_BIN" <<'XP_SSH_SCRIPT'
#!/bin/bash
# xp-ssh — SSH Account Expiry Checker
# Cek masa aktif akun SSH

SSH_DIR="/etc/vpnray/accounts/ssh"
TODAY=$(date '+%Y-%m-%d')

echo "=========================================="
echo "   SSH Account Expiry Status"
echo "=========================================="
printf "%-15s %-12s %-10s\n" "Username" "Expiry" "Status"
echo "------------------------------------------"

if [[ -d "$SSH_DIR" ]]; then
    for f in "$SSH_DIR"/*.json; do
        [[ -f "$f" ]] || continue
        if command -v jq &>/dev/null; then
            username=$(jq -r '.username' "$f" 2>/dev/null)
            expiry=$(jq -r '.expiry' "$f" 2>/dev/null)
            if [[ "$expiry" < "$TODAY" ]]; then
                status="EXPIRED"
            else
                status="Active"
            fi
            printf "%-15s %-12s %-10s\n" "$username" "$expiry" "$status"
        fi
    done
fi
echo "=========================================="
XP_SSH_SCRIPT

    chmod +x "$XP_SSH_BIN"
    log "Script xp-ssh berhasil dibuat: $XP_SSH_BIN"
}

create_xp_xray_script() {
    log "Membuat script xp-xray (Xray expiry checker)..."

    cat > "$XP_XRAY_BIN" <<'XP_XRAY_SCRIPT'
#!/bin/bash
# xp-xray — Xray Account Expiry Checker
# Cek masa aktif akun Xray (VMess, VLESS, Trojan, Shadowsocks, Socks)

ACCOUNT_DIR="/etc/vpnray/accounts"
TODAY=$(date '+%Y-%m-%d')
PROTOCOLS=("vmess" "vless" "trojan" "shadowsocks" "socks" "hysteria2" "trojan-go")

echo "=========================================="
echo "   Xray Account Expiry Status"
echo "=========================================="

for proto in "${PROTOCOLS[@]}"; do
    proto_dir="$ACCOUNT_DIR/$proto"
    [[ -d "$proto_dir" ]] || continue

    echo ""
    echo "--- $proto ---"
    printf "%-15s %-12s %-10s\n" "Username" "Expiry" "Status"
    echo "------------------------------------------"

    for f in "$proto_dir"/*.json; do
        [[ -f "$f" ]] || continue
        if command -v jq &>/dev/null; then
            username=$(jq -r '.username' "$f" 2>/dev/null)
            expiry=$(jq -r '.expiry' "$f" 2>/dev/null)
            if [[ "$expiry" < "$TODAY" ]]; then
                status="EXPIRED"
            else
                status="Active"
            fi
            printf "%-15s %-12s %-10s\n" "$username" "$expiry" "$status"
        fi
    done
done

echo ""
echo "=========================================="
XP_XRAY_SCRIPT

    chmod +x "$XP_XRAY_BIN"
    log "Script xp-xray berhasil dibuat: $XP_XRAY_BIN"
}

# ============================================================================
# Utility Scripts — Auto Delete & Auto Disconnect
# ============================================================================

create_auto_delete_script() {
    log "Membuat script auto-delete-expired..."

    cat > "$AUTO_DELETE_BIN" <<'AUTO_DELETE_SCRIPT'
#!/bin/bash
# auto-delete-expired — Hapus akun expired otomatis
# Dijalankan via cronjob setiap hari jam 00:00

LOG_FILE="/root/syslog.log"
ACCOUNT_DIR="/etc/vpnray/accounts"
TODAY=$(date '+%Y-%m-%d')

log_auto() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] AUTO-DELETE: $1" >> "$LOG_FILE"
}

# Delete expired SSH accounts
if [[ -d "$ACCOUNT_DIR/ssh" ]]; then
    for f in "$ACCOUNT_DIR/ssh"/*.json; do
        [[ -f "$f" ]] || continue
        if command -v jq &>/dev/null; then
            expiry=$(jq -r '.expiry' "$f" 2>/dev/null)
            username=$(jq -r '.username' "$f" 2>/dev/null)
            if [[ "$expiry" < "$TODAY" ]]; then
                pkill -u "$username" 2>/dev/null || true
                userdel -r "$username" 2>/dev/null || true
                rm -f "$f"
                log_auto "SSH account deleted: $username (expired: $expiry)"
            fi
        fi
    done
fi

# Delete expired Xray accounts
for proto in vmess vless trojan shadowsocks socks hysteria2 trojan-go; do
    proto_dir="$ACCOUNT_DIR/$proto"
    [[ -d "$proto_dir" ]] || continue

    for f in "$proto_dir"/*.json; do
        [[ -f "$f" ]] || continue
        if command -v jq &>/dev/null; then
            expiry=$(jq -r '.expiry' "$f" 2>/dev/null)
            username=$(jq -r '.username' "$f" 2>/dev/null)
            if [[ "$expiry" < "$TODAY" ]]; then
                rm -f "$f"
                log_auto "$proto account deleted: $username (expired: $expiry)"
            fi
        fi
    done
done

# Reload services
systemctl restart xray 2>/dev/null || true
systemctl restart hysteria2 2>/dev/null || true
systemctl restart trojan-go 2>/dev/null || true

log_auto "Auto-delete completed."
AUTO_DELETE_SCRIPT

    chmod +x "$AUTO_DELETE_BIN"
    log "Script auto-delete-expired berhasil dibuat: $AUTO_DELETE_BIN"
}

create_auto_disconnect_script() {
    log "Membuat script auto-disconnect-duplicate..."

    cat > "$AUTO_DISCONNECT_BIN" <<'AUTO_DISCONNECT_SCRIPT'
#!/bin/bash
# auto-disconnect-duplicate — Disconnect session duplikat
# Enforce IP limit per user

LOG_FILE="/root/syslog.log"
ACCOUNT_DIR="/etc/vpnray/accounts"

log_auto() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] AUTO-DISCONNECT: $1" >> "$LOG_FILE"
}

# Check SSH duplicate sessions
if [[ -d "$ACCOUNT_DIR/ssh" ]]; then
    for f in "$ACCOUNT_DIR/ssh"/*.json; do
        [[ -f "$f" ]] || continue
        if command -v jq &>/dev/null; then
            username=$(jq -r '.username' "$f" 2>/dev/null)
            ip_limit=$(jq -r '.ip_limit // 2' "$f" 2>/dev/null)
            login_count=$(who | grep -c "^${username} " 2>/dev/null || echo "0")

            if [[ "$login_count" -gt "$ip_limit" ]]; then
                pkill -u "$username" 2>/dev/null || true
                log_auto "SSH duplicate disconnected: $username ($login_count > $ip_limit)"
            fi
        fi
    done
fi

log_auto "Auto-disconnect check completed."
AUTO_DISCONNECT_SCRIPT

    chmod +x "$AUTO_DISCONNECT_BIN"
    log "Script auto-disconnect-duplicate berhasil dibuat: $AUTO_DISCONNECT_BIN"
}

# ============================================================================
# Utility Scripts — Limit IP, Limit Quota, Lock
# ============================================================================

create_limit_ip_scripts() {
    log "Membuat script limit-ip-ssh dan limit-ip-xray..."

    cat > "$LIMIT_IP_SSH_BIN" <<'LIMIT_IP_SSH_SCRIPT'
#!/bin/bash
# limit-ip-ssh — Set IP limit untuk akun SSH
USERNAME="$1"
MAX_IP="${2:-2}"
ACCOUNT_DIR="/etc/vpnray/accounts/ssh"

if [[ -z "$USERNAME" ]]; then
    echo "Usage: limit-ip-ssh <username> [max_ip]"
    exit 1
fi

if [[ -f "$ACCOUNT_DIR/${USERNAME}.json" ]] && command -v jq &>/dev/null; then
    tmp=$(mktemp)
    jq --argjson limit "$MAX_IP" '.ip_limit = $limit' "$ACCOUNT_DIR/${USERNAME}.json" > "$tmp"
    mv "$tmp" "$ACCOUNT_DIR/${USERNAME}.json"
    chmod 600 "$ACCOUNT_DIR/${USERNAME}.json"
    echo "IP limit set: $USERNAME = $MAX_IP"
else
    echo "Account not found: $USERNAME"
    exit 1
fi
LIMIT_IP_SSH_SCRIPT

    cat > "$LIMIT_IP_XRAY_BIN" <<'LIMIT_IP_XRAY_SCRIPT'
#!/bin/bash
# limit-ip-xray — Set IP limit untuk akun Xray
USERNAME="$1"
MAX_IP="${2:-2}"
PROTOCOL="${3:-vmess}"
ACCOUNT_DIR="/etc/vpnray/accounts/$PROTOCOL"

if [[ -z "$USERNAME" ]]; then
    echo "Usage: limit-ip-xray <username> [max_ip] [protocol]"
    exit 1
fi

if [[ -f "$ACCOUNT_DIR/${USERNAME}.json" ]] && command -v jq &>/dev/null; then
    tmp=$(mktemp)
    jq --argjson limit "$MAX_IP" '.ip_limit = $limit' "$ACCOUNT_DIR/${USERNAME}.json" > "$tmp"
    mv "$tmp" "$ACCOUNT_DIR/${USERNAME}.json"
    chmod 600 "$ACCOUNT_DIR/${USERNAME}.json"
    echo "IP limit set: $USERNAME = $MAX_IP ($PROTOCOL)"
else
    echo "Account not found: $USERNAME ($PROTOCOL)"
    exit 1
fi
LIMIT_IP_XRAY_SCRIPT

    chmod +x "$LIMIT_IP_SSH_BIN" "$LIMIT_IP_XRAY_BIN"
    log "Script limit-ip berhasil dibuat."
}

create_limit_quota_script() {
    log "Membuat script limit-quota-xray..."

    cat > "$LIMIT_QUOTA_XRAY_BIN" <<'LIMIT_QUOTA_SCRIPT'
#!/bin/bash
# limit-quota-xray — Set quota limit untuk akun Xray
USERNAME="$1"
QUOTA_GB="${2:-0}"
PROTOCOL="${3:-vmess}"
ACCOUNT_DIR="/etc/vpnray/accounts/$PROTOCOL"

if [[ -z "$USERNAME" ]]; then
    echo "Usage: limit-quota-xray <username> [quota_gb] [protocol]"
    exit 1
fi

QUOTA_BYTES=0
if [[ "$QUOTA_GB" -gt 0 ]]; then
    QUOTA_BYTES=$((QUOTA_GB * 1073741824))
fi

if [[ -f "$ACCOUNT_DIR/${USERNAME}.json" ]] && command -v jq &>/dev/null; then
    tmp=$(mktemp)
    jq --argjson limit "$QUOTA_BYTES" '.quota_limit = $limit' "$ACCOUNT_DIR/${USERNAME}.json" > "$tmp"
    mv "$tmp" "$ACCOUNT_DIR/${USERNAME}.json"
    chmod 600 "$ACCOUNT_DIR/${USERNAME}.json"
    echo "Quota limit set: $USERNAME = ${QUOTA_GB}GB ($PROTOCOL)"
else
    echo "Account not found: $USERNAME ($PROTOCOL)"
    exit 1
fi
LIMIT_QUOTA_SCRIPT

    chmod +x "$LIMIT_QUOTA_XRAY_BIN"
    log "Script limit-quota-xray berhasil dibuat."
}

create_lock_scripts() {
    log "Membuat script lock-ssh dan lock-xray..."

    cat > "$LOCK_SSH_BIN" <<'LOCK_SSH_SCRIPT'
#!/bin/bash
# lock-ssh — Lock akun SSH
USERNAME="$1"
if [[ -z "$USERNAME" ]]; then echo "Usage: lock-ssh <username>"; exit 1; fi
passwd -l "$USERNAME" 2>/dev/null
touch "/etc/vpnray/ssh-locked/${USERNAME}"
echo "SSH account locked: $USERNAME"
LOCK_SSH_SCRIPT

    cat > "$LOCK_XRAY_BIN" <<'LOCK_XRAY_SCRIPT'
#!/bin/bash
# lock-xray — Lock akun Xray (hapus dari config aktif)
USERNAME="$1"
PROTOCOL="${2:-vmess}"
ACCOUNT_DIR="/etc/vpnray/accounts/$PROTOCOL"
XRAY_CONFIG="/etc/xray/config.json"

if [[ -z "$USERNAME" ]]; then echo "Usage: lock-xray <username> [protocol]"; exit 1; fi

if [[ -f "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
    tmp=$(mktemp)
    jq --arg email "$USERNAME" '(.inbounds[].settings.clients) |= map(select(.email != $email))' \
       "$XRAY_CONFIG" > "$tmp" 2>/dev/null && mv "$tmp" "$XRAY_CONFIG"
fi

if [[ -f "$ACCOUNT_DIR/${USERNAME}.json" ]] && command -v jq &>/dev/null; then
    tmp=$(mktemp)
    jq '.status = "locked"' "$ACCOUNT_DIR/${USERNAME}.json" > "$tmp"
    mv "$tmp" "$ACCOUNT_DIR/${USERNAME}.json"
    chmod 600 "$ACCOUNT_DIR/${USERNAME}.json"
fi

systemctl restart xray 2>/dev/null || true
echo "Xray account locked: $USERNAME ($PROTOCOL)"
LOCK_XRAY_SCRIPT

    chmod +x "$LOCK_SSH_BIN" "$LOCK_XRAY_BIN"
    log "Script lock-ssh dan lock-xray berhasil dibuat."
}

# ============================================================================
# Bandwidth Per User Monitoring
# ============================================================================

setup_bandwidth_monitoring() {
    log "Mengkonfigurasi bandwidth monitoring per user..."

    # Xray memiliki API stats built-in — pastikan stats sudah aktif di config
    if [[ -f "$XRAY_CONFIG" ]] && command -v jq &>/dev/null; then
        local has_stats
        has_stats=$(jq '.stats // empty' "$XRAY_CONFIG" 2>/dev/null)
        if [[ -n "$has_stats" ]]; then
            log "Xray API stats sudah aktif."
        else
            log_warn "Xray API stats belum dikonfigurasi. Bandwidth monitoring mungkin terbatas."
        fi
    fi

    log "Bandwidth monitoring per user dikonfigurasi."
}

# ============================================================================
# Subscription Link Generator
# ============================================================================

create_subscription_generator() {
    log "Membuat subscription link generator..."

    local sub_bin="/usr/local/bin/generate-subscription"

    cat > "$sub_bin" <<'SUB_SCRIPT'
#!/bin/bash
# generate-subscription — Generate subscription link untuk client app
# Usage: generate-subscription <username> <protocol>

USERNAME="$1"
PROTOCOL="${2:-vmess}"
ACCOUNT_DIR="/etc/vpnray/accounts/$PROTOCOL"
DOMAIN_FILE="/etc/xray/domain"

if [[ -z "$USERNAME" ]]; then
    echo "Usage: generate-subscription <username> [protocol]"
    exit 1
fi

if [[ ! -f "$ACCOUNT_DIR/${USERNAME}.json" ]]; then
    echo "Account not found: $USERNAME ($PROTOCOL)"
    exit 1
fi

DOMAIN=""
if [[ -f "$DOMAIN_FILE" ]]; then
    DOMAIN=$(head -1 "$DOMAIN_FILE" 2>/dev/null | tr -d '[:space:]')
fi

if command -v jq &>/dev/null; then
    case "$PROTOCOL" in
        vmess)
            UUID=$(jq -r '.uuid' "$ACCOUNT_DIR/${USERNAME}.json" 2>/dev/null)
            # VMess link format (base64 encoded JSON)
            VMESS_JSON="{\"v\":\"2\",\"ps\":\"${USERNAME}-ws-tls\",\"add\":\"${DOMAIN}\",\"port\":\"443\",\"id\":\"${UUID}\",\"aid\":\"0\",\"scy\":\"auto\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"${DOMAIN}\",\"path\":\"/vmessws\",\"tls\":\"tls\",\"sni\":\"${DOMAIN}\"}"
            echo "vmess://$(echo -n "$VMESS_JSON" | base64 -w 0)"
            ;;
        vless)
            UUID=$(jq -r '.uuid' "$ACCOUNT_DIR/${USERNAME}.json" 2>/dev/null)
            echo "vless://${UUID}@${DOMAIN}:443?type=ws&security=tls&host=${DOMAIN}&path=%2Fvlessws&sni=${DOMAIN}#${USERNAME}-ws-tls"
            ;;
        trojan)
            PASSWORD=$(jq -r '.password' "$ACCOUNT_DIR/${USERNAME}.json" 2>/dev/null)
            echo "trojan://${PASSWORD}@${DOMAIN}:443?type=ws&security=tls&host=${DOMAIN}&path=%2Ftrojanws&sni=${DOMAIN}#${USERNAME}-ws-tls"
            ;;
        *)
            echo "Protocol not supported for subscription: $PROTOCOL"
            exit 1
            ;;
    esac
fi
SUB_SCRIPT

    chmod +x "$sub_bin"
    log "Subscription generator berhasil dibuat: $sub_bin"
}

# ============================================================================
# Clash Config Generator
# ============================================================================

create_clash_config_generator() {
    log "Membuat Clash config generator..."

    local clash_bin="/usr/local/bin/generate-clash"

    cat > "$clash_bin" <<'CLASH_SCRIPT'
#!/bin/bash
# generate-clash — Generate Clash YAML config per user
# Usage: generate-clash <username> <protocol>

USERNAME="$1"
PROTOCOL="${2:-vmess}"
ACCOUNT_DIR="/etc/vpnray/accounts/$PROTOCOL"
DOMAIN_FILE="/etc/xray/domain"

if [[ -z "$USERNAME" ]]; then
    echo "Usage: generate-clash <username> [protocol]"
    exit 1
fi

if [[ ! -f "$ACCOUNT_DIR/${USERNAME}.json" ]]; then
    echo "Account not found: $USERNAME ($PROTOCOL)"
    exit 1
fi

DOMAIN=""
if [[ -f "$DOMAIN_FILE" ]]; then
    DOMAIN=$(head -1 "$DOMAIN_FILE" 2>/dev/null | tr -d '[:space:]')
fi

if command -v jq &>/dev/null; then
    case "$PROTOCOL" in
        vmess)
            UUID=$(jq -r '.uuid' "$ACCOUNT_DIR/${USERNAME}.json" 2>/dev/null)
            cat <<CLASH_YAML
port: 7890
socks-port: 7891
allow-lan: false
mode: Rule
log-level: info

proxies:
  - name: "${USERNAME}-vmess-ws"
    type: vmess
    server: ${DOMAIN}
    port: 443
    uuid: ${UUID}
    alterId: 0
    cipher: auto
    udp: true
    tls: true
    servername: ${DOMAIN}
    network: ws
    ws-opts:
      path: /vmessws
      headers:
        Host: ${DOMAIN}

proxy-groups:
  - name: "Proxy"
    type: select
    proxies:
      - "${USERNAME}-vmess-ws"

rules:
  - MATCH,Proxy
CLASH_YAML
            ;;
        vless)
            UUID=$(jq -r '.uuid' "$ACCOUNT_DIR/${USERNAME}.json" 2>/dev/null)
            cat <<CLASH_YAML
port: 7890
socks-port: 7891
allow-lan: false
mode: Rule
log-level: info

proxies:
  - name: "${USERNAME}-vless-ws"
    type: vless
    server: ${DOMAIN}
    port: 443
    uuid: ${UUID}
    udp: true
    tls: true
    servername: ${DOMAIN}
    network: ws
    ws-opts:
      path: /vlessws
      headers:
        Host: ${DOMAIN}

proxy-groups:
  - name: "Proxy"
    type: select
    proxies:
      - "${USERNAME}-vless-ws"

rules:
  - MATCH,Proxy
CLASH_YAML
            ;;
        *)
            echo "# Protocol $PROTOCOL not yet supported for Clash config"
            ;;
    esac
fi
CLASH_SCRIPT

    chmod +x "$clash_bin"
    log "Clash config generator berhasil dibuat: $clash_bin"
}

# ============================================================================
# VPNRay JSON Converter
# ============================================================================

create_vpnray_converter() {
    log "Membuat VPNRay JSON converter..."

    local vpnray_bin="/usr/local/bin/generate-vpnray"

    cat > "$vpnray_bin" <<'VPNRAY_SCRIPT'
#!/bin/bash
# generate-vpnray — VPNRay JSON Converter untuk Custom HTTP
# Usage: generate-vpnray <username> <protocol>

USERNAME="$1"
PROTOCOL="${2:-vmess}"
ACCOUNT_DIR="/etc/vpnray/accounts/$PROTOCOL"
DOMAIN_FILE="/etc/xray/domain"

if [[ -z "$USERNAME" ]]; then
    echo "Usage: generate-vpnray <username> [protocol]"
    exit 1
fi

if [[ ! -f "$ACCOUNT_DIR/${USERNAME}.json" ]]; then
    echo "Account not found: $USERNAME ($PROTOCOL)"
    exit 1
fi

DOMAIN=""
if [[ -f "$DOMAIN_FILE" ]]; then
    DOMAIN=$(head -1 "$DOMAIN_FILE" 2>/dev/null | tr -d '[:space:]')
fi

if command -v jq &>/dev/null; then
    case "$PROTOCOL" in
        vmess)
            UUID=$(jq -r '.uuid' "$ACCOUNT_DIR/${USERNAME}.json" 2>/dev/null)
            cat <<VPNRAY_JSON
{
    "dns": "1.1.1.1",
    "proxyIp": "${DOMAIN}",
    "proxyPort": "443",
    "uuid": "${UUID}",
    "path": "/vmessws",
    "type": "vmess",
    "security": "tls",
    "network": "ws",
    "host": "${DOMAIN}",
    "sni": "${DOMAIN}",
    "remark": "${USERNAME}-vmess"
}
VPNRAY_JSON
            ;;
        vless)
            UUID=$(jq -r '.uuid' "$ACCOUNT_DIR/${USERNAME}.json" 2>/dev/null)
            cat <<VPNRAY_JSON
{
    "dns": "1.1.1.1",
    "proxyIp": "${DOMAIN}",
    "proxyPort": "443",
    "uuid": "${UUID}",
    "path": "/vlessws",
    "type": "vless",
    "security": "tls",
    "network": "ws",
    "host": "${DOMAIN}",
    "sni": "${DOMAIN}",
    "remark": "${USERNAME}-vless"
}
VPNRAY_JSON
            ;;
        *)
            echo "{\"error\": \"Protocol $PROTOCOL not supported\"}"
            ;;
    esac
fi
VPNRAY_SCRIPT

    chmod +x "$vpnray_bin"
    log "VPNRay JSON converter berhasil dibuat: $vpnray_bin"
}

# ============================================================================
# Cronjob Setup
# ============================================================================

setup_account_cronjobs() {
    log "Mengkonfigurasi cronjob untuk manajemen akun..."

    # Auto delete expired — setiap hari jam 00:00
    cat > "$CRON_DELETE_EXPIRED" <<CRON_DEL
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Auto delete expired accounts — setiap hari jam 00:00
0 0 * * * root $AUTO_DELETE_BIN >> /root/syslog.log 2>&1
CRON_DEL
    chmod 644 "$CRON_DELETE_EXPIRED"

    # Auto disconnect duplicate — setiap 5 menit
    cat > "$CRON_DISCONNECT_DUP" <<CRON_DIS
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Auto disconnect duplicate sessions — setiap 5 menit
*/5 * * * * root $AUTO_DISCONNECT_BIN >> /root/syslog.log 2>&1
CRON_DIS
    chmod 644 "$CRON_DISCONNECT_DUP"

    log "Cronjob berhasil dikonfigurasi."
}

# ============================================================================
# Main Function
# ============================================================================

main() {
    print_header

    log "Memulai Tahap 6: Setup Manajemen Akun & User..."

    # Pengecekan prasyarat
    log "Memulai pengecekan prasyarat..."
    check_root
    check_os
    check_arch
    check_virt
    check_tahap5
    log "Semua pengecekan prasyarat berhasil."

    # 1. Setup direktori akun
    setup_account_directories

    # 2. Buat utility scripts — Expiry checker
    create_xp_ssh_script
    create_xp_xray_script

    # 3. Buat utility scripts — Auto delete & disconnect
    create_auto_delete_script
    create_auto_disconnect_script

    # 4. Buat utility scripts — Limit IP, quota, lock
    create_limit_ip_scripts
    create_limit_quota_script
    create_lock_scripts

    # 5. Setup monitoring
    setup_bandwidth_monitoring

    # 6. Buat generators
    create_subscription_generator
    create_clash_config_generator
    create_vpnray_converter

    # 7. Setup cronjobs
    setup_account_cronjobs

    # Selesai
    echo ""
    echo -e "${GREEN}=============================================="
    echo "  Tahap 6 selesai!"
    echo ""
    echo "  Direktori Akun:"
    echo "    SSH          : $SSH_ACCOUNT_DIR"
    echo "    VMess        : $VMESS_ACCOUNT_DIR"
    echo "    VLESS        : $VLESS_ACCOUNT_DIR"
    echo "    Trojan       : $TROJAN_ACCOUNT_DIR"
    echo "    Shadowsocks  : $SHADOWSOCKS_ACCOUNT_DIR"
    echo "    Socks        : $SOCKS_ACCOUNT_DIR"
    echo "    Hysteria2    : $HYSTERIA2_ACCOUNT_DIR"
    echo "    Trojan-Go    : $TROJAN_GO_ACCOUNT_DIR"
    echo ""
    echo "  Utility Scripts:"
    echo "    xp-ssh                : $XP_SSH_BIN"
    echo "    xp-xray               : $XP_XRAY_BIN"
    echo "    auto-delete-expired    : $AUTO_DELETE_BIN"
    echo "    auto-disconnect-dup    : $AUTO_DISCONNECT_BIN"
    echo "    limit-ip-ssh           : $LIMIT_IP_SSH_BIN"
    echo "    limit-ip-xray          : $LIMIT_IP_XRAY_BIN"
    echo "    limit-quota-xray       : $LIMIT_QUOTA_XRAY_BIN"
    echo "    lock-ssh               : $LOCK_SSH_BIN"
    echo "    lock-xray              : $LOCK_XRAY_BIN"
    echo "    generate-subscription  : /usr/local/bin/generate-subscription"
    echo "    generate-clash         : /usr/local/bin/generate-clash"
    echo "    generate-vpnray        : /usr/local/bin/generate-vpnray"
    echo ""
    echo "  Cronjobs:"
    echo "    Auto Delete  : setiap hari jam 00:00"
    echo "    Auto Disc.   : setiap 5 menit"
    echo ""
    echo "  Protokol didukung:"
    echo "    SSH, VMess, VLESS, Trojan, Shadowsocks,"
    echo "    Socks, Hysteria2, Trojan-Go"
    echo ""
    echo "  Sistem siap untuk instalasi menu (Tahap 7)."
    echo -e "==============================================${NC}"
    echo ""

    log "Tahap 6 selesai. Manajemen akun & user berhasil dikonfigurasi."
}

main "$@"
