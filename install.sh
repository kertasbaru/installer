#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript Installer — Tahap 2: Install Dependencies & Setup
# ============================================================================
# Script ini melakukan instalasi dependencies, disable IPv6, setup direktori,
# dan konfigurasi awal untuk VPN Tunneling.
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
#   - Tahap 1 (setup.sh) sudah dijalankan
#
# Penggunaan:
#   chmod +x install.sh
#   ./install.sh                  # Tanpa Cloudflare API Key
#   ./install.sh "CFAPIKEY"       # Dengan Cloudflare API Key
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

# Cloudflare API Key (opsional, dari argumen pertama)
CF_API_KEY="${1:-}"

# Daftar dependencies yang dibutuhkan
DEPENDENCIES=(
    whois
    bzip2
    gzip
    coreutils
    wget
    screen
    nscd
    curl
    tmux
    gnupg
    perl
    dnsutils
)

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
    echo "  Tahap 2: Install Dependencies & Setup"
    echo "=============================================="
    echo -e "${NC}"
}

# ============================================================================
# Pengecekan Prasyarat
# ============================================================================

check_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        log_error "Script ini harus dijalankan sebagai root!"
        echo -e "${RED}Gunakan: sudo ./install.sh${NC}"
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

# ============================================================================
# Disable IPv6
# ============================================================================

disable_ipv6() {
    log "Menonaktifkan IPv6..."

    if ! sysctl -w net.ipv6.conf.all.disable_ipv6=1 >> "$LOG_FILE" 2>&1; then
        log_warn "Gagal menonaktifkan IPv6 (all). Melanjutkan..."
    fi

    if ! sysctl -w net.ipv6.conf.default.disable_ipv6=1 >> "$LOG_FILE" 2>&1; then
        log_warn "Gagal menonaktifkan IPv6 (default). Melanjutkan..."
    fi

    # Persist setting agar tetap aktif setelah reboot
    local sysctl_conf="/etc/sysctl.d/99-disable-ipv6.conf"
    cat > "$sysctl_conf" <<EOF
# Disable IPv6 — VPN Tunneling AutoScript
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
EOF

    log "IPv6 berhasil dinonaktifkan."
}

# ============================================================================
# Install Dependencies
# ============================================================================

install_dependencies() {
    log "Memulai instalasi dependencies..."

    # Set non-interactive mode
    export DEBIAN_FRONTEND=noninteractive

    # Update package list
    log "Menjalankan apt-get update..."
    if ! apt-get update >> "$LOG_FILE" 2>&1; then
        log_error "apt-get update gagal! Periksa koneksi internet dan repository."
        exit 1
    fi
    log "apt-get update selesai."

    # Install semua dependencies
    local dep_list
    dep_list="${DEPENDENCIES[*]}"
    log "Menginstall dependencies: $dep_list"

    # shellcheck disable=SC2068
    if ! apt-get --reinstall --fix-missing install -y ${DEPENDENCIES[@]} >> "$LOG_FILE" 2>&1; then
        log_error "Instalasi dependencies gagal!"
        exit 1
    fi

    log "Semua dependencies berhasil diinstall."

    # Verifikasi dependencies kritis
    local failed=false
    for dep in wget curl screen tmux; do
        if ! command -v "$dep" &>/dev/null; then
            log_error "Dependency kritis tidak ditemukan setelah install: $dep"
            failed=true
        fi
    done

    if [[ "$failed" == true ]]; then
        log_error "Beberapa dependencies kritis gagal diinstall. Periksa log."
        exit 1
    fi

    log "Verifikasi dependencies kritis: OK"
}

# ============================================================================
# Setup Timezone
# ============================================================================

setup_timezone() {
    local tz="Asia/Jakarta"
    log "Mengatur timezone ke $tz..."

    if command -v timedatectl &>/dev/null; then
        timedatectl set-timezone "$tz" >> "$LOG_FILE" 2>&1
    else
        ln -sf "/usr/share/zoneinfo/$tz" /etc/localtime
        echo "$tz" > /etc/timezone
    fi

    log "Timezone diatur ke $tz — OK"
}

# ============================================================================
# Setup Struktur Direktori
# ============================================================================

setup_directories() {
    log "Membuat struktur direktori..."

    # Direktori konfigurasi utama (/etc/)
    local config_dirs=(
        /etc/xray
        /etc/hysteria2
        /etc/trojan-go
        /etc/nginx/conf.d
        /etc/haproxy
        /etc/openvpn
        /etc/softether
        /etc/stunnel
        /etc/squid
        /etc/fail2ban
        /etc/warp
        /etc/cron.d
        /etc/vnstat
    )

    for dir in "${config_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            log "Direktori dibuat: $dir"
        fi
    done

    # Direktori data akun & backup (/home/vps/)
    mkdir -p /home/vps/public_html
    mkdir -p /home/vps/backup
    log "Direktori dibuat: /home/vps/public_html"
    log "Direktori dibuat: /home/vps/backup"

    # Direktori Rclone config
    mkdir -p ~/.config/rclone
    log "Direktori dibuat: ~/.config/rclone"

    log "Struktur direktori berhasil dibuat."
}

# ============================================================================
# Setup Cloudflare API Key (Opsional)
# ============================================================================

setup_cloudflare() {
    if [[ -z "$CF_API_KEY" ]]; then
        log "Cloudflare API Key tidak diberikan. Melewati setup Cloudflare."
        return
    fi

    log "Menyimpan Cloudflare API Key..."

    # Simpan API Key ke file konfigurasi
    echo "$CF_API_KEY" > /etc/xray/cloudflare
    chmod 600 /etc/xray/cloudflare

    log "Cloudflare API Key berhasil disimpan ke /etc/xray/cloudflare"
}

# ============================================================================
# Setup Domain File
# ============================================================================

setup_domain_file() {
    # Buat file domain kosong jika belum ada
    if [[ ! -f /etc/xray/domain ]]; then
        touch /etc/xray/domain
        log "File domain dibuat: /etc/xray/domain"
    fi
}

# ============================================================================
# Main
# ============================================================================

main() {
    # Inisialisasi log (append ke log yang sudah ada dari Tahap 1)
    {
        echo ""
        echo "=== VPN Tunneling AutoScript — Tahap 2 ==="
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
    log "Semua pengecekan prasyarat berhasil."

    echo ""
    echo -e "${BLUE}Semua prasyarat terpenuhi. Memulai instalasi Tahap 2...${NC}"
    echo ""

    # Disable IPv6
    disable_ipv6

    # Install dependencies
    install_dependencies

    # Setup timezone
    setup_timezone

    # Setup struktur direktori
    setup_directories

    # Setup Cloudflare API Key (jika diberikan)
    setup_cloudflare

    # Setup domain file
    setup_domain_file

    # Selesai
    echo ""
    echo -e "${GREEN}=============================================="
    echo "  Tahap 2 selesai!"
    echo ""
    echo "  Dependencies berhasil diinstall."
    echo "  Struktur direktori berhasil dibuat."
    echo "  IPv6 berhasil dinonaktifkan."
    if [[ -n "$CF_API_KEY" ]]; then
        echo "  Cloudflare API Key berhasil disimpan."
    fi
    echo ""
    echo "  Sistem siap untuk instalasi komponen VPN."
    echo -e "==============================================${NC}"
    echo ""

    log "Tahap 2 selesai. Sistem siap untuk instalasi komponen VPN."
}

main "$@"
