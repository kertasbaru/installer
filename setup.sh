#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript Installer — Tahap 1: Update Sistem & Reboot
# ============================================================================
# Script ini melakukan update sistem dan reboot sebagai persiapan awal
# sebelum instalasi komponen VPN Tunneling.
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
#   - Fresh/Clean Install OS
#
# Penggunaan:
#   chmod +x setup.sh
#   ./setup.sh
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
    echo "  Tahap 1: Update Sistem & Reboot"
    echo "=============================================="
    echo -e "${NC}"
}

# ============================================================================
# Pengecekan Prasyarat
# ============================================================================

check_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        log_error "Script ini harus dijalankan sebagai root!"
        echo -e "${RED}Gunakan: sudo ./setup.sh${NC}"
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
# Proses Update Sistem (Tahap 1)
# ============================================================================

update_system() {
    log "Memulai update sistem..."

    # Set non-interactive mode
    export DEBIAN_FRONTEND=noninteractive

    # Tambah group dip (diperlukan untuk PPP/networking)
    log "Menambahkan group 'dip'..."
    addgroup dip &>/dev/null
    log "Group 'dip' siap."

    # Update package list
    log "Menjalankan apt-get update..."
    if ! apt-get update -y --allow-releaseinfo-change >> "$LOG_FILE" 2>&1; then
        log_error "apt-get update gagal! Periksa koneksi internet dan repository."
        exit 1
    fi
    log "apt-get update selesai."

    # Reinstall grub
    log "Reinstall grub..."
    if ! apt-get install --reinstall -y grub >> "$LOG_FILE" 2>&1; then
        # Pada beberapa sistem, package 'grub' mungkin bernama berbeda
        log_warn "Reinstall grub gagal, mencoba grub2..."
        if ! apt-get install --reinstall -y grub2 >> "$LOG_FILE" 2>&1; then
            log_warn "Reinstall grub2 juga gagal, mencoba grub-pc..."
            if ! apt-get install --reinstall -y grub-pc >> "$LOG_FILE" 2>&1; then
                log_warn "Reinstall grub-pc gagal. Melanjutkan proses..."
            fi
        fi
    fi
    log "Reinstall grub selesai."

    # Upgrade semua paket
    log "Menjalankan apt-get upgrade..."
    if ! apt-get upgrade -y --fix-missing >> "$LOG_FILE" 2>&1; then
        log_error "apt-get upgrade gagal!"
        exit 1
    fi
    log "apt-get upgrade selesai."

    # Update grub configuration
    log "Menjalankan update-grub..."
    if ! update-grub >> "$LOG_FILE" 2>&1; then
        log_warn "update-grub gagal. Melanjutkan proses..."
    fi
    log "update-grub selesai."

    log "Update sistem selesai."
}

# ============================================================================
# Reboot Sistem
# ============================================================================

do_reboot() {
    echo ""
    echo -e "${GREEN}=============================================="
    echo "  Update sistem berhasil!"
    echo "  Sistem akan reboot dalam 2 detik..."
    echo ""
    echo "  Setelah reboot, lanjutkan ke Tahap 2:"
    echo "  Jalankan script instalasi komponen VPN."
    echo -e "==============================================${NC}"
    echo ""

    log "Sistem akan reboot dalam 2 detik..."

    sleep 2
    reboot
}

# ============================================================================
# Main
# ============================================================================

main() {
    # Inisialisasi log
    echo "=== VPN Tunneling AutoScript — Tahap 1 ===" > "$LOG_FILE"
    echo "Waktu mulai: $(date '+%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
    echo "============================================" >> "$LOG_FILE"

    print_header

    # Pengecekan prasyarat
    log "Memulai pengecekan prasyarat..."
    check_root
    check_os
    check_arch
    check_virt
    log "Semua pengecekan prasyarat berhasil."

    echo ""
    echo -e "${BLUE}Semua prasyarat terpenuhi. Memulai update sistem...${NC}"
    echo ""

    # Proses update
    update_system

    # Reboot
    do_reboot
}

main "$@"
