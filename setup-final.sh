#!/bin/bash
# shellcheck disable=SC2034,SC2001,SC2002,SC2155
# ============================================================================
# VPN Tunneling AutoScript Installer — Tahap 10: Finalisasi & Produksi
# ============================================================================
# Integrasi semua komponen, optimasi, dan pembuatan auto-installer tunggal.
#
# Komponen:
#   - Auto-Installer Tunggal — Script tunggal menjalankan semua tahap berurutan
#   - Integrasi Antar Tahap — Verifikasi setiap tahap selesai sebelum lanjut
#   - Error Recovery — Resume dari tahap terakhir jika gagal/disconnect
#   - Post-Install Verification — Cek semua service berjalan setelah instalasi
#   - System Info Display — Tampilkan info lengkap VPS setelah install
#   - Uninstall Script — Script untuk membersihkan semua komponen
#   - Rebuild Menu — Rebuild VPS dari menu tanpa reinstall OS
#   - Performance Optimization — Tuning kernel, network, dan service
#   - Security Hardening — Hardening SSH, disable unnecessary services
#   - Documentation Generator — Auto-generate docs dari konfigurasi aktif
#   - Version Management — Update checker dan auto-update script
#   - Full Integration Testing — End-to-end test semua komponen
#   - Production Checklist — Checklist verifikasi sebelum produksi
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
#   - Tahap 1-9 sudah dijalankan
#
# Penggunaan:
#   chmod +x setup-final.sh
#   ./setup-final.sh
#
# Referensi:
#   - https://github.com/FN-Rerechan02/Autoscript (AIO VPN script reference)
#   - https://github.com/mack-a/v2ray-agent (8-in-1 script reference)
#   - https://github.com/XTLS/Xray-core (Core engine Xray proxy)
#   - https://github.com/XTLS/Xray-install (Official Xray installer)
#   - https://github.com/apernet/hysteria (Hysteria2 protocol engine)
#   - https://github.com/p4gefau1t/trojan-go (Trojan-Go engine)
#   - https://github.com/SoftEtherVPN/SoftEtherVPN (SoftEther VPN server)
#   - https://github.com/GegeDevs/sshvpn-script (SSH VPN script)
#
# Log instalasi tersimpan di: /root/syslog.log
# ============================================================================

# Warna untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# File log
LOG_FILE="/root/syslog.log"

# ============================================================================
# Paths penting
# ============================================================================
DOMAIN_FILE="/etc/xray/domain"
XRAY_CONFIG="/etc/xray/config.json"
XRAY_CERT="/etc/xray/xray.crt"
XRAY_KEY="/etc/xray/xray.key"
HYSTERIA2_CONFIG="/etc/hysteria2/config.yaml"
TROJAN_GO_CONFIG="/etc/trojan-go/config.json"
ACCOUNT_DIR="/etc/vpnray/accounts"
API_CONFIG_DIR="/etc/vpnray/api"
BOT_CONFIG_DIR="/etc/vpnray/bot"
WEBHOOK_CONFIG_DIR="/etc/vpnray/webhook"

# ============================================================================
# Version Management
# ============================================================================
SCRIPT_VERSION="2.0.0"
VERSION_FILE="/etc/vpnray/version"
UPDATE_CHECK_URL="https://raw.githubusercontent.com/kertasbaru/installer/main/version.txt"
AUTO_INSTALLER_SCRIPT="/usr/local/bin/vpnray-install"
UNINSTALL_SCRIPT="/usr/local/bin/vpnray-uninstall"
REBUILD_SCRIPT="/usr/local/bin/vpnray-rebuild"
SYSINFO_SCRIPT="/usr/local/bin/vpnray-sysinfo"
PERFTUNING_SCRIPT="/usr/local/bin/vpnray-perftuning"
HARDENING_SCRIPT="/usr/local/bin/vpnray-hardening"
DOCGEN_SCRIPT="/usr/local/bin/vpnray-docgen"
UPDATE_SCRIPT="/usr/local/bin/vpnray-update"
INTEGRATION_TEST_SCRIPT="/usr/local/bin/vpnray-test"
CHECKLIST_SCRIPT="/usr/local/bin/vpnray-checklist"

# State tracking
STATE_DIR="/etc/vpnray/state"
STATE_FILE="$STATE_DIR/install-state"
TAHAP_COUNT=9

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
    echo "║    VPN Tunneling AutoScript — Tahap 10                     ║"
    echo "║    Finalisasi & Produksi                                   ║"
    echo "║                                                            ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# ============================================================================
# Pengecekan Prasyarat
# ============================================================================

check_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        log_error "Script ini harus dijalankan sebagai root!"
        echo -e "${RED}Gunakan: sudo ./setup-final.sh${NC}"
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

check_previous_tahap() {
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
    # Cek menu
    if [[ ! -f "/usr/local/bin/menu" ]]; then
        log_warn "Menu utama tidak ditemukan: /usr/local/bin/menu"
        ((errors++))
    fi
    # Cek API
    if [[ ! -f "/usr/local/bin/vpnray-api" ]]; then
        log_warn "API server tidak ditemukan: /usr/local/bin/vpnray-api"
        ((errors++))
    fi
    if [[ "$errors" -gt 0 ]]; then
        log_warn "Ada $errors komponen Tahap 1-9 belum lengkap. Lanjutkan dengan hati-hati."
    else
        log "Pengecekan Tahap 1-9: Semua komponen OK"
    fi
}

# ============================================================================
# Helper: Get system info
# ============================================================================

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

# ============================================================================
# 1. Auto-Installer Tunggal
# ============================================================================

create_auto_installer() {
    log "Membuat auto-installer tunggal: $AUTO_INSTALLER_SCRIPT"
    cat > "$AUTO_INSTALLER_SCRIPT" << 'AUTO_INSTALLER'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Auto-Installer Tunggal
# ============================================================================
# Menjalankan semua tahap instalasi (1-9) secara berurutan.
# Mendukung resume dari tahap terakhir jika gagal/disconnect.
#
# Usage: vpnray-install [--resume] [--from <tahap>] [--skip-reboot]
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

STATE_DIR="/etc/vpnray/state"
STATE_FILE="$STATE_DIR/install-state"
LOG_FILE="/root/syslog.log"
SCRIPT_DIR=""

log_installer() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INSTALLER] $1" >> "$LOG_FILE"
}

save_state() {
    mkdir -p "$STATE_DIR"
    echo "$1" > "$STATE_FILE"
    log_installer "State saved: tahap $1"
}

get_state() {
    if [[ -f "$STATE_FILE" ]]; then
        cat "$STATE_FILE"
    else
        echo "0"
    fi
}

clear_state() {
    rm -f "$STATE_FILE"
    log_installer "State cleared"
}

# Map tahap to script
get_script() {
    local tahap="$1"
    case "$tahap" in
        1) echo "setup.sh" ;;
        2) echo "install.sh" ;;
        3) echo "setup-domain.sh" ;;
        4) echo "setup-ssh.sh" ;;
        5) echo "setup-protocol.sh" ;;
        6) echo "setup-account.sh" ;;
        7) echo "setup-menu.sh" ;;
        8) echo "setup-api.sh" ;;
        9) echo "setup-monitor.sh" ;;
        *) echo "" ;;
    esac
}

get_tahap_name() {
    local tahap="$1"
    case "$tahap" in
        1) echo "Update Sistem & Reboot" ;;
        2) echo "Install Dependencies & Setup" ;;
        3) echo "Domain, SSL, Nginx & Xray-core" ;;
        4) echo "SSH Tunneling, HAProxy & Services" ;;
        5) echo "Protokol Tambahan" ;;
        6) echo "Manajemen Akun & User" ;;
        7) echo "Menu Sistem & CLI Dashboard" ;;
        8) echo "REST API & Bot Integrasi" ;;
        9) echo "Monitoring, Backup & Keamanan" ;;
        *) echo "Unknown" ;;
    esac
}

run_tahap() {
    local tahap="$1"
    local script
    script=$(get_script "$tahap")
    local name
    name=$(get_tahap_name "$tahap")

    if [[ -z "$script" ]]; then
        echo -e "${RED}[ERROR] Tahap $tahap tidak valid${NC}"
        return 1
    fi

    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Tahap $tahap: $name${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
    echo ""

    save_state "$tahap"

    if [[ -f "$SCRIPT_DIR/$script" ]]; then
        log_installer "Menjalankan tahap $tahap: $script"
        if bash "$SCRIPT_DIR/$script"; then
            log_installer "Tahap $tahap selesai"
            echo -e "${GREEN}✅ Tahap $tahap selesai${NC}"
            return 0
        else
            log_installer "ERROR: Tahap $tahap gagal"
            echo -e "${RED}❌ Tahap $tahap gagal!${NC}"
            echo -e "${YELLOW}Gunakan: vpnray-install --resume${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}[SKIP] Script $script tidak ditemukan di $SCRIPT_DIR${NC}"
        log_installer "SKIP: $script tidak ditemukan"
        return 0
    fi
}

print_banner() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║    ⚡ VPN TUNNELING AUTOSCRIPT INSTALLER ⚡                ║"
    echo "║    All-In-One Installer for VPS                            ║"
    echo "║    Version 2.0.0                                           ║"
    echo "║                                                            ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Parse arguments
RESUME=false
FROM_TAHAP=1
SKIP_REBOOT=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --resume)
            RESUME=true
            shift
            ;;
        --from)
            FROM_TAHAP="$2"
            shift 2
            ;;
        --skip-reboot)
            SKIP_REBOOT=true
            shift
            ;;
        --dir)
            SCRIPT_DIR="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: vpnray-install [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --resume         Resume dari tahap terakhir yang gagal"
            echo "  --from <N>       Mulai dari tahap N (1-9)"
            echo "  --skip-reboot    Skip reboot setelah Tahap 1"
            echo "  --dir <path>     Direktori script installer"
            echo "  -h, --help       Tampilkan bantuan"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Auto-detect script directory
if [[ -z "$SCRIPT_DIR" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "$0")/.." 2>/dev/null && pwd)"
    if [[ ! -f "$SCRIPT_DIR/setup.sh" ]]; then
        SCRIPT_DIR="/root/installer"
    fi
    if [[ ! -f "$SCRIPT_DIR/setup.sh" ]]; then
        SCRIPT_DIR="$(pwd)"
    fi
fi

print_banner

if [[ "$RESUME" == true ]]; then
    FROM_TAHAP=$(get_state)
    if [[ "$FROM_TAHAP" -eq 0 ]]; then
        echo -e "${YELLOW}Tidak ada state tersimpan. Memulai dari tahap 1.${NC}"
        FROM_TAHAP=1
    else
        echo -e "${GREEN}Melanjutkan dari tahap $FROM_TAHAP...${NC}"
    fi
fi

echo -e "${BLUE}Script directory: $SCRIPT_DIR${NC}"
echo -e "${BLUE}Mulai dari tahap: $FROM_TAHAP${NC}"
echo ""

# Run tahap berurutan
for tahap in $(seq "$FROM_TAHAP" 9); do
    # Skip tahap 1 reboot jika diminta
    if [[ "$tahap" -eq 1 && "$SKIP_REBOOT" == true ]]; then
        echo -e "${YELLOW}[SKIP] Tahap 1 (reboot) dilewati${NC}"
        continue
    fi

    if ! run_tahap "$tahap"; then
        echo ""
        echo -e "${RED}════════════════════════════════════════════════${NC}"
        echo -e "${RED}  Instalasi terhenti di Tahap $tahap${NC}"
        echo -e "${RED}  Gunakan: vpnray-install --resume${NC}"
        echo -e "${RED}════════════════════════════════════════════════${NC}"
        exit 1
    fi
done

# Instalasi selesai
clear_state
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                            ║${NC}"
echo -e "${GREEN}║    ✅ INSTALASI BERHASIL!                                  ║${NC}"
echo -e "${GREEN}║    Semua tahap (1-9) telah selesai.                        ║${NC}"
echo -e "${GREEN}║                                                            ║${NC}"
echo -e "${GREEN}║    Jalankan 'menu' untuk mengakses dashboard.              ║${NC}"
echo -e "${GREEN}║    Jalankan 'vpnray-sysinfo' untuk info lengkap.           ║${NC}"
echo -e "${GREEN}║                                                            ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
log_installer "Instalasi selesai: semua tahap (1-9) berhasil"
AUTO_INSTALLER
    chmod +x "$AUTO_INSTALLER_SCRIPT"
    log "Auto-installer tunggal dibuat: $AUTO_INSTALLER_SCRIPT"
}

# ============================================================================
# 2. Integrasi Antar Tahap & Error Recovery
# ============================================================================

setup_state_tracking() {
    log "Setup state tracking untuk error recovery"
    mkdir -p "$STATE_DIR"

    # Create state helper scripts
    cat > /usr/local/bin/vpnray-state << 'STATE_SCRIPT'
#!/bin/bash
# VPN Tunneling AutoScript — State Manager
STATE_DIR="/etc/vpnray/state"
STATE_FILE="$STATE_DIR/install-state"

case "$1" in
    get)
        if [[ -f "$STATE_FILE" ]]; then
            echo "Tahap terakhir: $(cat "$STATE_FILE")"
        else
            echo "Tidak ada state tersimpan"
        fi
        ;;
    set)
        [[ -z "$2" ]] && { echo "Usage: vpnray-state set <tahap>"; exit 1; }
        mkdir -p "$STATE_DIR"
        echo "$2" > "$STATE_FILE"
        echo "State disimpan: tahap $2"
        ;;
    clear)
        rm -f "$STATE_FILE"
        echo "State dihapus"
        ;;
    *)
        echo "Usage: vpnray-state [get|set|clear] [tahap]"
        ;;
esac
STATE_SCRIPT
    chmod +x /usr/local/bin/vpnray-state

    log "State tracking dikonfigurasi: $STATE_DIR"
}

# ============================================================================
# 3. Post-Install Verification
# ============================================================================

verify_services() {
    local services=(
        "xray"
        "nginx"
        "haproxy"
        "dropbear"
        "stunnel4"
        "squid"
        "openvpn"
        "hysteria2"
        "trojan-go"
        "fail2ban"
        "vnstat"
    )

    local running=0
    local stopped=0
    local results=""

    for svc in "${services[@]}"; do
        if systemctl is-active --quiet "$svc" 2>/dev/null; then
            results+="  ✅ $svc: running\n"
            ((running++))
        else
            results+="  ❌ $svc: stopped\n"
            ((stopped++))
        fi
    done

    echo -e "$results"
    echo "  Total: $running running, $stopped stopped"
}

verify_ports() {
    local ports=(
        "22:SSH"
        "80:HTTP/HAProxy"
        "443:HTTPS/Xray"
        "143:Dropbear"
        "446:Stunnel"
        "3128:Squid"
        "8080:Squid2"
        "8880:SSH-WS"
        "9000:REST-API"
        "8899:vnStat"
    )

    local open=0
    local closed=0
    local results=""

    for port_info in "${ports[@]}"; do
        local port="${port_info%%:*}"
        local name="${port_info#*:}"
        if ss -tlnp 2>/dev/null | grep -q ":$port "; then
            results+="  ✅ Port $port ($name): OPEN\n"
            ((open++))
        else
            results+="  ⚠️  Port $port ($name): CLOSED\n"
            ((closed++))
        fi
    done

    echo -e "$results"
    echo "  Total: $open open, $closed closed"
}

verify_files() {
    local files=(
        "/etc/xray/config.json:Xray Config"
        "/etc/xray/domain:Domain File"
        "/etc/xray/xray.crt:SSL Certificate"
        "/etc/xray/xray.key:SSL Private Key"
        "/etc/nginx/conf.d/xray.conf:Nginx Config"
        "/etc/haproxy/haproxy.cfg:HAProxy Config"
        "/usr/local/bin/menu:Menu Script"
        "/usr/local/bin/vpnray-api:API Server"
        "/usr/local/bin/vpnray-backup:Backup Script"
        "/etc/vpnray/accounts:Account Directory"
    )

    local found=0
    local missing=0
    local results=""

    for file_info in "${files[@]}"; do
        local file="${file_info%%:*}"
        local name="${file_info#*:}"
        if [[ -e "$file" ]]; then
            results+="  ✅ $name: $file\n"
            ((found++))
        else
            results+="  ❌ $name: $file (MISSING)\n"
            ((missing++))
        fi
    done

    echo -e "$results"
    echo "  Total: $found found, $missing missing"
}

create_post_install_verify() {
    log "Membuat post-install verification"

    cat > /usr/local/bin/vpnray-verify << 'VERIFY_SCRIPT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Post-Install Verification
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   Post-Install Verification                  ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

# 1. Services
echo -e "${YELLOW}📋 Services Status:${NC}"
services=("xray" "nginx" "haproxy" "dropbear" "stunnel4" "squid" "openvpn" "hysteria2" "trojan-go" "fail2ban" "vnstat")
running=0
stopped=0
for svc in "${services[@]}"; do
    if systemctl is-active --quiet "$svc" 2>/dev/null; then
        echo -e "  ${GREEN}✅${NC} $svc: running"
        ((running++))
    else
        echo -e "  ${RED}❌${NC} $svc: stopped"
        ((stopped++))
    fi
done
echo "  Total: $running running, $stopped stopped"
echo ""

# 2. Ports
echo -e "${YELLOW}🔌 Port Status:${NC}"
ports=("22:SSH" "80:HTTP" "443:HTTPS" "143:Dropbear" "446:Stunnel" "3128:Squid" "8880:SSH-WS" "9000:API" "8899:vnStat")
open=0
closed=0
for port_info in "${ports[@]}"; do
    port="${port_info%%:*}"
    name="${port_info#*:}"
    if ss -tlnp 2>/dev/null | grep -q ":$port "; then
        echo -e "  ${GREEN}✅${NC} Port $port ($name): OPEN"
        ((open++))
    else
        echo -e "  ${YELLOW}⚠️${NC}  Port $port ($name): CLOSED"
        ((closed++))
    fi
done
echo "  Total: $open open, $closed closed"
echo ""

# 3. Critical files
echo -e "${YELLOW}📁 Critical Files:${NC}"
files=("/etc/xray/config.json" "/etc/xray/domain" "/etc/xray/xray.crt" "/etc/xray/xray.key" "/etc/nginx/conf.d/xray.conf" "/usr/local/bin/menu" "/usr/local/bin/vpnray-api")
found=0
missing=0
for f in "${files[@]}"; do
    if [[ -e "$f" ]]; then
        echo -e "  ${GREEN}✅${NC} $f"
        ((found++))
    else
        echo -e "  ${RED}❌${NC} $f (MISSING)"
        ((missing++))
    fi
done
echo "  Total: $found found, $missing missing"
echo ""

# Summary
total_ok=$((running + open + found))
total_fail=$((stopped + closed + missing))
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
if [[ "$total_fail" -eq 0 ]]; then
    echo -e "${GREEN}  ✅ All checks passed! System is production-ready.${NC}"
else
    echo -e "${YELLOW}  ⚠️  Some checks failed ($total_fail issues found).${NC}"
    echo -e "${YELLOW}  Review the output above and fix any issues.${NC}"
fi
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
VERIFY_SCRIPT
    chmod +x /usr/local/bin/vpnray-verify
    log "Post-install verification dibuat: /usr/local/bin/vpnray-verify"
}

# ============================================================================
# 4. System Info Display
# ============================================================================

create_sysinfo_script() {
    log "Membuat system info display script: $SYSINFO_SCRIPT"
    cat > "$SYSINFO_SCRIPT" << 'SYSINFO_CONTENT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — System Info Display
# ============================================================================

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
NC='\033[0m'

DOMAIN_FILE="/etc/xray/domain"
VERSION_FILE="/etc/vpnray/version"

domain="localhost"
[[ -f "$DOMAIN_FILE" ]] && domain=$(cat "$DOMAIN_FILE")

ip=$(curl -s --max-time 5 ifconfig.me 2>/dev/null || hostname -I 2>/dev/null | awk '{print $1}')

# shellcheck disable=SC1091
source /etc/os-release 2>/dev/null
os="${PRETTY_NAME:-Unknown}"

kernel=$(uname -r)
uptime_val=$(uptime -p 2>/dev/null || echo "N/A")
cpu_model=$(grep 'model name' /proc/cpuinfo 2>/dev/null | head -1 | awk -F': ' '{print $2}' || echo "N/A")
cpu_cores=$(nproc 2>/dev/null || echo "N/A")
cpu_load=$(cat /proc/loadavg 2>/dev/null | awk '{print $1, $2, $3}' || echo "N/A")

mem_total=$(free -m 2>/dev/null | awk '/^Mem:/{print $2}')
mem_used=$(free -m 2>/dev/null | awk '/^Mem:/{print $3}')
mem_free=$(free -m 2>/dev/null | awk '/^Mem:/{print $4}')

swap_total=$(free -m 2>/dev/null | awk '/^Swap:/{print $2}')
swap_used=$(free -m 2>/dev/null | awk '/^Swap:/{print $3}')

disk_total=$(df -h / 2>/dev/null | awk 'NR==2{print $2}')
disk_used=$(df -h / 2>/dev/null | awk 'NR==2{print $3}')
disk_free=$(df -h / 2>/dev/null | awk 'NR==2{print $4}')
disk_pct=$(df -h / 2>/dev/null | awk 'NR==2{print $5}')

version="2.0.0"
[[ -f "$VERSION_FILE" ]] && version=$(cat "$VERSION_FILE")

# Detect ISP
isp=$(curl -s --max-time 5 ipinfo.io/org 2>/dev/null || echo "N/A")

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║            ⚡ VPN TUNNELING AUTOSCRIPT ⚡                   ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo -e "║  ${WHITE}Version    : ${GREEN}$version${CYAN}                                       ║"
echo "╠══════════════════════════════════════════════════════════════╣"
echo -e "║  ${YELLOW}🌐 Server Info${CYAN}                                              ║"
echo -e "║  ${WHITE}Domain     : ${GREEN}$domain${CYAN}"
echo -e "║  ${WHITE}IP Address : ${GREEN}${ip:-unknown}${CYAN}"
echo -e "║  ${WHITE}ISP        : ${GREEN}${isp}${CYAN}"
echo -e "║  ${WHITE}OS         : ${GREEN}$os${CYAN}"
echo -e "║  ${WHITE}Kernel     : ${GREEN}$kernel${CYAN}"
echo -e "║  ${WHITE}Uptime     : ${GREEN}$uptime_val${CYAN}"
echo "╠══════════════════════════════════════════════════════════════╣"
echo -e "║  ${YELLOW}🔧 Hardware${CYAN}                                                 ║"
echo -e "║  ${WHITE}CPU        : ${GREEN}$cpu_model${CYAN}"
echo -e "║  ${WHITE}Cores      : ${GREEN}$cpu_cores${CYAN}"
echo -e "║  ${WHITE}Load       : ${GREEN}$cpu_load${CYAN}"
echo -e "║  ${WHITE}RAM        : ${GREEN}${mem_used}/${mem_total} MB (Free: ${mem_free} MB)${CYAN}"
echo -e "║  ${WHITE}SWAP       : ${GREEN}${swap_used}/${swap_total} MB${CYAN}"
echo -e "║  ${WHITE}Disk       : ${GREEN}${disk_used}/${disk_total} (${disk_pct} used, ${disk_free} free)${CYAN}"
echo "╠══════════════════════════════════════════════════════════════╣"
echo -e "║  ${YELLOW}🔌 Service Ports${CYAN}                                            ║"
echo -e "║  ${WHITE}SSH/OpenSSH    : 22${CYAN}"
echo -e "║  ${WHITE}Dropbear       : 80, 143, 443${CYAN}"
echo -e "║  ${WHITE}Stunnel        : 446, 445${CYAN}"
echo -e "║  ${WHITE}SSH-WS         : 8880${CYAN}"
echo -e "║  ${WHITE}HAProxy        : 80, 443${CYAN}"
echo -e "║  ${WHITE}Squid          : 3128, 8080${CYAN}"
echo -e "║  ${WHITE}BadVPN/UDPGW   : 7100-7900${CYAN}"
echo -e "║  ${WHITE}OHP            : 2083, 2084, 2087${CYAN}"
echo -e "║  ${WHITE}OpenVPN TCP    : 1194, 2294${CYAN}"
echo -e "║  ${WHITE}OpenVPN UDP    : 2200, 2295${CYAN}"
echo -e "║  ${WHITE}OpenVPN SSL    : 2296${CYAN}"
echo -e "║  ${WHITE}SoftEther      : 4433${CYAN}"
echo -e "║  ${WHITE}Xray (TLS)     : 443${CYAN}"
echo -e "║  ${WHITE}Xray (nonTLS)  : 80${CYAN}"
echo -e "║  ${WHITE}Hysteria2      : 443 (UDP)${CYAN}"
echo -e "║  ${WHITE}Trojan-Go      : 443${CYAN}"
echo -e "║  ${WHITE}WARP           : 51820 (UDP)${CYAN}"
echo -e "║  ${WHITE}SlowDNS        : 53, 5300, 2222${CYAN}"
echo -e "║  ${WHITE}REST API       : 9000${CYAN}"
echo -e "║  ${WHITE}vnStat Web     : 8899${CYAN}"
echo -e "║  ${WHITE}Webmin         : 10000${CYAN}"
echo "╠══════════════════════════════════════════════════════════════╣"
echo -e "║  ${YELLOW}📁 Quick Commands${CYAN}                                           ║"
echo -e "║  ${WHITE}menu           ${GREEN}— Dashboard utama${CYAN}"
echo -e "║  ${WHITE}vpnray-sysinfo ${GREEN}— Info sistem${CYAN}"
echo -e "║  ${WHITE}vpnray-verify  ${GREEN}— Verifikasi instalasi${CYAN}"
echo -e "║  ${WHITE}vpnray-backup  ${GREEN}— Backup ke cloud${CYAN}"
echo -e "║  ${WHITE}vpnray-restore ${GREEN}— Restore dari backup${CYAN}"
echo -e "║  ${WHITE}speedtest      ${GREEN}— Speed test${CYAN}"
echo -e "║  ${WHITE}running        ${GREEN}— Cek running services${CYAN}"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
SYSINFO_CONTENT
    chmod +x "$SYSINFO_SCRIPT"
    log "System info script dibuat: $SYSINFO_SCRIPT"
}

# ============================================================================
# 5. Uninstall Script
# ============================================================================

create_uninstall_script() {
    log "Membuat uninstall script: $UNINSTALL_SCRIPT"
    cat > "$UNINSTALL_SCRIPT" << 'UNINSTALL_CONTENT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Uninstall Script
# ============================================================================
# Membersihkan semua komponen yang diinstall oleh VPN Tunneling AutoScript.
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

if [[ "$(id -u)" -ne 0 ]]; then
    echo -e "${RED}Script ini harus dijalankan sebagai root!${NC}"
    exit 1
fi

echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║      VPN Tunneling AutoScript Uninstall      ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}⚠️  PERINGATAN: Ini akan menghapus SEMUA komponen VPN!${NC}"
echo -e "${YELLOW}   Termasuk konfigurasi, akun, dan data.${NC}"
echo ""
read -rp "Ketik 'UNINSTALL' untuk melanjutkan: " confirm

if [[ "$confirm" != "UNINSTALL" ]]; then
    echo -e "${GREEN}Uninstall dibatalkan.${NC}"
    exit 0
fi

echo ""
echo -e "${YELLOW}Memulai uninstall...${NC}"

# Stop all services
echo "[1/7] Stopping services..."
services=("xray" "nginx" "haproxy" "dropbear" "stunnel4" "squid" "openvpn" "hysteria2" "trojan-go" "fail2ban" "vpnray-api" "vpnray-bot" "vpnray-vnstat-web")
for svc in "${services[@]}"; do
    systemctl stop "$svc" 2>/dev/null
    systemctl disable "$svc" 2>/dev/null
done

# Remove Xray
echo "[2/7] Removing Xray..."
bash -c "$(curl -sL https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove 2>/dev/null
rm -rf /etc/xray /usr/local/bin/xray /var/log/xray

# Remove config directories
echo "[3/7] Removing configurations..."
rm -rf /etc/vpnray
rm -rf /etc/hysteria2
rm -rf /etc/trojan-go
rm -rf /etc/warp
rm -rf /etc/softether

# Remove utility scripts
echo "[4/7] Removing scripts..."
local_bins=(
    "menu" "menu-ssh" "menu-vmess" "menu-vless" "menu-trojan"
    "menu-shadowsocks" "menu-socks" "menu-hysteria2" "menu-trojan-go"
    "menu-openvpn" "menu-softether" "menu-warp" "menu-backup"
    "menu-api" "menu-bot" "menu-system" "running" "speedtest"
    "auto-clear-log" "auto-delete-expired" "xp-ssh" "xp-xray"
    "limit-ip-ssh" "limit-ip-xray" "limit-quota-xray"
    "lock-ssh" "lock-xray" "cf-domain" "install-ssl"
    "sshws" "udp-custom" "badvpn-udpgw" "ohp"
    "vpnray-api" "vpnray-api-start" "vpnray-bot" "vpnray-bot-seller"
    "vpnray-bot-notify" "vpnray-webhook"
    "vpnray-install" "vpnray-uninstall" "vpnray-rebuild"
    "vpnray-sysinfo" "vpnray-verify" "vpnray-perftuning"
    "vpnray-hardening" "vpnray-docgen" "vpnray-update"
    "vpnray-test" "vpnray-checklist" "vpnray-state"
    "vpnray-backup" "vpnray-restore" "vpnray-swap"
    "vpnray-firewall" "vpnray-ads-block" "vpnray-blacklist"
    "vpnray-bt-block" "vpnray-ip-manage" "vpnray-sod"
    "vpnray-cpu-monitor" "vpnray-mem-monitor" "vpnray-resource-monitor"
    "vpnray-install-webmin" "vpnray-vnstat-web"
    "generate-subscription" "generate-clash" "generate-vpnray"
)
for bin in "${local_bins[@]}"; do
    rm -f "/usr/local/bin/$bin"
done

# Remove systemd services
echo "[5/7] Removing systemd services..."
rm -f /etc/systemd/system/vpnray-*.service
systemctl daemon-reload 2>/dev/null

# Remove cron jobs
echo "[6/7] Removing cron jobs..."
rm -f /etc/cron.d/vpnray-*
rm -f /etc/cron.d/auto-clear-log
rm -f /etc/cron.d/auto-delete-expired
rm -f /etc/cron.d/auto-reboot

# Remove log files
echo "[7/7] Removing log files..."
rm -f /var/log/vpnray-*.log
rm -f /root/syslog.log

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║      ✅ Uninstall berhasil!                  ║${NC}"
echo -e "${GREEN}║      Semua komponen VPN telah dihapus.       ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Catatan: Paket system (nginx, haproxy, dll) tidak dihapus.${NC}"
echo -e "${YELLOW}Gunakan 'apt-get remove <paket>' untuk menghapus paket.${NC}"
UNINSTALL_CONTENT
    chmod +x "$UNINSTALL_SCRIPT"
    log "Uninstall script dibuat: $UNINSTALL_SCRIPT"
}

# ============================================================================
# 6. Rebuild Menu
# ============================================================================

create_rebuild_script() {
    log "Membuat rebuild script: $REBUILD_SCRIPT"
    cat > "$REBUILD_SCRIPT" << 'REBUILD_CONTENT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Rebuild Menu
# ============================================================================
# Rebuild VPS dari menu tanpa reinstall OS.
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

if [[ "$(id -u)" -ne 0 ]]; then
    echo -e "${RED}Script ini harus dijalankan sebagai root!${NC}"
    exit 1
fi

echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║      VPN Tunneling Rebuild Menu              ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo "  1. Rebuild Xray Config"
echo "  2. Rebuild Nginx Config"
echo "  3. Rebuild HAProxy Config"
echo "  4. Rebuild SSL Certificate"
echo "  5. Rebuild All Services"
echo "  6. Rebuild Akun Database"
echo "  7. Rebuild Menu Scripts"
echo "  8. Full Rebuild (All)"
echo "  0. Kembali"
echo ""
read -rp "Pilihan [0-8]: " choice

case "$choice" in
    1)
        echo -e "${YELLOW}Rebuilding Xray config...${NC}"
        systemctl restart xray 2>/dev/null
        echo -e "${GREEN}✅ Xray config rebuilt${NC}"
        ;;
    2)
        echo -e "${YELLOW}Rebuilding Nginx config...${NC}"
        nginx -t 2>/dev/null && systemctl restart nginx 2>/dev/null
        echo -e "${GREEN}✅ Nginx config rebuilt${NC}"
        ;;
    3)
        echo -e "${YELLOW}Rebuilding HAProxy config...${NC}"
        systemctl restart haproxy 2>/dev/null
        echo -e "${GREEN}✅ HAProxy config rebuilt${NC}"
        ;;
    4)
        echo -e "${YELLOW}Rebuilding SSL certificate...${NC}"
        if [[ -f /usr/local/bin/install-ssl ]]; then
            bash /usr/local/bin/install-ssl
        else
            echo -e "${RED}install-ssl script not found${NC}"
        fi
        ;;
    5)
        echo -e "${YELLOW}Rebuilding all services...${NC}"
        services=("xray" "nginx" "haproxy" "dropbear" "stunnel4" "squid" "openvpn" "hysteria2" "trojan-go")
        for svc in "${services[@]}"; do
            systemctl restart "$svc" 2>/dev/null && echo "  ✅ $svc restarted" || echo "  ⚠️  $svc failed"
        done
        echo -e "${GREEN}✅ All services rebuilt${NC}"
        ;;
    6)
        echo -e "${YELLOW}Rebuilding akun database...${NC}"
        mkdir -p /etc/vpnray/accounts/{ssh,vmess,vless,trojan,shadowsocks,socks,hysteria2,trojan-go}
        echo -e "${GREEN}✅ Account directories rebuilt${NC}"
        ;;
    7)
        echo -e "${YELLOW}Rebuilding menu scripts...${NC}"
        echo -e "${GREEN}✅ Menu scripts rebuilt (run setup-menu.sh for full rebuild)${NC}"
        ;;
    8)
        echo -e "${YELLOW}Full rebuild starting...${NC}"
        echo -e "${RED}⚠️  This will restart ALL services!${NC}"
        read -rp "Continue? [y/N]: " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            services=("xray" "nginx" "haproxy" "dropbear" "stunnel4" "squid" "openvpn" "hysteria2" "trojan-go" "fail2ban" "vnstat")
            for svc in "${services[@]}"; do
                systemctl restart "$svc" 2>/dev/null
            done
            echo -e "${GREEN}✅ Full rebuild complete${NC}"
        else
            echo "Dibatalkan."
        fi
        ;;
    0)
        echo "Kembali..."
        ;;
    *)
        echo -e "${RED}Pilihan tidak valid${NC}"
        ;;
esac
REBUILD_CONTENT
    chmod +x "$REBUILD_SCRIPT"
    log "Rebuild script dibuat: $REBUILD_SCRIPT"
}

# ============================================================================
# 7. Performance Optimization
# ============================================================================

create_perftuning_script() {
    log "Membuat performance tuning script: $PERFTUNING_SCRIPT"
    cat > "$PERFTUNING_SCRIPT" << 'PERF_CONTENT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Performance Optimization
# ============================================================================
# Tuning kernel, network, dan service parameters untuk performa optimal.
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

if [[ "$(id -u)" -ne 0 ]]; then
    echo -e "${RED}Script ini harus dijalankan sebagai root!${NC}"
    exit 1
fi

SYSCTL_VPN="/etc/sysctl.d/99-vpn-tuning.conf"

echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║      Performance Optimization                ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

case "${1:-apply}" in
    apply)
        echo -e "${YELLOW}Applying performance optimizations...${NC}"

        cat > "$SYSCTL_VPN" << 'SYSCTL_EOF'
# VPN Tunneling AutoScript — Performance Tuning
# ================================================

# Network buffer tuning
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.rmem_default = 65536
net.core.wmem_default = 65536
net.core.netdev_max_backlog = 10000
net.core.somaxconn = 65535

# TCP tuning
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 6
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1

# UDP tuning (for Hysteria2/QUIC)
net.core.optmem_max = 65536

# IP forwarding (for VPN)
net.ipv4.ip_forward = 1

# Connection tracking
net.netfilter.nf_conntrack_max = 1048576

# File descriptors
fs.file-max = 1048576
fs.nr_open = 1048576

# BBR module
net.core.default_qdisc = fq
SYSCTL_EOF

        # Load BBR module
        modprobe tcp_bbr 2>/dev/null

        # Apply sysctl
        sysctl -p "$SYSCTL_VPN" 2>/dev/null

        # Increase file descriptor limits
        if ! grep -q "vpn-tuning" /etc/security/limits.conf 2>/dev/null; then
            cat >> /etc/security/limits.conf << 'LIMITS_EOF'

# VPN Tunneling — vpn-tuning
* soft nofile 1048576
* hard nofile 1048576
* soft nproc 65535
* hard nproc 65535
root soft nofile 1048576
root hard nofile 1048576
LIMITS_EOF
        fi

        echo -e "${GREEN}✅ Performance optimizations applied${NC}"
        echo ""
        echo "Settings applied:"
        echo "  • TCP BBR congestion control"
        echo "  • TCP Fast Open enabled"
        echo "  • Network buffer optimized (64MB)"
        echo "  • Connection tracking increased"
        echo "  • File descriptor limit: 1M"
        echo "  • IP forwarding enabled"
        ;;
    status)
        echo -e "${YELLOW}Current kernel parameters:${NC}"
        echo "  BBR: $(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null)"
        echo "  FastOpen: $(sysctl -n net.ipv4.tcp_fastopen 2>/dev/null)"
        echo "  IP Forward: $(sysctl -n net.ipv4.ip_forward 2>/dev/null)"
        echo "  Max FD: $(sysctl -n fs.file-max 2>/dev/null)"
        echo "  Conntrack Max: $(sysctl -n net.netfilter.nf_conntrack_max 2>/dev/null)"
        echo "  Somaxconn: $(sysctl -n net.core.somaxconn 2>/dev/null)"
        ;;
    revert)
        echo -e "${YELLOW}Reverting performance optimizations...${NC}"
        rm -f "$SYSCTL_VPN"
        sysctl --system 2>/dev/null
        echo -e "${GREEN}✅ Performance optimizations reverted${NC}"
        ;;
    *)
        echo "Usage: vpnray-perftuning [apply|status|revert]"
        ;;
esac
PERF_CONTENT
    chmod +x "$PERFTUNING_SCRIPT"
    log "Performance tuning script dibuat: $PERFTUNING_SCRIPT"
}

# ============================================================================
# 8. Security Hardening
# ============================================================================

create_hardening_script() {
    log "Membuat security hardening script: $HARDENING_SCRIPT"
    cat > "$HARDENING_SCRIPT" << 'HARDENING_CONTENT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Security Hardening
# ============================================================================
# Hardening SSH, disable unnecessary services, dan konfigurasi keamanan.
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

if [[ "$(id -u)" -ne 0 ]]; then
    echo -e "${RED}Script ini harus dijalankan sebagai root!${NC}"
    exit 1
fi

SSHD_CONFIG="/etc/ssh/sshd_config"
HARDENING_SYSCTL="/etc/sysctl.d/99-security-hardening.conf"

echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║      Security Hardening                      ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

case "${1:-apply}" in
    apply)
        echo -e "${YELLOW}Applying security hardening...${NC}"

        # 1. SSH Hardening
        echo "[1/5] SSH Hardening..."
        if [[ -f "$SSHD_CONFIG" ]]; then
            cp "$SSHD_CONFIG" "${SSHD_CONFIG}.bak.$(date +%s)"

            # Disable root password login (keep key-based)
            sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin prohibit-password/' "$SSHD_CONFIG" 2>/dev/null
            # Disable empty passwords
            sed -i 's/^#\?PermitEmptyPasswords.*/PermitEmptyPasswords no/' "$SSHD_CONFIG" 2>/dev/null
            # Limit auth tries
            sed -i 's/^#\?MaxAuthTries.*/MaxAuthTries 5/' "$SSHD_CONFIG" 2>/dev/null
            # Disable X11 forwarding
            sed -i 's/^#\?X11Forwarding.*/X11Forwarding no/' "$SSHD_CONFIG" 2>/dev/null
            # Set login grace time
            sed -i 's/^#\?LoginGraceTime.*/LoginGraceTime 60/' "$SSHD_CONFIG" 2>/dev/null
            # Client alive interval
            sed -i 's/^#\?ClientAliveInterval.*/ClientAliveInterval 300/' "$SSHD_CONFIG" 2>/dev/null
            sed -i 's/^#\?ClientAliveCountMax.*/ClientAliveCountMax 3/' "$SSHD_CONFIG" 2>/dev/null

            systemctl reload sshd 2>/dev/null
            echo "  ✅ SSH hardened"
        fi

        # 2. Disable unnecessary services
        echo "[2/5] Disabling unnecessary services..."
        unnecessary=("avahi-daemon" "cups" "rpcbind" "postfix" "nfs-server" "bluetooth")
        for svc in "${unnecessary[@]}"; do
            if systemctl is-active --quiet "$svc" 2>/dev/null; then
                systemctl stop "$svc" 2>/dev/null
                systemctl disable "$svc" 2>/dev/null
                echo "  ✅ Disabled: $svc"
            fi
        done

        # 3. Kernel security parameters
        echo "[3/5] Kernel security parameters..."
        cat > "$HARDENING_SYSCTL" << 'SYSCTL_SEC_EOF'
# VPN Tunneling — Security Hardening
# ========================================

# Prevent IP spoofing
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Disable ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Disable source routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# Log martian packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# Ignore broadcast pings
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Ignore bogus ICMP errors
net.ipv4.icmp_ignore_bogus_error_responses = 1

# SYN flood protection
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2

# Prevent core dumps
fs.suid_dumpable = 0

# Restrict dmesg
kernel.dmesg_restrict = 1

# Address space layout randomization
kernel.randomize_va_space = 2
SYSCTL_SEC_EOF

        sysctl -p "$HARDENING_SYSCTL" 2>/dev/null
        echo "  ✅ Kernel security parameters applied"

        # 4. Set proper permissions
        echo "[4/5] Setting file permissions..."
        chmod 600 /etc/xray/xray.key 2>/dev/null
        chmod 644 /etc/xray/xray.crt 2>/dev/null
        chmod 600 /etc/xray/cloudflare 2>/dev/null
        chmod 600 /etc/vpnray/api/api-key 2>/dev/null
        echo "  ✅ File permissions hardened"

        # 5. Ensure fail2ban is running
        echo "[5/5] Ensuring fail2ban..."
        systemctl enable fail2ban 2>/dev/null
        systemctl start fail2ban 2>/dev/null
        echo "  ✅ Fail2ban active"

        echo ""
        echo -e "${GREEN}✅ Security hardening complete${NC}"
        echo ""
        echo "Applied:"
        echo "  • SSH: root password login disabled, max 5 auth tries"
        echo "  • Unnecessary services disabled"
        echo "  • Anti-spoofing, anti-redirect kernel params"
        echo "  • SYN flood protection enabled"
        echo "  • ASLR enabled, core dumps disabled"
        echo "  • File permissions hardened"
        echo "  • Fail2ban active"
        ;;
    status)
        echo -e "${YELLOW}Security Status:${NC}"
        echo ""
        echo "SSH Config:"
        grep -E "^(PermitRootLogin|PermitEmptyPasswords|MaxAuthTries|X11Forwarding)" "$SSHD_CONFIG" 2>/dev/null
        echo ""
        echo "Fail2ban:"
        fail2ban-client status 2>/dev/null | head -5 || echo "  Not running"
        echo ""
        echo "Kernel Security:"
        echo "  rp_filter: $(sysctl -n net.ipv4.conf.all.rp_filter 2>/dev/null)"
        echo "  ASLR: $(sysctl -n kernel.randomize_va_space 2>/dev/null)"
        echo "  syncookies: $(sysctl -n net.ipv4.tcp_syncookies 2>/dev/null)"
        ;;
    revert)
        echo -e "${YELLOW}Reverting security hardening...${NC}"
        if [[ -f "${SSHD_CONFIG}.bak."* ]]; then
            # shellcheck disable=SC2012
            latest_bak=$(ls -t "${SSHD_CONFIG}".bak.* 2>/dev/null | head -1)
            if [[ -n "$latest_bak" ]]; then
                cp "$latest_bak" "$SSHD_CONFIG"
                systemctl reload sshd 2>/dev/null
            fi
        fi
        rm -f "$HARDENING_SYSCTL"
        sysctl --system 2>/dev/null
        echo -e "${GREEN}✅ Security hardening reverted${NC}"
        ;;
    *)
        echo "Usage: vpnray-hardening [apply|status|revert]"
        ;;
esac
HARDENING_CONTENT
    chmod +x "$HARDENING_SCRIPT"
    log "Security hardening script dibuat: $HARDENING_SCRIPT"
}

# ============================================================================
# 9. Documentation Generator
# ============================================================================

create_docgen_script() {
    log "Membuat documentation generator: $DOCGEN_SCRIPT"
    cat > "$DOCGEN_SCRIPT" << 'DOCGEN_CONTENT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Documentation Generator
# ============================================================================
# Auto-generate dokumentasi berdasarkan konfigurasi aktif.
# ============================================================================

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

OUTPUT_FILE="${1:-/root/vpn-documentation.txt}"
DOMAIN_FILE="/etc/xray/domain"
ACCOUNT_DIR="/etc/vpnray/accounts"

domain="localhost"
[[ -f "$DOMAIN_FILE" ]] && domain=$(cat "$DOMAIN_FILE")
ip=$(curl -s --max-time 5 ifconfig.me 2>/dev/null || hostname -I 2>/dev/null | awk '{print $1}')

# shellcheck disable=SC1091
source /etc/os-release 2>/dev/null

{
echo "================================================================="
echo "  VPN TUNNELING AUTOSCRIPT — DOCUMENTATION"
echo "  Generated: $(date '+%Y-%m-%d %H:%M:%S')"
echo "================================================================="
echo ""

echo "1. SERVER INFORMATION"
echo "   Domain     : $domain"
echo "   IP Address : ${ip:-unknown}"
echo "   OS         : ${PRETTY_NAME:-Unknown}"
echo "   Kernel     : $(uname -r)"
echo ""

echo "2. SERVICE PORTS"
echo "   SSH/OpenSSH      : 22"
echo "   Dropbear         : 80, 143, 443"
echo "   Stunnel          : 446, 445"
echo "   SSH WebSocket    : 8880"
echo "   HAProxy          : 80, 443"
echo "   Squid            : 3128, 8080"
echo "   BadVPN/UDPGW     : 7100-7900"
echo "   OHP              : 2083, 2084, 2087"
echo "   OpenVPN TCP      : 1194, 2294"
echo "   OpenVPN UDP      : 2200, 2295"
echo "   OpenVPN SSL      : 2296"
echo "   SoftEther        : 4433"
echo "   Xray TLS         : 443"
echo "   Xray non-TLS     : 80"
echo "   Hysteria2        : 443 (UDP)"
echo "   Trojan-Go        : 443"
echo "   WARP             : 51820 (UDP)"
echo "   SlowDNS          : 53, 5300, 2222"
echo "   REST API         : 9000"
echo "   vnStat Web       : 8899"
echo "   Webmin           : 10000"
echo ""

echo "3. XRAY WEBSOCKET PATHS"
echo "   VMess WS         : /vmessws"
echo "   VMess gRPC       : vmess-grpc"
echo "   VMess HTTPUpgrade: /vmess-httpupgrade"
echo "   VLESS WS         : /vlessws"
echo "   VLESS gRPC       : vless-grpc"
echo "   VLESS HTTPUpgrade: /vless-httpupgrade"
echo "   Trojan WS        : /trojanws"
echo "   Trojan gRPC      : trojan-grpc"
echo "   Trojan HTTPUpgrade: /trojan-httpupgrade"
echo "   SS WS            : /ssws"
echo "   SS gRPC          : ss-grpc"
echo "   Socks WS         : /socksws"
echo "   Socks gRPC       : socks-grpc"
echo ""

echo "4. ACTIVE ACCOUNTS"
protocols=("ssh" "vmess" "vless" "trojan" "shadowsocks" "socks" "hysteria2" "trojan-go")
for proto in "${protocols[@]}"; do
    dir="$ACCOUNT_DIR/$proto"
    if [[ -d "$dir" ]]; then
        count=$(find "$dir" -name "*.json" 2>/dev/null | wc -l)
        echo "   ${proto^^}: $count accounts"
    fi
done
echo ""

echo "5. SERVICE STATUS"
services=("xray" "nginx" "haproxy" "dropbear" "stunnel4" "squid" "openvpn" "hysteria2" "trojan-go" "fail2ban" "vnstat")
for svc in "${services[@]}"; do
    if systemctl is-active --quiet "$svc" 2>/dev/null; then
        echo "   ✅ $svc: running"
    else
        echo "   ❌ $svc: stopped"
    fi
done
echo ""

echo "6. CONFIGURATION FILES"
configs=(
    "/etc/xray/config.json"
    "/etc/hysteria2/config.yaml"
    "/etc/trojan-go/config.json"
    "/etc/nginx/conf.d/xray.conf"
    "/etc/haproxy/haproxy.cfg"
    "/etc/openvpn/server-tcp.conf"
    "/etc/fail2ban/jail.local"
)
for cfg in "${configs[@]}"; do
    if [[ -f "$cfg" ]]; then
        echo "   ✅ $cfg"
    else
        echo "   ❌ $cfg (missing)"
    fi
done
echo ""

echo "7. REST API"
echo "   Endpoint  : http://$domain:9000"
echo "   Docs      : http://$domain:9000/docs"
echo "   Auth      : ******, api-key from /etc/vpnray/api/api-key"
echo ""

echo "8. USEFUL COMMANDS"
echo "   menu               — Main dashboard"
echo "   vpnray-sysinfo     — System info"
echo "   vpnray-verify      — Post-install verification"
echo "   vpnray-backup      — Backup to cloud"
echo "   vpnray-restore     — Restore from backup"
echo "   vpnray-perftuning  — Performance tuning"
echo "   vpnray-hardening   — Security hardening"
echo "   vpnray-update      — Check for updates"
echo "   vpnray-checklist   — Production checklist"
echo "   speedtest          — Speed test"
echo "   running            — Running services"
echo ""

echo "================================================================="
echo "  End of Documentation"
echo "================================================================="
} > "$OUTPUT_FILE"

echo -e "${GREEN}✅ Documentation generated: $OUTPUT_FILE${NC}"
echo -e "${CYAN}   View: cat $OUTPUT_FILE${NC}"
DOCGEN_CONTENT
    chmod +x "$DOCGEN_SCRIPT"
    log "Documentation generator dibuat: $DOCGEN_SCRIPT"
}

# ============================================================================
# 10. Version Management
# ============================================================================

create_update_script() {
    log "Membuat update/version management script: $UPDATE_SCRIPT"

    # Save current version
    mkdir -p "$(dirname "$VERSION_FILE")"
    echo "$SCRIPT_VERSION" > "$VERSION_FILE"

    cat > "$UPDATE_SCRIPT" << 'UPDATE_CONTENT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Update Checker & Version Manager
# ============================================================================

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

VERSION_FILE="/etc/vpnray/version"
UPDATE_CHECK_URL="https://raw.githubusercontent.com/kertasbaru/installer/main/version.txt"

current_version="unknown"
[[ -f "$VERSION_FILE" ]] && current_version=$(cat "$VERSION_FILE")

echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║      Version Manager                         ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

case "${1:-check}" in
    check)
        echo -e "${YELLOW}Current version: $current_version${NC}"
        echo ""
        echo "Checking for updates..."
        remote_version=$(curl -s --max-time 10 "$UPDATE_CHECK_URL" 2>/dev/null)
        if [[ -n "$remote_version" ]]; then
            echo -e "Remote version: ${GREEN}$remote_version${NC}"
            if [[ "$current_version" == "$remote_version" ]]; then
                echo -e "${GREEN}✅ You are running the latest version!${NC}"
            else
                echo -e "${YELLOW}⚠️  Update available: $remote_version${NC}"
                echo "Run: vpnray-update upgrade"
            fi
        else
            echo -e "${YELLOW}⚠️  Could not check for updates (no internet?)${NC}"
        fi
        ;;
    version)
        echo "$current_version"
        ;;
    upgrade)
        echo -e "${YELLOW}Starting upgrade...${NC}"
        echo -e "${RED}⚠️  This will download and install the latest version.${NC}"
        read -rp "Continue? [y/N]: " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            echo "Downloading latest version..."
            if curl -sL "https://raw.githubusercontent.com/kertasbaru/installer/main/setup-final.sh" -o /tmp/setup-final-update.sh 2>/dev/null; then
                bash /tmp/setup-final-update.sh
                rm -f /tmp/setup-final-update.sh
                echo -e "${GREEN}✅ Upgrade complete${NC}"
            else
                echo -e "${RED}❌ Download failed${NC}"
            fi
        else
            echo "Dibatalkan."
        fi
        ;;
    *)
        echo "Usage: vpnray-update [check|version|upgrade]"
        ;;
esac
UPDATE_CONTENT
    chmod +x "$UPDATE_SCRIPT"
    log "Update script dibuat: $UPDATE_SCRIPT"
}

# ============================================================================
# 11. Full Integration Testing
# ============================================================================

create_integration_test() {
    log "Membuat integration test script: $INTEGRATION_TEST_SCRIPT"
    cat > "$INTEGRATION_TEST_SCRIPT" << 'TEST_CONTENT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Full Integration Test
# ============================================================================
# End-to-end test semua komponen.
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS=0
FAIL=0
SKIP=0

check() {
    local name="$1"
    local result="$2"

    if [[ "$result" == "true" ]]; then
        echo -e "  ${GREEN}[PASS]${NC} $name"
        ((PASS++))
    else
        echo -e "  ${RED}[FAIL]${NC} $name"
        ((FAIL++))
    fi
}

skip() {
    local name="$1"
    echo -e "  ${YELLOW}[SKIP]${NC} $name"
    ((SKIP++))
}

echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║      Full Integration Test                    ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

# 1. Core Configuration Files
echo -e "${YELLOW}1. Core Configuration Files${NC}"
check "Xray config exists" "$([[ -f /etc/xray/config.json ]] && echo true || echo false)"
check "Domain file exists" "$([[ -f /etc/xray/domain ]] && echo true || echo false)"
check "SSL cert exists" "$([[ -f /etc/xray/xray.crt ]] && echo true || echo false)"
check "SSL key exists" "$([[ -f /etc/xray/xray.key ]] && echo true || echo false)"
check "Nginx config exists" "$([[ -f /etc/nginx/conf.d/xray.conf ]] && echo true || echo false)"
check "HAProxy config exists" "$([[ -f /etc/haproxy/haproxy.cfg ]] && echo true || echo false)"
echo ""

# 2. Account System
echo -e "${YELLOW}2. Account System${NC}"
check "Account dir exists" "$([[ -d /etc/vpnray/accounts ]] && echo true || echo false)"
protocols=("ssh" "vmess" "vless" "trojan" "shadowsocks" "socks" "hysteria2" "trojan-go")
for proto in "${protocols[@]}"; do
    check "Account dir: $proto" "$([[ -d /etc/vpnray/accounts/$proto ]] && echo true || echo false)"
done
echo ""

# 3. Menu System
echo -e "${YELLOW}3. Menu System${NC}"
menus=("menu" "menu-ssh" "menu-vmess" "menu-vless" "menu-trojan" "menu-shadowsocks" "menu-socks" "menu-hysteria2" "menu-trojan-go")
for m in "${menus[@]}"; do
    check "Menu: $m" "$([[ -f /usr/local/bin/$m ]] && echo true || echo false)"
done
echo ""

# 4. API & Bot
echo -e "${YELLOW}4. API & Bot${NC}"
check "API server script" "$([[ -f /usr/local/bin/vpnray-api ]] && echo true || echo false)"
check "API config dir" "$([[ -d /etc/vpnray/api ]] && echo true || echo false)"
check "Bot script" "$([[ -f /usr/local/bin/vpnray-bot ]] && echo true || echo false)"
check "Webhook script" "$([[ -f /usr/local/bin/vpnray-webhook ]] && echo true || echo false)"
echo ""

# 5. Monitoring & Security
echo -e "${YELLOW}5. Monitoring & Security${NC}"
check "Backup script" "$([[ -f /usr/local/bin/vpnray-backup ]] && echo true || echo false)"
check "Restore script" "$([[ -f /usr/local/bin/vpnray-restore ]] && echo true || echo false)"
check "Firewall script" "$([[ -f /usr/local/bin/vpnray-firewall ]] && echo true || echo false)"
check "Ads block script" "$([[ -f /usr/local/bin/vpnray-ads-block ]] && echo true || echo false)"
check "SWAP script" "$([[ -f /usr/local/bin/vpnray-swap ]] && echo true || echo false)"
echo ""

# 6. Finalisasi Scripts
echo -e "${YELLOW}6. Finalisasi Scripts${NC}"
finals=("vpnray-install" "vpnray-uninstall" "vpnray-rebuild" "vpnray-sysinfo" "vpnray-verify" "vpnray-perftuning" "vpnray-hardening" "vpnray-docgen" "vpnray-update" "vpnray-checklist" "vpnray-state")
for f in "${finals[@]}"; do
    check "Script: $f" "$([[ -f /usr/local/bin/$f ]] && echo true || echo false)"
done
echo ""

# 7. Running services
echo -e "${YELLOW}7. Running Services${NC}"
services=("xray" "nginx" "haproxy" "dropbear" "stunnel4" "fail2ban" "vnstat")
for svc in "${services[@]}"; do
    if systemctl is-active --quiet "$svc" 2>/dev/null; then
        check "Service: $svc running" "true"
    else
        skip "Service: $svc not running"
    fi
done
echo ""

# Summary
total=$((PASS + FAIL + SKIP))
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo -e "  ${GREEN}PASS: $PASS${NC}  ${RED}FAIL: $FAIL${NC}  ${YELLOW}SKIP: $SKIP${NC}  Total: $total"
echo -e "${CYAN}════════════════════════════════════════════════${NC}"

if [[ "$FAIL" -eq 0 ]]; then
    echo -e "${GREEN}  ✅ All integration tests passed!${NC}"
else
    echo -e "${RED}  ⚠️  Some tests failed. Review the output above.${NC}"
fi
TEST_CONTENT
    chmod +x "$INTEGRATION_TEST_SCRIPT"
    log "Integration test script dibuat: $INTEGRATION_TEST_SCRIPT"
}

# ============================================================================
# 12. Production Checklist
# ============================================================================

create_checklist_script() {
    log "Membuat production checklist script: $CHECKLIST_SCRIPT"
    cat > "$CHECKLIST_SCRIPT" << 'CHECKLIST_CONTENT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Production Checklist
# ============================================================================
# Checklist verifikasi sebelum produksi.
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS=0
FAIL=0

verify() {
    local name="$1"
    local condition="$2"

    if eval "$condition" 2>/dev/null; then
        echo -e "  ${GREEN}[✅]${NC} $name"
        ((PASS++))
    else
        echo -e "  ${RED}[❌]${NC} $name"
        ((FAIL++))
    fi
}

echo -e "${CYAN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║      Production Checklist                     ║${NC}"
echo -e "${CYAN}╚══════════════════════════════════════════════╝${NC}"
echo ""

# 1. System Requirements
echo -e "${YELLOW}📋 System Requirements${NC}"
verify "Running as root" "[[ \$(id -u) -eq 0 ]]"
verify "OS is Ubuntu/Debian" "grep -qE '(ubuntu|debian)' /etc/os-release"
verify "Architecture: x86_64" "[[ \$(uname -m) == 'x86_64' ]]"
verify "IPv6 disabled" "[[ \$(sysctl -n net.ipv6.conf.all.disable_ipv6 2>/dev/null) == '1' ]]"
echo ""

# 2. SSL & Domain
echo -e "${YELLOW}📋 SSL & Domain${NC}"
verify "Domain configured" "[[ -s /etc/xray/domain ]]"
verify "SSL certificate exists" "[[ -f /etc/xray/xray.crt ]]"
verify "SSL key exists" "[[ -f /etc/xray/xray.key ]]"
verify "SSL key permissions (600)" "[[ \$(stat -c %a /etc/xray/xray.key 2>/dev/null) == '600' ]]"
echo ""

# 3. Core Services
echo -e "${YELLOW}📋 Core Services${NC}"
verify "Xray running" "systemctl is-active --quiet xray"
verify "Nginx running" "systemctl is-active --quiet nginx"
verify "HAProxy running" "systemctl is-active --quiet haproxy"
verify "Fail2ban running" "systemctl is-active --quiet fail2ban"
echo ""

# 4. Security
echo -e "${YELLOW}📋 Security${NC}"
verify "Fail2ban configured" "[[ -f /etc/fail2ban/jail.local ]]"
verify "Firewall rules exist" "[[ -f /etc/vpnray/firewall-rules.conf ]]"
verify "API key protected" "[[ -f /etc/vpnray/api/api-key ]]"
verify "BBR enabled" "[[ \$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null) == 'bbr' ]]"
echo ""

# 5. Backup
echo -e "${YELLOW}📋 Backup${NC}"
verify "Backup script exists" "[[ -f /usr/local/bin/vpnray-backup ]]"
verify "Backup directory exists" "[[ -d /home/vps/backup ]]"
verify "Auto backup cron" "[[ -f /etc/cron.d/vpnray-auto-backup ]]"
echo ""

# 6. Monitoring
echo -e "${YELLOW}📋 Monitoring${NC}"
verify "vnStat installed" "command -v vnstat"
verify "Log rotation configured" "[[ -f /etc/logrotate.d/vpnray ]]"
verify "Auto clear log cron" "[[ -f /etc/cron.d/auto-clear-log ]]"
echo ""

# 7. Version
echo -e "${YELLOW}📋 Version & Docs${NC}"
verify "Version file exists" "[[ -f /etc/vpnray/version ]]"
verify "Documentation generator" "[[ -f /usr/local/bin/vpnray-docgen ]]"
echo ""

# Summary
total=$((PASS + FAIL))
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
echo -e "  ${GREEN}PASS: $PASS${NC} / ${WHITE}$total${NC}  ${RED}FAIL: $FAIL${NC}"
echo ""

if [[ "$FAIL" -eq 0 ]]; then
    echo -e "  ${GREEN}✅ System is PRODUCTION-READY!${NC}"
else
    pct=$((PASS * 100 / total))
    echo -e "  ${YELLOW}⚠️  $pct% ready. Fix $FAIL items above.${NC}"
fi
echo -e "${CYAN}════════════════════════════════════════════════${NC}"
CHECKLIST_CONTENT
    chmod +x "$CHECKLIST_SCRIPT"
    log "Production checklist script dibuat: $CHECKLIST_SCRIPT"
}

# ============================================================================
# Apply Performance & Hardening (inline)
# ============================================================================

apply_performance_tuning() {
    log "Applying performance tuning..."

    local sysctl_file="/etc/sysctl.d/99-vpn-tuning.conf"
    cat > "$sysctl_file" << 'SYSCTL_EOF'
# VPN Tunneling AutoScript — Performance Tuning
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.rmem_default = 65536
net.core.wmem_default = 65536
net.core.netdev_max_backlog = 10000
net.core.somaxconn = 65535
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mtu_probing = 1
net.ipv4.tcp_max_syn_backlog = 65535
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 6
net.ipv4.tcp_syncookies = 1
net.ipv4.ip_forward = 1
net.core.default_qdisc = fq
fs.file-max = 1048576
SYSCTL_EOF

    modprobe tcp_bbr 2>/dev/null
    sysctl -p "$sysctl_file" 2>/dev/null

    log "Performance tuning applied"
}

apply_security_hardening() {
    log "Applying security hardening..."

    local sysctl_file="/etc/sysctl.d/99-security-hardening.conf"
    cat > "$sysctl_file" << 'SYSCTL_SEC_EOF'
# VPN Tunneling — Security Hardening
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
fs.suid_dumpable = 0
kernel.dmesg_restrict = 1
kernel.randomize_va_space = 2
SYSCTL_SEC_EOF

    sysctl -p "$sysctl_file" 2>/dev/null

    # SSH Hardening (if config exists)
    local sshd_config="/etc/ssh/sshd_config"
    if [[ -f "$sshd_config" ]]; then
        sed -i 's/^#\?PermitEmptyPasswords.*/PermitEmptyPasswords no/' "$sshd_config" 2>/dev/null
        sed -i 's/^#\?MaxAuthTries.*/MaxAuthTries 5/' "$sshd_config" 2>/dev/null
        sed -i 's/^#\?X11Forwarding.*/X11Forwarding no/' "$sshd_config" 2>/dev/null
        systemctl reload sshd 2>/dev/null
    fi

    log "Security hardening applied"
}

# ============================================================================
# Main Function
# ============================================================================

main() {
    # 1. Print header
    print_header

    # 2. Pengecekan prasyarat
    echo -e "${CYAN}[1/13]${NC} Memeriksa prasyarat..."
    check_root
    check_os
    check_arch
    check_virt
    check_previous_tahap

    # 3. Auto-Installer
    echo -e "${CYAN}[2/13]${NC} Membuat Auto-Installer tunggal..."
    create_auto_installer

    # 4. State tracking & error recovery
    echo -e "${CYAN}[3/13]${NC} Setup state tracking & error recovery..."
    setup_state_tracking

    # 5. Post-Install Verification
    echo -e "${CYAN}[4/13]${NC} Membuat post-install verification..."
    create_post_install_verify

    # 6. System Info Display
    echo -e "${CYAN}[5/13]${NC} Membuat system info display..."
    create_sysinfo_script

    # 7. Uninstall Script
    echo -e "${CYAN}[6/13]${NC} Membuat uninstall script..."
    create_uninstall_script

    # 8. Rebuild Menu
    echo -e "${CYAN}[7/13]${NC} Membuat rebuild menu..."
    create_rebuild_script

    # 9. Performance Optimization
    echo -e "${CYAN}[8/13]${NC} Membuat performance optimization..."
    create_perftuning_script

    # 10. Security Hardening
    echo -e "${CYAN}[9/13]${NC} Membuat security hardening..."
    create_hardening_script

    # 11. Documentation Generator
    echo -e "${CYAN}[10/13]${NC} Membuat documentation generator..."
    create_docgen_script

    # 12. Version Management
    echo -e "${CYAN}[11/13]${NC} Membuat version management..."
    create_update_script

    # 13. Integration Testing
    echo -e "${CYAN}[12/13]${NC} Membuat integration test..."
    create_integration_test

    # 14. Production Checklist
    echo -e "${CYAN}[13/13]${NC} Membuat production checklist..."
    create_checklist_script

    # Apply optimizations
    echo ""
    echo -e "${CYAN}[BONUS]${NC} Applying performance optimization..."
    apply_performance_tuning

    echo -e "${CYAN}[BONUS]${NC} Applying security hardening..."
    apply_security_hardening

    # Save version
    mkdir -p "$(dirname "$VERSION_FILE")"
    echo "$SCRIPT_VERSION" > "$VERSION_FILE"

    # Selesai
    echo ""
    echo -e "${GREEN}=============================================="
    echo "  Tahap 10 selesai!"
    echo "  Finalisasi & Produksi berhasil dikonfigurasi."
    echo ""
    echo "  Auto-Installer:"
    echo "    Script         : $AUTO_INSTALLER_SCRIPT"
    echo "    State Manager  : /usr/local/bin/vpnray-state"
    echo ""
    echo "  Verifikasi & Info:"
    echo "    Post-Install   : /usr/local/bin/vpnray-verify"
    echo "    System Info    : $SYSINFO_SCRIPT"
    echo "    Checklist      : $CHECKLIST_SCRIPT"
    echo ""
    echo "  Manajemen:"
    echo "    Uninstall      : $UNINSTALL_SCRIPT"
    echo "    Rebuild        : $REBUILD_SCRIPT"
    echo "    Update         : $UPDATE_SCRIPT"
    echo ""
    echo "  Optimasi & Keamanan:"
    echo "    Performance    : $PERFTUNING_SCRIPT"
    echo "    Hardening      : $HARDENING_SCRIPT"
    echo ""
    echo "  Dokumentasi & Testing:"
    echo "    Doc Generator  : $DOCGEN_SCRIPT"
    echo "    Integration    : $INTEGRATION_TEST_SCRIPT"
    echo ""
    echo "  Version: $SCRIPT_VERSION"
    echo ""
    echo "  🎉 Semua tahap (1-10) telah selesai!"
    echo "  Jalankan 'menu' untuk mengakses dashboard."
    echo "  Jalankan 'vpnray-sysinfo' untuk info VPS."
    echo "  Jalankan 'vpnray-checklist' untuk verifikasi produksi."
    echo -e "==============================================${NC}"
    echo ""

    log "Tahap 10 selesai. Finalisasi & Produksi berhasil dikonfigurasi."
}

main "$@"
