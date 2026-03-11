#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript Installer — Tahap 3: Domain, SSL, Nginx & Xray-core
# ============================================================================
# Script ini melakukan setup domain, instalasi SSL certificate,
# konfigurasi Nginx reverse proxy, dan instalasi Xray-core.
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
#   - Tahap 1 (setup.sh) dan Tahap 2 (install.sh) sudah dijalankan
#   - Domain sudah diarahkan ke IP VPS
#
# Penggunaan:
#   chmod +x setup-domain.sh
#   ./setup-domain.sh <domain>                   # Tanpa Cloudflare
#   ./setup-domain.sh <domain> <cf_api_key>      # Dengan Cloudflare API Key
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

# Parameter input
DOMAIN="${1:-}"
CF_API_KEY="${2:-}"

# Paths penting
XRAY_CONFIG_DIR="/etc/xray"
XRAY_CERT="/etc/xray/xray.crt"
XRAY_KEY="/etc/xray/xray.key"
DOMAIN_FILE="/etc/xray/domain"
CF_FILE="/etc/xray/cloudflare"
NGINX_CONF="/etc/nginx/conf.d/xray.conf"
ACME_DIR="/root/.acme.sh"

# Port konfigurasi (sesuai README)
XRAY_WS_TLS_PORT=10001
XRAY_WS_NTLS_PORT=10002
XRAY_GRPC_PORT=10003
XRAY_HTTPUPGRADE_PORT=10004

# Xray download
XRAY_INSTALL_DIR="/usr/local/bin"
XRAY_CONFIG_FILE="/etc/xray/config.json"

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
    echo "  Tahap 3: Domain, SSL, Nginx & Xray-core"
    echo "=============================================="
    echo -e "${NC}"
}

# ============================================================================
# Pengecekan Prasyarat
# ============================================================================

check_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        log_error "Script ini harus dijalankan sebagai root!"
        echo -e "${RED}Gunakan: sudo ./setup-domain.sh${NC}"
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

check_domain_input() {
    if [[ -z "$DOMAIN" ]]; then
        log_error "Domain tidak diberikan!"
        echo -e "${RED}Penggunaan: ./setup-domain.sh <domain> [cf_api_key]${NC}"
        echo -e "${RED}Contoh: ./setup-domain.sh vpn.example.com${NC}"
        exit 1
    fi

    # Validasi format domain (basic regex)
    if ! echo "$DOMAIN" | grep -qP '^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)*\.[a-zA-Z]{2,}$'; then
        log_error "Format domain tidak valid: $DOMAIN"
        echo -e "${RED}Gunakan format domain yang benar, contoh: vpn.example.com${NC}"
        exit 1
    fi

    log "Domain input valid: $DOMAIN"
}

check_dependencies() {
    local missing=false
    local required_cmds=(curl wget)

    for cmd in "${required_cmds[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            log_error "Dependency tidak ditemukan: $cmd"
            log_error "Pastikan Tahap 2 (install.sh) sudah dijalankan."
            missing=true
        fi
    done

    if [[ "$missing" == true ]]; then
        exit 1
    fi

    log "Pengecekan dependencies: OK"
}

# ============================================================================
# Domain Setup & Validation
# ============================================================================

setup_domain() {
    log "Menyimpan domain: $DOMAIN"

    # Simpan domain ke file konfigurasi
    echo "$DOMAIN" > "$DOMAIN_FILE"

    log "Domain disimpan ke $DOMAIN_FILE"
}

validate_domain_dns() {
    log "Memvalidasi DNS domain $DOMAIN..."

    # Dapatkan IP VPS
    local vps_ip
    vps_ip=$(curl -s --ipv4 --max-time 10 ifconfig.me 2>/dev/null)

    if [[ -z "$vps_ip" ]]; then
        vps_ip=$(curl -s --ipv4 --max-time 10 icanhazip.com 2>/dev/null)
    fi

    if [[ -z "$vps_ip" ]]; then
        log_warn "Tidak dapat mendeteksi IP publik VPS. Melewati validasi DNS."
        return
    fi

    log "IP publik VPS terdeteksi: $vps_ip"

    # Resolusi DNS domain
    local domain_ip
    domain_ip=$(dig +short "$DOMAIN" A 2>/dev/null | head -1)

    if [[ -z "$domain_ip" ]]; then
        log_warn "DNS domain $DOMAIN belum terresolusi. Pastikan domain sudah diarahkan ke IP VPS."
        return
    fi

    log "DNS domain $DOMAIN terresolusi ke: $domain_ip"

    if [[ "$vps_ip" != "$domain_ip" ]]; then
        log_warn "IP domain ($domain_ip) tidak sama dengan IP VPS ($vps_ip)."
        log_warn "Pastikan domain sudah diarahkan ke IP VPS yang benar."
    else
        log "Validasi DNS: Domain $DOMAIN sudah mengarah ke IP VPS — OK"
    fi
}

# ============================================================================
# Cloudflare Domain Pointing
# ============================================================================

setup_cloudflare_domain() {
    # Baca CF API Key dari file jika tidak dari argumen
    if [[ -z "$CF_API_KEY" ]] && [[ -f "$CF_FILE" ]]; then
        CF_API_KEY=$(cat "$CF_FILE")
    fi

    if [[ -z "$CF_API_KEY" ]]; then
        log "Cloudflare API Key tidak tersedia. Melewati Cloudflare domain pointing."
        log "Pastikan domain sudah diarahkan ke IP VPS secara manual."
        return
    fi

    log "Mendeteksi konfigurasi Cloudflare..."

    # Simpan CF API Key ke file jika belum ada
    if [[ ! -f "$CF_FILE" ]]; then
        echo "$CF_API_KEY" > "$CF_FILE"
        chmod 600 "$CF_FILE"
        log "Cloudflare API Key disimpan ke $CF_FILE"
    fi

    # Dapatkan IP publik VPS
    local vps_ip
    vps_ip=$(curl -s --ipv4 --max-time 10 ifconfig.me 2>/dev/null)

    if [[ -z "$vps_ip" ]]; then
        vps_ip=$(curl -s --ipv4 --max-time 10 icanhazip.com 2>/dev/null)
    fi

    if [[ -z "$vps_ip" ]]; then
        log_warn "Tidak dapat mendeteksi IP publik. Melewati Cloudflare pointing."
        return
    fi

    # Dapatkan Zone ID dari Cloudflare
    local main_domain
    main_domain=$(echo "$DOMAIN" | awk -F. '{print $(NF-1)"."$NF}')

    log "Mencari Cloudflare Zone untuk domain: $main_domain"

    local zone_response
    zone_response=$(curl -s --max-time 15 -X GET \
        "https://api.cloudflare.com/client/v4/zones?name=$main_domain" \
        -H "Authorization: Bearer $CF_API_KEY" \
        -H "Content-Type: application/json" 2>/dev/null)

    local zone_id
    if command -v jq &>/dev/null; then
        zone_id=$(echo "$zone_response" | jq -r '.result[0].id // empty' 2>/dev/null)
    else
        zone_id=$(echo "$zone_response" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    fi

    if [[ -z "$zone_id" ]]; then
        log_warn "Zone ID tidak ditemukan untuk domain $main_domain."
        log_warn "Pastikan API Key valid dan domain terdaftar di akun Cloudflare."
        return
    fi

    log "Cloudflare Zone ID ditemukan: $zone_id"

    # Cek apakah DNS record sudah ada
    local record_response
    record_response=$(curl -s --max-time 15 -X GET \
        "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records?type=A&name=$DOMAIN" \
        -H "Authorization: Bearer $CF_API_KEY" \
        -H "Content-Type: application/json" 2>/dev/null)

    local record_id
    if command -v jq &>/dev/null; then
        record_id=$(echo "$record_response" | jq -r '.result[0].id // empty' 2>/dev/null)
    else
        record_id=$(echo "$record_response" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    fi

    if [[ -n "$record_id" ]]; then
        # Update existing record
        log "Mengupdate DNS record A untuk $DOMAIN..."
        curl -s --max-time 15 -X PUT \
            "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$record_id" \
            -H "Authorization: Bearer $CF_API_KEY" \
            -H "Content-Type: application/json" \
            --data "{\"type\":\"A\",\"name\":\"$DOMAIN\",\"content\":\"$vps_ip\",\"ttl\":1,\"proxied\":false}" \
            >> "$LOG_FILE" 2>&1
        log "DNS record A untuk $DOMAIN berhasil diupdate ke $vps_ip"
    else
        # Create new record
        log "Membuat DNS record A untuk $DOMAIN..."
        curl -s --max-time 15 -X POST \
            "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records" \
            -H "Authorization: Bearer $CF_API_KEY" \
            -H "Content-Type: application/json" \
            --data "{\"type\":\"A\",\"name\":\"$DOMAIN\",\"content\":\"$vps_ip\",\"ttl\":1,\"proxied\":false}" \
            >> "$LOG_FILE" 2>&1
        log "DNS record A untuk $DOMAIN berhasil dibuat dengan IP $vps_ip"
    fi
}

# ============================================================================
# SSL Certificate Installation (acme.sh)
# ============================================================================

install_acme() {
    log "Menginstall acme.sh untuk manajemen SSL certificate..."

    if [[ -d "$ACME_DIR" ]]; then
        log "acme.sh sudah terinstall. Melewati instalasi."
        return
    fi

    # Install socat (dibutuhkan oleh acme.sh untuk standalone mode)
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y socat >> "$LOG_FILE" 2>&1

    # Install acme.sh
    curl -s https://get.acme.sh | sh >> "$LOG_FILE" 2>&1

    if [[ ! -d "$ACME_DIR" ]]; then
        log_error "Instalasi acme.sh gagal!"
        exit 1
    fi

    # Set default CA ke Let's Encrypt
    "$ACME_DIR/acme.sh" --set-default-ca --server letsencrypt >> "$LOG_FILE" 2>&1

    log "acme.sh berhasil diinstall."
}

issue_ssl_certificate() {
    log "Menerbitkan SSL certificate untuk $DOMAIN..."

    # Stop Nginx sementara jika sedang berjalan (agar port 80 free)
    if systemctl is-active --quiet nginx 2>/dev/null; then
        systemctl stop nginx >> "$LOG_FILE" 2>&1
    fi

    local ssl_issued=false

    # Metode 1: Cloudflare DNS API (jika CF API Key tersedia)
    if [[ -n "$CF_API_KEY" ]]; then
        log "Mencoba menerbitkan SSL via Cloudflare DNS API..."
        export CF_Token="$CF_API_KEY"

        if "$ACME_DIR/acme.sh" --issue --dns dns_cf \
            -d "$DOMAIN" \
            --keylength ec-256 \
            --force >> "$LOG_FILE" 2>&1; then
            ssl_issued=true
            log "SSL certificate berhasil diterbitkan via Cloudflare DNS."
        else
            log_warn "Penerbitan SSL via Cloudflare DNS gagal. Mencoba mode standalone..."
        fi
    fi

    # Metode 2: Standalone HTTP (fallback)
    if [[ "$ssl_issued" != true ]]; then
        log "Mencoba menerbitkan SSL via standalone HTTP..."
        if "$ACME_DIR/acme.sh" --issue --standalone \
            -d "$DOMAIN" \
            --keylength ec-256 \
            --force >> "$LOG_FILE" 2>&1; then
            ssl_issued=true
            log "SSL certificate berhasil diterbitkan via standalone HTTP."
        else
            log_error "Penerbitan SSL certificate gagal!"
            log_error "Pastikan domain sudah diarahkan ke IP VPS dan port 80 tidak diblokir."
            exit 1
        fi
    fi

    # Install certificate ke lokasi Xray
    log "Menginstall SSL certificate ke $XRAY_CONFIG_DIR..."
    "$ACME_DIR/acme.sh" --install-cert -d "$DOMAIN" --ecc \
        --fullchain-file "$XRAY_CERT" \
        --key-file "$XRAY_KEY" \
        --reloadcmd "systemctl reload nginx 2>/dev/null; systemctl restart xray 2>/dev/null" \
        >> "$LOG_FILE" 2>&1

    # Set permissions
    chmod 644 "$XRAY_CERT"
    chmod 600 "$XRAY_KEY"

    log "SSL certificate berhasil diinstall."
    log "  Certificate: $XRAY_CERT"
    log "  Private Key: $XRAY_KEY"
}

# ============================================================================
# Nginx Installation & Configuration
# ============================================================================

install_nginx() {
    log "Menginstall Nginx..."

    export DEBIAN_FRONTEND=noninteractive

    if ! apt-get install -y nginx >> "$LOG_FILE" 2>&1; then
        log_error "Instalasi Nginx gagal!"
        exit 1
    fi

    # Pastikan nginx binary tersedia
    if ! command -v nginx &>/dev/null; then
        log_error "Nginx binary tidak ditemukan setelah instalasi!"
        exit 1
    fi

    log "Nginx berhasil diinstall: $(nginx -v 2>&1)"
}

configure_nginx() {
    log "Mengkonfigurasi Nginx reverse proxy..."

    # Backup konfigurasi default jika ada
    if [[ -f /etc/nginx/sites-enabled/default ]]; then
        rm -f /etc/nginx/sites-enabled/default
        log "Konfigurasi default Nginx dihapus."
    fi

    # Konfigurasi utama Nginx
    cat > /etc/nginx/nginx.conf <<'NGINX_MAIN'
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections 1024;
    multi_accept on;
}

http {
    # Basic Settings
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    server_tokens off;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    # SSL Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1d;
    ssl_session_tickets off;

    # Logging
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    # Gzip
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript;

    # Virtual Host Configs
    include /etc/nginx/conf.d/*.conf;
}
NGINX_MAIN
    log "Konfigurasi utama Nginx ditulis."

    # Konfigurasi reverse proxy Xray
    cat > "$NGINX_CONF" <<NGINX_XRAY
# ============================================================================
# Nginx Reverse Proxy Configuration — VPN Tunneling AutoScript
# Domain: $DOMAIN
# ============================================================================

# --- HTTPS Server (Port 443) ---
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $DOMAIN;

    ssl_certificate $XRAY_CERT;
    ssl_certificate_key $XRAY_KEY;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;

    # Root untuk fallback
    root /home/vps/public_html;
    index index.html index.htm;

    # --- VMess WebSocket TLS ---
    location /vmessws {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:$XRAY_WS_TLS_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # --- VLESS WebSocket TLS ---
    location /vlessws {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:$XRAY_WS_TLS_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # --- Trojan WebSocket TLS ---
    location /trojanws {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:$XRAY_WS_TLS_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # --- Shadowsocks WebSocket TLS ---
    location /ssws {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:$XRAY_WS_TLS_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # --- Socks WebSocket TLS ---
    location /socksws {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:$XRAY_WS_TLS_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # --- VMess HTTP Upgrade TLS ---
    location /vmess-httpupgrade {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:$XRAY_HTTPUPGRADE_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # --- VLESS HTTP Upgrade TLS ---
    location /vless-httpupgrade {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:$XRAY_HTTPUPGRADE_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # --- Trojan HTTP Upgrade TLS ---
    location /trojan-httpupgrade {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:$XRAY_HTTPUPGRADE_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # --- gRPC Services ---
    location ^~ /vmess-grpc {
        grpc_pass grpc://127.0.0.1:$XRAY_GRPC_PORT;
        grpc_set_header Host \$host;
        grpc_set_header X-Real-IP \$remote_addr;
    }

    location ^~ /vless-grpc {
        grpc_pass grpc://127.0.0.1:$XRAY_GRPC_PORT;
        grpc_set_header Host \$host;
        grpc_set_header X-Real-IP \$remote_addr;
    }

    location ^~ /trojan-grpc {
        grpc_pass grpc://127.0.0.1:$XRAY_GRPC_PORT;
        grpc_set_header Host \$host;
        grpc_set_header X-Real-IP \$remote_addr;
    }

    location ^~ /ss-grpc {
        grpc_pass grpc://127.0.0.1:$XRAY_GRPC_PORT;
        grpc_set_header Host \$host;
        grpc_set_header X-Real-IP \$remote_addr;
    }

    location ^~ /socks-grpc {
        grpc_pass grpc://127.0.0.1:$XRAY_GRPC_PORT;
        grpc_set_header Host \$host;
        grpc_set_header X-Real-IP \$remote_addr;
    }

    # --- SSH WebSocket ---
    location /ssh {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:$XRAY_WS_TLS_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # --- Trojan-Go WebSocket ---
    location /trojan-go {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:$XRAY_WS_TLS_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # --- Default location ---
    location / {
        try_files \$uri \$uri/ =404;
    }
}

# --- HTTP Server (Port 80) — Redirect & Non-TLS ---
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN;

    # --- VMess WebSocket Non-TLS ---
    location /vmessws {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:$XRAY_WS_NTLS_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # --- VLESS WebSocket Non-TLS ---
    location /vlessws {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:$XRAY_WS_NTLS_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # --- Trojan WebSocket Non-TLS ---
    location /trojanws {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:$XRAY_WS_NTLS_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # --- Shadowsocks WebSocket Non-TLS ---
    location /ssws {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:$XRAY_WS_NTLS_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # --- Socks WebSocket Non-TLS ---
    location /socksws {
        proxy_redirect off;
        proxy_pass http://127.0.0.1:$XRAY_WS_NTLS_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }

    # Default: redirect ke HTTPS
    location / {
        return 301 https://\$host\$request_uri;
    }
}

# --- Fallback Server (Port 663) ---
server {
    listen 663 ssl http2;
    listen [::]:663 ssl http2;
    server_name $DOMAIN;

    ssl_certificate $XRAY_CERT;
    ssl_certificate_key $XRAY_KEY;

    root /home/vps/public_html;
    index index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }
}

# --- Alt HTTP Server (Port 81) ---
server {
    listen 81;
    listen [::]:81;
    server_name $DOMAIN;

    root /home/vps/public_html;
    index index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
NGINX_XRAY
    log "Konfigurasi Nginx reverse proxy ditulis ke $NGINX_CONF"

    # Buat halaman default
    if [[ ! -f /home/vps/public_html/index.html ]]; then
        cat > /home/vps/public_html/index.html <<'INDEX_HTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VPN Tunneling AutoScript</title>
    <style>
        body { font-family: 'Segoe UI', sans-serif; background: #0d1117; color: #c9d1d9; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; }
        .container { text-align: center; }
        h1 { color: #58a6ff; }
        p { color: #8b949e; }
    </style>
</head>
<body>
    <div class="container">
        <h1>⚡ VPN Tunneling AutoScript</h1>
        <p>Server is running.</p>
    </div>
</body>
</html>
INDEX_HTML
        log "Halaman default index.html dibuat."
    fi

    # Test konfigurasi Nginx
    if nginx -t >> "$LOG_FILE" 2>&1; then
        log "Konfigurasi Nginx valid."
    else
        log_warn "Konfigurasi Nginx memiliki error. Periksa log."
    fi
}

start_nginx() {
    log "Memulai Nginx..."

    systemctl enable nginx >> "$LOG_FILE" 2>&1
    systemctl restart nginx >> "$LOG_FILE" 2>&1

    if systemctl is-active --quiet nginx; then
        log "Nginx berhasil dijalankan."
    else
        log_warn "Nginx gagal dijalankan. Periksa konfigurasi dan log."
    fi
}

# ============================================================================
# Xray-core Installation
# ============================================================================

install_xray() {
    log "Menginstall Xray-core..."

    # Download dan install menggunakan official script
    if ! bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install >> "$LOG_FILE" 2>&1; then
        log_warn "Instalasi Xray via official script gagal. Mencoba download manual..."

        # Fallback: download manual dari GitHub releases
        local xray_version
        if command -v jq &>/dev/null; then
            xray_version=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | jq -r '.tag_name // empty' 2>/dev/null)
        else
            xray_version=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
        fi

        if [[ -z "$xray_version" ]]; then
            log_error "Tidak dapat mendeteksi versi Xray terbaru!"
            exit 1
        fi

        log "Mendownload Xray-core $xray_version..."

        local xray_url="https://github.com/XTLS/Xray-core/releases/download/$xray_version/Xray-linux-64.zip"
        local xray_tmp="/tmp/xray-install"

        mkdir -p "$xray_tmp"

        if ! wget --inet4-only --no-check-certificate -O "$xray_tmp/xray.zip" "$xray_url" >> "$LOG_FILE" 2>&1; then
            log_error "Download Xray-core gagal!"
            exit 1
        fi

        # Extract
        apt-get install -y unzip >> "$LOG_FILE" 2>&1
        unzip -o "$xray_tmp/xray.zip" -d "$xray_tmp" >> "$LOG_FILE" 2>&1

        # Install binary
        install -m 755 "$xray_tmp/xray" "$XRAY_INSTALL_DIR/xray"
        mkdir -p /usr/local/share/xray
        install -m 644 "$xray_tmp/geoip.dat" /usr/local/share/xray/geoip.dat 2>/dev/null
        install -m 644 "$xray_tmp/geosite.dat" /usr/local/share/xray/geosite.dat 2>/dev/null

        # Cleanup
        rm -rf "$xray_tmp"
    fi

    # Verifikasi instalasi
    if command -v xray &>/dev/null; then
        log "Xray-core berhasil diinstall: $(xray version 2>/dev/null | head -1)"
    elif [[ -f "$XRAY_INSTALL_DIR/xray" ]]; then
        log "Xray-core berhasil diinstall: $($XRAY_INSTALL_DIR/xray version 2>/dev/null | head -1)"
    else
        log_error "Xray binary tidak ditemukan setelah instalasi!"
        exit 1
    fi
}

create_xray_config() {
    log "Membuat konfigurasi dasar Xray-core..."

    # Buat config.json utama Xray
    cat > "$XRAY_CONFIG_FILE" <<XRAY_CONFIG
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "api": {
    "tag": "api",
    "services": [
      "StatsService"
    ]
  },
  "stats": {},
  "policy": {
    "levels": {
      "0": {
        "statsUserUplink": true,
        "statsUserDownlink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true,
      "statsOutboundUplink": true,
      "statsOutboundDownlink": true
    }
  },
  "inbounds": [
    {
      "tag": "vmess-ws-tls",
      "listen": "127.0.0.1",
      "port": $XRAY_WS_TLS_PORT,
      "protocol": "vmess",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vmessws"
        }
      }
    },
    {
      "tag": "vless-ws-tls",
      "listen": "127.0.0.1",
      "port": $XRAY_WS_TLS_PORT,
      "protocol": "vless",
      "settings": {
        "clients": [],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vlessws"
        }
      }
    },
    {
      "tag": "trojan-ws-tls",
      "listen": "127.0.0.1",
      "port": $XRAY_WS_TLS_PORT,
      "protocol": "trojan",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/trojanws"
        }
      }
    },
    {
      "tag": "shadowsocks-ws-tls",
      "listen": "127.0.0.1",
      "port": $XRAY_WS_TLS_PORT,
      "protocol": "shadowsocks",
      "settings": {
        "clients": [],
        "network": "tcp,udp"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/ssws"
        }
      }
    },
    {
      "tag": "socks-ws-tls",
      "listen": "127.0.0.1",
      "port": $XRAY_WS_TLS_PORT,
      "protocol": "socks",
      "settings": {
        "auth": "password",
        "accounts": [],
        "udp": true
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/socksws"
        }
      }
    },
    {
      "tag": "vmess-ws-ntls",
      "listen": "127.0.0.1",
      "port": $XRAY_WS_NTLS_PORT,
      "protocol": "vmess",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vmessws"
        }
      }
    },
    {
      "tag": "vless-ws-ntls",
      "listen": "127.0.0.1",
      "port": $XRAY_WS_NTLS_PORT,
      "protocol": "vless",
      "settings": {
        "clients": [],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vlessws"
        }
      }
    },
    {
      "tag": "trojan-ws-ntls",
      "listen": "127.0.0.1",
      "port": $XRAY_WS_NTLS_PORT,
      "protocol": "trojan",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/trojanws"
        }
      }
    },
    {
      "tag": "shadowsocks-ws-ntls",
      "listen": "127.0.0.1",
      "port": $XRAY_WS_NTLS_PORT,
      "protocol": "shadowsocks",
      "settings": {
        "clients": [],
        "network": "tcp,udp"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/ssws"
        }
      }
    },
    {
      "tag": "socks-ws-ntls",
      "listen": "127.0.0.1",
      "port": $XRAY_WS_NTLS_PORT,
      "protocol": "socks",
      "settings": {
        "auth": "password",
        "accounts": [],
        "udp": true
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/socksws"
        }
      }
    },
    {
      "tag": "vmess-grpc",
      "listen": "127.0.0.1",
      "port": $XRAY_GRPC_PORT,
      "protocol": "vmess",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "vmess-grpc"
        }
      }
    },
    {
      "tag": "vless-grpc",
      "listen": "127.0.0.1",
      "port": $XRAY_GRPC_PORT,
      "protocol": "vless",
      "settings": {
        "clients": [],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "vless-grpc"
        }
      }
    },
    {
      "tag": "trojan-grpc",
      "listen": "127.0.0.1",
      "port": $XRAY_GRPC_PORT,
      "protocol": "trojan",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "trojan-grpc"
        }
      }
    },
    {
      "tag": "ss-grpc",
      "listen": "127.0.0.1",
      "port": $XRAY_GRPC_PORT,
      "protocol": "shadowsocks",
      "settings": {
        "clients": [],
        "network": "tcp,udp"
      },
      "streamSettings": {
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "ss-grpc"
        }
      }
    },
    {
      "tag": "socks-grpc",
      "listen": "127.0.0.1",
      "port": $XRAY_GRPC_PORT,
      "protocol": "socks",
      "settings": {
        "auth": "password",
        "accounts": [],
        "udp": true
      },
      "streamSettings": {
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "socks-grpc"
        }
      }
    },
    {
      "tag": "vmess-httpupgrade",
      "listen": "127.0.0.1",
      "port": $XRAY_HTTPUPGRADE_PORT,
      "protocol": "vmess",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "httpupgrade",
        "httpupgradeSettings": {
          "path": "/vmess-httpupgrade"
        }
      }
    },
    {
      "tag": "vless-httpupgrade",
      "listen": "127.0.0.1",
      "port": $XRAY_HTTPUPGRADE_PORT,
      "protocol": "vless",
      "settings": {
        "clients": [],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "httpupgrade",
        "httpupgradeSettings": {
          "path": "/vless-httpupgrade"
        }
      }
    },
    {
      "tag": "trojan-httpupgrade",
      "listen": "127.0.0.1",
      "port": $XRAY_HTTPUPGRADE_PORT,
      "protocol": "trojan",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "httpupgrade",
        "httpupgradeSettings": {
          "path": "/trojan-httpupgrade"
        }
      }
    }
  ],
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {}
    },
    {
      "tag": "blocked",
      "protocol": "blackhole",
      "settings": {}
    }
  ],
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "type": "field",
        "inboundTag": [
          "api"
        ],
        "outboundTag": "api"
      },
      {
        "type": "field",
        "protocol": [
          "bittorrent"
        ],
        "outboundTag": "blocked"
      }
    ]
  }
}
XRAY_CONFIG

    log "Konfigurasi Xray-core ditulis ke $XRAY_CONFIG_FILE"

    # Buat direktori log Xray
    mkdir -p /var/log/xray
    log "Direktori log Xray dibuat: /var/log/xray"
}

create_xray_service() {
    log "Membuat systemd service untuk Xray-core..."

    # Cek apakah service sudah dibuat oleh installer resmi
    if [[ -f /etc/systemd/system/xray.service ]]; then
        log "Service Xray sudah ada (dari installer resmi)."
        return
    fi

    cat > /etc/systemd/system/xray.service <<'XRAY_SERVICE'
[Unit]
Description=Xray Service
Documentation=https://github.com/XTLS/Xray-core
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
XRAY_SERVICE

    systemctl daemon-reload >> "$LOG_FILE" 2>&1
    log "Systemd service Xray-core dibuat."
}

start_xray() {
    log "Memulai Xray-core..."

    systemctl enable xray >> "$LOG_FILE" 2>&1
    systemctl restart xray >> "$LOG_FILE" 2>&1

    if systemctl is-active --quiet xray; then
        log "Xray-core berhasil dijalankan."
    else
        log_warn "Xray-core gagal dijalankan. Periksa konfigurasi dan log."
    fi
}

# ============================================================================
# Main
# ============================================================================

main() {
    # Inisialisasi log (append ke log sebelumnya)
    {
        echo ""
        echo "=== VPN Tunneling AutoScript — Tahap 3 ==="
        echo "Waktu mulai: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "============================================"
    } >> "$LOG_FILE"

    print_header

    # Pengecekan prasyarat
    log "Memulai pengecekan prasyarat..."
    check_root
    check_os
    check_arch
    check_virt
    check_domain_input
    check_dependencies
    log "Semua pengecekan prasyarat berhasil."

    echo ""
    echo -e "${BLUE}Semua prasyarat terpenuhi. Memulai setup Tahap 3...${NC}"
    echo ""

    # 1. Setup domain
    setup_domain
    validate_domain_dns

    # 2. Cloudflare domain pointing (opsional)
    setup_cloudflare_domain

    # 3. Install dan konfigurasi Nginx
    install_nginx
    configure_nginx

    # 4. Install acme.sh dan SSL certificate
    install_acme
    issue_ssl_certificate

    # 5. Start Nginx
    start_nginx

    # 6. Install Xray-core
    install_xray
    create_xray_config
    create_xray_service
    start_xray

    # Selesai
    echo ""
    echo -e "${GREEN}=============================================="
    echo "  Tahap 3 selesai!"
    echo ""
    echo "  Domain       : $DOMAIN"
    echo "  SSL Cert     : $XRAY_CERT"
    echo "  SSL Key      : $XRAY_KEY"
    echo "  Nginx Config : $NGINX_CONF"
    echo "  Xray Config  : $XRAY_CONFIG_FILE"
    echo ""
    echo "  Nginx Status : $(systemctl is-active nginx 2>/dev/null || echo 'unknown')"
    echo "  Xray Status  : $(systemctl is-active xray 2>/dev/null || echo 'unknown')"
    echo ""
    echo "  Ports:"
    echo "    HTTPS  : 443"
    echo "    HTTP   : 80"
    echo "    Alt    : 81"
    echo "    Fallbk : 663"
    echo ""
    echo "  Sistem siap untuk instalasi komponen tambahan."
    echo -e "==============================================${NC}"
    echo ""

    log "Tahap 3 selesai. Domain, SSL, Nginx, dan Xray-core berhasil diinstall."
}

main "$@"
