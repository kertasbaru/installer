#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript Installer — Tahap 7: Menu Sistem & CLI Dashboard
# ============================================================================
# Script pembuatan menu interaktif dan CLI dashboard untuk mengelola semua
# layanan VPN yang terinstall. Membuat menu scripts di /usr/local/bin/ yang
# dapat diakses langsung dari terminal.
#
# Menu yang dibuat:
#   - Menu Utama (menu), Protocol Sub-menus (menu-ssh, menu-vmess, dll.)
#   - Menu Sistem, Backup, API, Bot, WARP, SoftEther
#   - Script utilitas: running, speedtest, vnstat
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
#   - Tahap 1-6 sudah dijalankan
#
# Penggunaan:
#   chmod +x setup-menu.sh
#   ./setup-menu.sh
#
# Referensi:
#   - https://github.com/FN-Rerechan02/Autoscript (AIO VPN script reference)
#   - https://github.com/mack-a/v2ray-agent (8-in-1 script reference)
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

# Config paths
DOMAIN_FILE="/etc/xray/domain"
XRAY_CONFIG="/etc/xray/config.json"
XRAY_CERT="/etc/xray/xray.crt"
# shellcheck disable=SC2034
XRAY_KEY="/etc/xray/xray.key"

# Account directories
ACCOUNT_DIR="/etc/vpnray/accounts"

# Menu script paths
MENU_BIN="/usr/local/bin/menu"
MENU_SSH_BIN="/usr/local/bin/menu-ssh"
MENU_VMESS_BIN="/usr/local/bin/menu-vmess"
MENU_VLESS_BIN="/usr/local/bin/menu-vless"
MENU_TROJAN_BIN="/usr/local/bin/menu-trojan"
MENU_SS_BIN="/usr/local/bin/menu-shadowsocks"
MENU_SOCKS_BIN="/usr/local/bin/menu-socks"
MENU_HYSTERIA2_BIN="/usr/local/bin/menu-hysteria2"
MENU_TROJAN_GO_BIN="/usr/local/bin/menu-trojan-go"
MENU_SOFTETHER_BIN="/usr/local/bin/menu-softether"
MENU_WARP_BIN="/usr/local/bin/menu-warp"
MENU_BACKUP_BIN="/usr/local/bin/menu-backup"
MENU_API_BIN="/usr/local/bin/menu-api"
MENU_BOT_BIN="/usr/local/bin/menu-bot"
MENU_SYSTEM_BIN="/usr/local/bin/menu-system"
RUNNING_BIN="/usr/local/bin/running"
SPEEDTEST_BIN="/usr/local/bin/speedtest"
BANDWIDTH_BIN="/usr/local/bin/vnstat"

# Menu functions source (deployed by this script)
MENU_FUNCTIONS="/etc/vpnray/menu-functions.sh"

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
    echo "  Tahap 7: Menu Sistem & CLI Dashboard"
    echo "=============================================="
    echo -e "${NC}"
}

# ============================================================================
# Pengecekan Prasyarat
# ============================================================================

check_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        log_error "Script ini harus dijalankan sebagai root!"
        echo -e "${RED}Gunakan: sudo ./setup-menu.sh${NC}"
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

check_tahap6() {
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

    # Cek Xray (Tahap 3/5)
    if ! command -v xray &>/dev/null && [[ ! -f /usr/local/bin/xray ]]; then
        log_error "Xray-core tidak terinstall. Tahap 3 belum dijalankan."
        missing=true
    fi

    # Cek Xray config (Tahap 5)
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

    # Cek Account directory (Tahap 6)
    if [[ ! -d "$ACCOUNT_DIR" ]]; then
        log_error "Direktori akun tidak ditemukan: $ACCOUNT_DIR"
        log_error "Tahap 6 belum dijalankan."
        missing=true
    fi

    # Cek account utility scripts (Tahap 6)
    if [[ ! -f /usr/local/bin/xp-ssh ]]; then
        log_warn "xp-ssh tidak ditemukan. Tahap 6 mungkin belum dijalankan."
    fi

    if [[ "$missing" == true ]]; then
        log_error "Pastikan Tahap 1-6 sudah dijalankan sebelum melanjutkan."
        exit 1
    fi

    log "Pengecekan Tahap 6: OK"
}

# ============================================================================
# Menu Utama — /usr/local/bin/menu
# ============================================================================

create_main_menu() {
    log "Membuat menu utama: $MENU_BIN"

    cat > "$MENU_BIN" <<'MENU_SCRIPT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Menu Utama (CLI Dashboard)
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'

DOMAIN_FILE="/etc/xray/domain"

get_domain() {
    if [[ -f "$DOMAIN_FILE" ]]; then
        cat "$DOMAIN_FILE"
    else
        echo "N/A"
    fi
}

get_ip() {
    local ip=""
    ip=$(curl -s --max-time 5 ifconfig.me 2>/dev/null)
    if [[ -z "$ip" ]]; then
        ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    fi
    echo "${ip:-N/A}"
}

get_isp() {
    local isp=""
    isp=$(curl -s --max-time 5 ipinfo.io/org 2>/dev/null)
    echo "${isp:-N/A}"
}

get_uptime_info() {
    uptime -p 2>/dev/null | sed 's/up //' || echo "N/A"
}

get_mem_usage() {
    free -m 2>/dev/null | awk '/Mem:/ {printf "%dMB / %dMB (%.1f%%)", $3, $2, $3/$2*100}'
}

get_cpu_load() {
    awk '{printf "%.2f, %.2f, %.2f", $1, $2, $3}' /proc/loadavg 2>/dev/null || echo "N/A"
}

get_os_info() {
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        source /etc/os-release
        echo "$PRETTY_NAME"
    else
        echo "Unknown"
    fi
}

get_kernel() {
    uname -r
}

show_menu() {
    clear
    local domain ip isp uptime_info mem_usage cpu_load os_info kernel
    domain=$(get_domain)
    ip=$(get_ip)
    isp=$(get_isp)
    uptime_info=$(get_uptime_info)
    mem_usage=$(get_mem_usage)
    cpu_load=$(get_cpu_load)
    os_info=$(get_os_info)
    kernel=$(get_kernel)

    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${WHITE}          ⚡ VPN TUNNELING AUTOSCRIPT ⚡          ${CYAN}│${NC}"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC} %-16s : ${GREEN}%-28s${NC} ${CYAN}│${NC}\n" "Hostname" "$(hostname)"
    printf "${CYAN}│${NC} %-16s : ${GREEN}%-28s${NC} ${CYAN}│${NC}\n" "Domain" "$domain"
    printf "${CYAN}│${NC} %-16s : ${GREEN}%-28s${NC} ${CYAN}│${NC}\n" "IP Address" "$ip"
    printf "${CYAN}│${NC} %-16s : ${GREEN}%-28s${NC} ${CYAN}│${NC}\n" "ISP" "$isp"
    printf "${CYAN}│${NC} %-16s : ${GREEN}%-28s${NC} ${CYAN}│${NC}\n" "OS" "$os_info"
    printf "${CYAN}│${NC} %-16s : ${GREEN}%-28s${NC} ${CYAN}│${NC}\n" "Kernel" "$kernel"
    printf "${CYAN}│${NC} %-16s : ${GREEN}%-28s${NC} ${CYAN}│${NC}\n" "Uptime" "$uptime_info"
    printf "${CYAN}│${NC} %-16s : ${GREEN}%-28s${NC} ${CYAN}│${NC}\n" "Memory" "$mem_usage"
    printf "${CYAN}│${NC} %-16s : ${GREEN}%-28s${NC} ${CYAN}│${NC}\n" "Load" "$cpu_load"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    echo -e "${CYAN}│${YELLOW}             PROTOCOL TUNNEL MENU               ${CYAN}│${NC}"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC}  ${WHITE}[1]${NC}  %-41s ${CYAN}│${NC}\n" "SSH & OpenVPN Menu"
    printf "${CYAN}│${NC}  ${WHITE}[2]${NC}  %-41s ${CYAN}│${NC}\n" "VMess Menu"
    printf "${CYAN}│${NC}  ${WHITE}[3]${NC}  %-41s ${CYAN}│${NC}\n" "VLESS Menu"
    printf "${CYAN}│${NC}  ${WHITE}[4]${NC}  %-41s ${CYAN}│${NC}\n" "Trojan Menu"
    printf "${CYAN}│${NC}  ${WHITE}[5]${NC}  %-41s ${CYAN}│${NC}\n" "Shadowsocks Menu"
    printf "${CYAN}│${NC}  ${WHITE}[6]${NC}  %-41s ${CYAN}│${NC}\n" "Socks Menu"
    printf "${CYAN}│${NC}  ${WHITE}[7]${NC}  %-41s ${CYAN}│${NC}\n" "Hysteria2 Menu"
    printf "${CYAN}│${NC}  ${WHITE}[8]${NC}  %-41s ${CYAN}│${NC}\n" "Trojan-Go Menu"
    printf "${CYAN}│${NC}  ${WHITE}[9]${NC}  %-41s ${CYAN}│${NC}\n" "SoftEther VPN Menu"
    printf "${CYAN}│${NC}  ${WHITE}[10]${NC} %-41s ${CYAN}│${NC}\n" "Cloudflare WARP Menu"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    echo -e "${CYAN}│${YELLOW}             MANAGEMENT & TOOLS                 ${CYAN}│${NC}"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC}  ${WHITE}[11]${NC} %-41s ${CYAN}│${NC}\n" "System & Server Settings"
    printf "${CYAN}│${NC}  ${WHITE}[12]${NC} %-41s ${CYAN}│${NC}\n" "Backup & Restore"
    printf "${CYAN}│${NC}  ${WHITE}[13]${NC} %-41s ${CYAN}│${NC}\n" "API & Bot Menu"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    echo -e "${CYAN}│${YELLOW}             QUICK TOOLS                        ${CYAN}│${NC}"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC}  ${WHITE}[14]${NC} %-41s ${CYAN}│${NC}\n" "Reboot VPS"
    printf "${CYAN}│${NC}  ${WHITE}[15]${NC} %-41s ${CYAN}│${NC}\n" "Running Services"
    printf "${CYAN}│${NC}  ${WHITE}[16]${NC} %-41s ${CYAN}│${NC}\n" "Speedtest"
    printf "${CYAN}│${NC}  ${WHITE}[17]${NC} %-41s ${CYAN}│${NC}\n" "vnStat Bandwidth"
    printf "${CYAN}│${NC}  ${WHITE}[18]${NC} %-41s ${CYAN}│${NC}\n" "Script Info"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC}  ${RED}[0]${NC}  %-41s ${CYAN}│${NC}\n" "Exit"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo ""
}

show_script_info() {
    clear
    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${WHITE}          ⚡ SCRIPT INFORMATION ⚡               ${CYAN}│${NC}"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC}  %-45s ${CYAN}│${NC}\n" "VPN Tunneling AutoScript Installer"
    printf "${CYAN}│${NC}  %-45s ${CYAN}│${NC}\n" "Version : 1.0.0"
    printf "${CYAN}│${NC}  %-45s ${CYAN}│${NC}\n" "Author  : AutoScript Team"
    printf "${CYAN}│${NC}  %-45s ${CYAN}│${NC}\n" "License : MIT"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC}  %-45s ${CYAN}│${NC}\n" "Supported Protocols:"
    printf "${CYAN}│${NC}    %-43s ${CYAN}│${NC}\n" "SSH, VMess, VLESS, Trojan, Shadowsocks"
    printf "${CYAN}│${NC}    %-43s ${CYAN}│${NC}\n" "Socks, Hysteria2, Trojan-Go, SoftEther"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo ""
    read -rp "Tekan Enter untuk kembali..."
}

handle_choice() {
    local choice="$1"
    case "$choice" in
        1) menu-ssh ;;
        2) menu-vmess ;;
        3) menu-vless ;;
        4) menu-trojan ;;
        5) menu-shadowsocks ;;
        6) menu-socks ;;
        7) menu-hysteria2 ;;
        8) menu-trojan-go ;;
        9) menu-softether ;;
        10) menu-warp ;;
        11) menu-system ;;
        12) menu-backup ;;
        13)
            echo -e "\n${CYAN}┌───────────────────────────────┐${NC}"
            printf "${CYAN}│${NC}  ${WHITE}[1]${NC} %-24s ${CYAN}│${NC}\n" "API Menu"
            printf "${CYAN}│${NC}  ${WHITE}[2]${NC} %-24s ${CYAN}│${NC}\n" "Bot Menu"
            printf "${CYAN}│${NC}  ${RED}[0]${NC} %-24s ${CYAN}│${NC}\n" "Kembali"
            echo -e "${CYAN}└───────────────────────────────┘${NC}"
            read -rp "Pilih: " sub
            case "$sub" in
                1) menu-api ;;
                2) menu-bot ;;
                0) return ;;
                *) echo -e "${RED}Input tidak valid!${NC}" ;;
            esac
            ;;
        14)
            echo -e "${YELLOW}VPS akan direboot dalam 5 detik...${NC}"
            echo -e "${YELLOW}Tekan Ctrl+C untuk membatalkan.${NC}"
            sleep 5
            reboot
            ;;
        15) running ;;
        16) speedtest ;;
        17) vnstat ;;
        18) show_script_info ;;
        0)
            echo -e "${GREEN}Terima kasih! Goodbye.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Input tidak valid! Silakan pilih 0-18.${NC}"
            sleep 1
            ;;
    esac
}

# Main loop
while true; do
    show_menu
    read -rp "Pilih Menu [0-18]: " choice
    handle_choice "$choice"
    if [[ "$choice" != "0" ]]; then
        echo ""
        read -rp "Tekan Enter untuk kembali ke menu utama..."
    fi
done
MENU_SCRIPT

    chmod +x "$MENU_BIN"
    log "Menu utama berhasil dibuat: $MENU_BIN"
}

# ============================================================================
# Generic Protocol Menu Generator
# ============================================================================

create_protocol_menu() {
    local protocol="$1"
    local display_name="$2"
    local output_path="$3"

    log "Membuat menu $display_name: $output_path"

    cat > "$output_path" <<PROTOCOL_MENU_SCRIPT
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Menu ${display_name}
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'

PROTOCOL="${protocol}"
DISPLAY_NAME="${display_name}"
DOMAIN_FILE="/etc/xray/domain"
ACCOUNT_DIR="/etc/vpnray/accounts/${protocol}"
MENU_FUNCTIONS="/etc/vpnray/menu-functions.sh"

get_domain() {
    if [[ -f "\$DOMAIN_FILE" ]]; then
        cat "\$DOMAIN_FILE"
    else
        echo "N/A"
    fi
}

get_ip() {
    local ip=""
    ip=\$(curl -s --max-time 5 ifconfig.me 2>/dev/null)
    if [[ -z "\$ip" ]]; then
        ip=\$(hostname -I 2>/dev/null | awk '{print \$1}')
    fi
    echo "\${ip:-N/A}"
}

get_uptime_info() {
    uptime -p 2>/dev/null | sed 's/up //' || echo "N/A"
}

count_accounts() {
    if [[ -d "\$ACCOUNT_DIR" ]]; then
        find "\$ACCOUNT_DIR" -name "*.json" -type f 2>/dev/null | wc -l
    else
        echo "0"
    fi
}

count_active_accounts() {
    local count=0
    if [[ -d "\$ACCOUNT_DIR" ]] && command -v jq &>/dev/null; then
        while IFS= read -r f; do
            [[ -f "\$f" ]] || continue
            local status
            status=\$(jq -r '.status' "\$f" 2>/dev/null)
            if [[ "\$status" == "active" ]]; then
                ((count++))
            fi
        done < <(find "\$ACCOUNT_DIR" -name "*.json" -type f 2>/dev/null)
    fi
    echo "\$count"
}

call_account_function() {
    local action="\$1"
    if [[ -f "\$MENU_FUNCTIONS" ]]; then
        # shellcheck source=/dev/null
        source "\$MENU_FUNCTIONS"
        local func_name="\${action}_\${PROTOCOL}_account"
        if declare -f "\$func_name" &>/dev/null; then
            "\$func_name"
        else
            echo -e "\${YELLOW}Fungsi \$func_name belum tersedia.${NC}"
            echo -e "\${YELLOW}Fitur ini akan tersedia setelah Tahap 8.${NC}"
        fi
    else
        echo -e "\${YELLOW}Menu functions belum terinstall: \$MENU_FUNCTIONS${NC}"
        echo -e "\${YELLOW}Fitur ini akan tersedia setelah konfigurasi lengkap.${NC}"
    fi
}

show_menu() {
    clear
    local domain ip uptime_info total_accounts active_accounts
    domain=\$(get_domain)
    ip=\$(get_ip)
    uptime_info=\$(get_uptime_info)
    total_accounts=\$(count_accounts)
    active_accounts=\$(count_active_accounts)

    echo -e "\${CYAN}┌─────────────────────────────────────────────────┐\${NC}"
    echo -e "\${CYAN}│\${WHITE}          ⚡ \${DISPLAY_NAME} MENU ⚡\${NC}"
    echo -e "\${CYAN}│─────────────────────────────────────────────────│\${NC}"
    printf "\${CYAN}│\${NC} %-16s : \${GREEN}%-28s\${NC} \${CYAN}│\${NC}\n" "Domain" "\$domain"
    printf "\${CYAN}│\${NC} %-16s : \${GREEN}%-28s\${NC} \${CYAN}│\${NC}\n" "IP Address" "\$ip"
    printf "\${CYAN}│\${NC} %-16s : \${GREEN}%-28s\${NC} \${CYAN}│\${NC}\n" "Uptime" "\$uptime_info"
    printf "\${CYAN}│\${NC} %-16s : \${GREEN}%-28s\${NC} \${CYAN}│\${NC}\n" "Total Accounts" "\$total_accounts"
    printf "\${CYAN}│\${NC} %-16s : \${GREEN}%-28s\${NC} \${CYAN}│\${NC}\n" "Active Accounts" "\$active_accounts"
    echo -e "\${CYAN}│─────────────────────────────────────────────────│\${NC}"
    echo -e "\${CYAN}│\${YELLOW}             ACCOUNT MANAGEMENT                 \${CYAN}│\${NC}"
    echo -e "\${CYAN}│─────────────────────────────────────────────────│\${NC}"
    printf "\${CYAN}│\${NC}  \${WHITE}[1]${NC}  %-41s \${CYAN}│\${NC}\n" "Create Account"
    printf "\${CYAN}│\${NC}  \${WHITE}[2]${NC}  %-41s \${CYAN}│\${NC}\n" "Bulk Create"
    printf "\${CYAN}│\${NC}  \${WHITE}[3]${NC}  %-41s \${CYAN}│\${NC}\n" "Delete Account"
    printf "\${CYAN}│\${NC}  \${WHITE}[4]${NC}  %-41s \${CYAN}│\${NC}\n" "Extend / Renew"
    printf "\${CYAN}│\${NC}  \${WHITE}[5]${NC}  %-41s \${CYAN}│\${NC}\n" "Check User Login"
    printf "\${CYAN}│\${NC}  \${WHITE}[6]${NC}  %-41s \${CYAN}│\${NC}\n" "User Details"
    printf "\${CYAN}│\${NC}  \${WHITE}[7]${NC}  %-41s \${CYAN}│\${NC}\n" "Lock Account"
    printf "\${CYAN}│\${NC}  \${WHITE}[8]${NC}  %-41s \${CYAN}│\${NC}\n" "Unlock Account"
    printf "\${CYAN}│\${NC}  \${WHITE}[9]${NC}  %-41s \${CYAN}│\${NC}\n" "Limit IP Login"
    printf "\${CYAN}│\${NC}  \${WHITE}[10]${NC} %-41s \${CYAN}│\${NC}\n" "Limit Quota"
    printf "\${CYAN}│\${NC}  \${WHITE}[11]${NC} %-41s \${CYAN}│\${NC}\n" "Ban Account"
    printf "\${CYAN}│\${NC}  \${WHITE}[12]${NC} %-41s \${CYAN}│\${NC}\n" "Unban Account"
    printf "\${CYAN}│\${NC}  \${WHITE}[13]${NC} %-41s \${CYAN}│\${NC}\n" "Recover Expired"
    printf "\${CYAN}│\${NC}  \${WHITE}[14]${NC} %-41s \${CYAN}│\${NC}\n" "List All Members"
    echo -e "\${CYAN}│─────────────────────────────────────────────────│\${NC}"
    printf "\${CYAN}│\${NC}  \${RED}[0]${NC}  %-41s \${CYAN}│\${NC}\n" "Back to Main Menu"
    echo -e "\${CYAN}└─────────────────────────────────────────────────┘\${NC}"
    echo ""
}

handle_choice() {
    local choice="\$1"
    case "\$choice" in
        1) call_account_function "create" ;;
        2) call_account_function "bulk_create" ;;
        3) call_account_function "delete" ;;
        4) call_account_function "extend" ;;
        5) call_account_function "check_login" ;;
        6) call_account_function "detail" ;;
        7) call_account_function "lock" ;;
        8) call_account_function "unlock" ;;
        9) call_account_function "limit_ip" ;;
        10) call_account_function "limit_quota" ;;
        11) call_account_function "ban" ;;
        12) call_account_function "unban" ;;
        13) call_account_function "recover" ;;
        14) call_account_function "list" ;;
        0) exit 0 ;;
        *)
            echo -e "\${RED}Input tidak valid! Silakan pilih 0-14.\${NC}"
            sleep 1
            ;;
    esac
}

# Main loop
while true; do
    show_menu
    read -rp "Pilih Menu [0-14]: " choice
    handle_choice "\$choice"
    if [[ "\$choice" != "0" ]]; then
        echo ""
        read -rp "Tekan Enter untuk kembali..."
    fi
done
PROTOCOL_MENU_SCRIPT

    chmod +x "$output_path"
    log "Menu $display_name berhasil dibuat: $output_path"
}

# ============================================================================
# Protocol Sub-Menu Wrappers
# ============================================================================

create_ssh_menu() {
    create_protocol_menu "ssh" "SSH & OpenVPN" "$MENU_SSH_BIN"
}

create_vmess_menu() {
    create_protocol_menu "vmess" "VMess" "$MENU_VMESS_BIN"
}

create_vless_menu() {
    create_protocol_menu "vless" "VLESS" "$MENU_VLESS_BIN"
}

create_trojan_menu() {
    create_protocol_menu "trojan" "Trojan" "$MENU_TROJAN_BIN"
}

create_shadowsocks_menu() {
    create_protocol_menu "shadowsocks" "Shadowsocks" "$MENU_SS_BIN"
}

create_socks_menu() {
    create_protocol_menu "socks" "Socks" "$MENU_SOCKS_BIN"
}

create_hysteria2_menu() {
    create_protocol_menu "hysteria2" "Hysteria2" "$MENU_HYSTERIA2_BIN"
}

create_trojan_go_menu() {
    create_protocol_menu "trojan-go" "Trojan-Go" "$MENU_TROJAN_GO_BIN"
}

# ============================================================================
# Menu SoftEther — /usr/local/bin/menu-softether
# ============================================================================

create_softether_menu() {
    log "Membuat menu SoftEther: $MENU_SOFTETHER_BIN"

    cat > "$MENU_SOFTETHER_BIN" <<'SOFTETHER_SCRIPT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Menu SoftEther VPN
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

get_softether_status() {
    if systemctl is-active --quiet softether-vpnserver 2>/dev/null; then
        echo -e "${GREEN}Running${NC}"
    elif [[ -f /usr/local/vpnserver/vpnserver ]]; then
        echo -e "${RED}Stopped${NC}"
    else
        echo -e "${YELLOW}Not Installed${NC}"
    fi
}

show_menu() {
    clear
    local status
    status=$(get_softether_status)

    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${WHITE}          ⚡ SOFTETHER VPN MENU ⚡               ${CYAN}│${NC}"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC} %-16s : %-30b ${CYAN}│${NC}\n" "Status" "$status"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC}  ${WHITE}[1]${NC}  %-41s ${CYAN}│${NC}\n" "SoftEther Status"
    printf "${CYAN}│${NC}  ${WHITE}[2]${NC}  %-41s ${CYAN}│${NC}\n" "Start SoftEther"
    printf "${CYAN}│${NC}  ${WHITE}[3]${NC}  %-41s ${CYAN}│${NC}\n" "Stop SoftEther"
    printf "${CYAN}│${NC}  ${WHITE}[4]${NC}  %-41s ${CYAN}│${NC}\n" "Restart SoftEther"
    printf "${CYAN}│${NC}  ${WHITE}[5]${NC}  %-41s ${CYAN}│${NC}\n" "SoftEther Config"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC}  ${RED}[0]${NC}  %-41s ${CYAN}│${NC}\n" "Back to Main Menu"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo ""
}

handle_choice() {
    local choice="$1"
    case "$choice" in
        1)
            echo -e "\n${CYAN}=== SoftEther VPN Status ===${NC}"
            if systemctl is-active --quiet softether-vpnserver 2>/dev/null; then
                systemctl status softether-vpnserver --no-pager
            elif [[ -f /usr/local/vpnserver/vpnserver ]]; then
                /usr/local/vpnserver/vpnserver status
            else
                echo -e "${YELLOW}SoftEther VPN belum terinstall.${NC}"
            fi
            ;;
        2)
            echo -e "${GREEN}Memulai SoftEther VPN...${NC}"
            if systemctl start softether-vpnserver 2>/dev/null; then
                echo -e "${GREEN}SoftEther VPN berhasil dimulai.${NC}"
            elif [[ -f /usr/local/vpnserver/vpnserver ]]; then
                /usr/local/vpnserver/vpnserver start
            else
                echo -e "${RED}SoftEther VPN belum terinstall.${NC}"
            fi
            ;;
        3)
            echo -e "${YELLOW}Menghentikan SoftEther VPN...${NC}"
            if systemctl stop softether-vpnserver 2>/dev/null; then
                echo -e "${GREEN}SoftEther VPN berhasil dihentikan.${NC}"
            elif [[ -f /usr/local/vpnserver/vpnserver ]]; then
                /usr/local/vpnserver/vpnserver stop
            else
                echo -e "${RED}SoftEther VPN belum terinstall.${NC}"
            fi
            ;;
        4)
            echo -e "${YELLOW}Merestart SoftEther VPN...${NC}"
            if systemctl restart softether-vpnserver 2>/dev/null; then
                echo -e "${GREEN}SoftEther VPN berhasil direstart.${NC}"
            elif [[ -f /usr/local/vpnserver/vpnserver ]]; then
                /usr/local/vpnserver/vpnserver stop
                sleep 2
                /usr/local/vpnserver/vpnserver start
            else
                echo -e "${RED}SoftEther VPN belum terinstall.${NC}"
            fi
            ;;
        5)
            echo -e "\n${CYAN}=== SoftEther VPN Configuration ===${NC}"
            if [[ -f /usr/local/vpnserver/vpn_server.config ]]; then
                echo -e "${GREEN}Config file: /usr/local/vpnserver/vpn_server.config${NC}"
                echo -e "${YELLOW}Gunakan SoftEther Server Manager untuk konfigurasi GUI.${NC}"
                echo ""
                echo "Listener ports:"
                grep -i "listenport" /usr/local/vpnserver/vpn_server.config 2>/dev/null | head -5
            else
                echo -e "${YELLOW}Config SoftEther tidak ditemukan.${NC}"
            fi
            ;;
        0) exit 0 ;;
        *)
            echo -e "${RED}Input tidak valid! Silakan pilih 0-5.${NC}"
            sleep 1
            ;;
    esac
}

while true; do
    show_menu
    read -rp "Pilih Menu [0-5]: " choice
    handle_choice "$choice"
    if [[ "$choice" != "0" ]]; then
        echo ""
        read -rp "Tekan Enter untuk kembali..."
    fi
done
SOFTETHER_SCRIPT

    chmod +x "$MENU_SOFTETHER_BIN"
    log "Menu SoftEther berhasil dibuat: $MENU_SOFTETHER_BIN"
}

# ============================================================================
# Menu WARP — /usr/local/bin/menu-warp
# ============================================================================

create_warp_menu() {
    log "Membuat menu WARP: $MENU_WARP_BIN"

    cat > "$MENU_WARP_BIN" <<'WARP_SCRIPT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Menu Cloudflare WARP
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

get_warp_status() {
    if command -v warp-cli &>/dev/null; then
        local status
        status=$(warp-cli --accept-tos status 2>/dev/null | grep -i "status" | head -1)
        if echo "$status" | grep -qi "connected"; then
            echo -e "${GREEN}Connected${NC}"
        else
            echo -e "${YELLOW}Disconnected${NC}"
        fi
    else
        echo -e "${RED}Not Installed${NC}"
    fi
}

get_warp_mode() {
    if command -v warp-cli &>/dev/null; then
        warp-cli --accept-tos settings 2>/dev/null | grep -i "mode" | head -1 | awk '{print $NF}'
    else
        echo "N/A"
    fi
}

show_menu() {
    clear
    local status mode
    status=$(get_warp_status)
    mode=$(get_warp_mode)

    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${WHITE}          ⚡ CLOUDFLARE WARP MENU ⚡             ${CYAN}│${NC}"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC} %-16s : %-30b ${CYAN}│${NC}\n" "WARP Status" "$status"
    printf "${CYAN}│${NC} %-16s : ${GREEN}%-28s${NC} ${CYAN}│${NC}\n" "WARP Mode" "$mode"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC}  ${WHITE}[1]${NC}  %-41s ${CYAN}│${NC}\n" "Enable WARP"
    printf "${CYAN}│${NC}  ${WHITE}[2]${NC}  %-41s ${CYAN}│${NC}\n" "Disable WARP"
    printf "${CYAN}│${NC}  ${WHITE}[3]${NC}  %-41s ${CYAN}│${NC}\n" "WARP Status"
    printf "${CYAN}│${NC}  ${WHITE}[4]${NC}  %-41s ${CYAN}│${NC}\n" "Change WARP Mode"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC}  ${RED}[0]${NC}  %-41s ${CYAN}│${NC}\n" "Back to Main Menu"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo ""
}

handle_choice() {
    local choice="$1"
    case "$choice" in
        1)
            if ! command -v warp-cli &>/dev/null; then
                echo -e "${RED}Cloudflare WARP belum terinstall.${NC}"
                echo -e "${YELLOW}Install dengan: curl https://pkg.cloudflareclient.com/install.sh | bash${NC}"
            else
                echo -e "${GREEN}Mengaktifkan WARP...${NC}"
                warp-cli --accept-tos connect 2>/dev/null
                sleep 2
                echo -e "${GREEN}WARP berhasil diaktifkan.${NC}"
                warp-cli --accept-tos status 2>/dev/null
            fi
            ;;
        2)
            if ! command -v warp-cli &>/dev/null; then
                echo -e "${RED}Cloudflare WARP belum terinstall.${NC}"
            else
                echo -e "${YELLOW}Menonaktifkan WARP...${NC}"
                warp-cli --accept-tos disconnect 2>/dev/null
                echo -e "${GREEN}WARP berhasil dinonaktifkan.${NC}"
            fi
            ;;
        3)
            echo -e "\n${CYAN}=== Cloudflare WARP Status ===${NC}"
            if command -v warp-cli &>/dev/null; then
                warp-cli --accept-tos status 2>/dev/null
                echo ""
                warp-cli --accept-tos settings 2>/dev/null
            else
                echo -e "${RED}Cloudflare WARP belum terinstall.${NC}"
            fi
            ;;
        4)
            if ! command -v warp-cli &>/dev/null; then
                echo -e "${RED}Cloudflare WARP belum terinstall.${NC}"
            else
                echo -e "${CYAN}Mode yang tersedia:${NC}"
                echo "  1. warp      - Full tunnel"
                echo "  2. doh       - DNS over HTTPS only"
                echo "  3. warp+doh  - WARP with DNS over HTTPS"
                echo "  4. dot       - DNS over TLS"
                echo "  5. proxy     - Local SOCKS5 proxy"
                read -rp "Pilih mode [1-5]: " mode_choice
                case "$mode_choice" in
                    1) warp-cli --accept-tos set-mode warp 2>/dev/null ;;
                    2) warp-cli --accept-tos set-mode doh 2>/dev/null ;;
                    3) warp-cli --accept-tos set-mode warp+doh 2>/dev/null ;;
                    4) warp-cli --accept-tos set-mode dot 2>/dev/null ;;
                    5) warp-cli --accept-tos set-mode proxy 2>/dev/null ;;
                    *) echo -e "${RED}Mode tidak valid!${NC}" ;;
                esac
                echo -e "${GREEN}Mode WARP berhasil diubah.${NC}"
            fi
            ;;
        0) exit 0 ;;
        *)
            echo -e "${RED}Input tidak valid! Silakan pilih 0-4.${NC}"
            sleep 1
            ;;
    esac
}

while true; do
    show_menu
    read -rp "Pilih Menu [0-4]: " choice
    handle_choice "$choice"
    if [[ "$choice" != "0" ]]; then
        echo ""
        read -rp "Tekan Enter untuk kembali..."
    fi
done
WARP_SCRIPT

    chmod +x "$MENU_WARP_BIN"
    log "Menu WARP berhasil dibuat: $MENU_WARP_BIN"
}

# ============================================================================
# Menu Backup — /usr/local/bin/menu-backup
# ============================================================================

create_backup_menu() {
    log "Membuat menu Backup: $MENU_BACKUP_BIN"

    cat > "$MENU_BACKUP_BIN" <<'BACKUP_SCRIPT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Menu Backup & Restore
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

BACKUP_DIR="/root/backup"
RCLONE_CONFIG="/root/.config/rclone/rclone.conf"

show_menu() {
    clear
    local rclone_status
    if command -v rclone &>/dev/null; then
        rclone_status="${GREEN}Installed${NC}"
    else
        rclone_status="${RED}Not Installed${NC}"
    fi

    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${WHITE}          ⚡ BACKUP & RESTORE MENU ⚡            ${CYAN}│${NC}"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC} %-16s : %-30b ${CYAN}│${NC}\n" "Rclone" "$rclone_status"
    printf "${CYAN}│${NC} %-16s : ${GREEN}%-28s${NC} ${CYAN}│${NC}\n" "Backup Dir" "$BACKUP_DIR"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC}  ${WHITE}[1]${NC}  %-41s ${CYAN}│${NC}\n" "Backup Data"
    printf "${CYAN}│${NC}  ${WHITE}[2]${NC}  %-41s ${CYAN}│${NC}\n" "Restore Data"
    printf "${CYAN}│${NC}  ${WHITE}[3]${NC}  %-41s ${CYAN}│${NC}\n" "Setup Rclone"
    printf "${CYAN}│${NC}  ${WHITE}[4]${NC}  %-41s ${CYAN}│${NC}\n" "Auto Backup Settings"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC}  ${RED}[0]${NC}  %-41s ${CYAN}│${NC}\n" "Back to Main Menu"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo ""
}

do_backup() {
    echo -e "${GREEN}Memulai backup data...${NC}"
    mkdir -p "$BACKUP_DIR"

    local timestamp
    timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="$BACKUP_DIR/backup_${timestamp}.tar.gz"

    local dirs_to_backup=()
    [[ -d /etc/vpnray ]] && dirs_to_backup+=("/etc/vpnray")
    [[ -d /etc/xray ]] && dirs_to_backup+=("/etc/xray")
    [[ -f /etc/haproxy/haproxy.cfg ]] && dirs_to_backup+=("/etc/haproxy/haproxy.cfg")
    [[ -f /etc/stunnel/stunnel.conf ]] && dirs_to_backup+=("/etc/stunnel/stunnel.conf")
    [[ -f /etc/squid/squid.conf ]] && dirs_to_backup+=("/etc/squid/squid.conf")
    [[ -d /etc/openvpn ]] && dirs_to_backup+=("/etc/openvpn")
    [[ -f /etc/nginx/nginx.conf ]] && dirs_to_backup+=("/etc/nginx/nginx.conf")
    [[ -d /etc/nginx/conf.d ]] && dirs_to_backup+=("/etc/nginx/conf.d")

    if [[ ${#dirs_to_backup[@]} -eq 0 ]]; then
        echo -e "${RED}Tidak ada data untuk dibackup.${NC}"
        return
    fi

    tar -czf "$backup_file" "${dirs_to_backup[@]}" 2>/dev/null
    echo -e "${GREEN}Backup berhasil disimpan: $backup_file${NC}"

    if command -v rclone &>/dev/null && [[ -f "$RCLONE_CONFIG" ]]; then
        read -rp "Upload ke cloud storage? (y/n): " upload
        if [[ "$upload" == "y" || "$upload" == "Y" ]]; then
            local remote
            remote=$(rclone listremotes 2>/dev/null | head -1)
            if [[ -n "$remote" ]]; then
                echo -e "${GREEN}Uploading ke ${remote}...${NC}"
                rclone copy "$backup_file" "${remote}vpn-backup/" 2>/dev/null
                echo -e "${GREEN}Upload selesai.${NC}"
            else
                echo -e "${RED}Tidak ada remote yang dikonfigurasi.${NC}"
            fi
        fi
    fi
}

do_restore() {
    echo -e "${CYAN}=== Daftar Backup ===${NC}"
    if [[ ! -d "$BACKUP_DIR" ]] || [[ -z "$(ls -A "$BACKUP_DIR"/*.tar.gz 2>/dev/null)" ]]; then
        echo -e "${YELLOW}Tidak ada file backup ditemukan di $BACKUP_DIR${NC}"
        echo ""
        read -rp "Masukkan path file backup: " backup_path
        if [[ ! -f "$backup_path" ]]; then
            echo -e "${RED}File tidak ditemukan: $backup_path${NC}"
            return
        fi
    else
        local i=1
        declare -a backup_files
        while IFS= read -r f; do
            printf "  [%d] %s\n" "$i" "$(basename "$f")"
            backup_files[$i]="$f"
            ((i++))
        done < <(ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null)
        echo ""
        read -rp "Pilih nomor backup: " num
        backup_path="${backup_files[$num]}"
        if [[ -z "$backup_path" || ! -f "$backup_path" ]]; then
            echo -e "${RED}Pilihan tidak valid.${NC}"
            return
        fi
    fi

    echo -e "${YELLOW}Merestore dari: $(basename "$backup_path")${NC}"
    read -rp "Lanjutkan restore? Data lama akan ditimpa! (y/n): " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        tar -xzf "$backup_path" -C / 2>/dev/null
        echo -e "${GREEN}Restore berhasil. Silakan restart service yang diperlukan.${NC}"
    else
        echo -e "${YELLOW}Restore dibatalkan.${NC}"
    fi
}

setup_rclone() {
    if ! command -v rclone &>/dev/null; then
        echo -e "${GREEN}Menginstall Rclone...${NC}"
        curl -fsSL https://rclone.org/install.sh | bash 2>/dev/null
        if command -v rclone &>/dev/null; then
            echo -e "${GREEN}Rclone berhasil diinstall.${NC}"
        else
            echo -e "${RED}Gagal menginstall Rclone.${NC}"
            return
        fi
    fi
    echo -e "${CYAN}Menjalankan konfigurasi Rclone...${NC}"
    rclone config
}

setup_auto_backup() {
    echo -e "${CYAN}=== Auto Backup Settings ===${NC}"
    echo "  [1] Aktifkan Auto Backup (Daily)"
    echo "  [2] Aktifkan Auto Backup (Weekly)"
    echo "  [3] Nonaktifkan Auto Backup"
    echo "  [4] Lihat Status Auto Backup"
    read -rp "Pilih: " ab_choice
    case "$ab_choice" in
        1)
            echo "0 2 * * * root /usr/local/bin/menu-backup --auto-backup" > /etc/cron.d/auto-backup-vpn
            chmod 644 /etc/cron.d/auto-backup-vpn
            echo -e "${GREEN}Auto backup harian diaktifkan (02:00 setiap hari).${NC}"
            ;;
        2)
            echo "0 2 * * 0 root /usr/local/bin/menu-backup --auto-backup" > /etc/cron.d/auto-backup-vpn
            chmod 644 /etc/cron.d/auto-backup-vpn
            echo -e "${GREEN}Auto backup mingguan diaktifkan (Minggu 02:00).${NC}"
            ;;
        3)
            rm -f /etc/cron.d/auto-backup-vpn
            echo -e "${GREEN}Auto backup dinonaktifkan.${NC}"
            ;;
        4)
            if [[ -f /etc/cron.d/auto-backup-vpn ]]; then
                echo -e "${GREEN}Auto backup aktif:${NC}"
                cat /etc/cron.d/auto-backup-vpn
            else
                echo -e "${YELLOW}Auto backup tidak aktif.${NC}"
            fi
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid.${NC}"
            ;;
    esac
}

# Handle --auto-backup flag for cron
if [[ "$1" == "--auto-backup" ]]; then
    mkdir -p "$BACKUP_DIR"
    timestamp=$(date '+%Y%m%d_%H%M%S')
    backup_file="$BACKUP_DIR/backup_${timestamp}.tar.gz"
    dirs=()
    [[ -d /etc/vpnray ]] && dirs+=("/etc/vpnray")
    [[ -d /etc/xray ]] && dirs+=("/etc/xray")
    [[ -d /etc/openvpn ]] && dirs+=("/etc/openvpn")
    if [[ ${#dirs[@]} -gt 0 ]]; then
        tar -czf "$backup_file" "${dirs[@]}" 2>/dev/null
        # Upload if rclone is configured
        if command -v rclone &>/dev/null && [[ -f "$RCLONE_CONFIG" ]]; then
            remote=$(rclone listremotes 2>/dev/null | head -1)
            if [[ -n "$remote" ]]; then
                rclone copy "$backup_file" "${remote}vpn-backup/" 2>/dev/null
            fi
        fi
    fi
    # Keep only last 7 backups
    ls -t "$BACKUP_DIR"/backup_*.tar.gz 2>/dev/null | tail -n +8 | xargs rm -f 2>/dev/null
    exit 0
fi

handle_choice() {
    local choice="$1"
    case "$choice" in
        1) do_backup ;;
        2) do_restore ;;
        3) setup_rclone ;;
        4) setup_auto_backup ;;
        0) exit 0 ;;
        *)
            echo -e "${RED}Input tidak valid! Silakan pilih 0-4.${NC}"
            sleep 1
            ;;
    esac
}

while true; do
    show_menu
    read -rp "Pilih Menu [0-4]: " choice
    handle_choice "$choice"
    if [[ "$choice" != "0" ]]; then
        echo ""
        read -rp "Tekan Enter untuk kembali..."
    fi
done
BACKUP_SCRIPT

    chmod +x "$MENU_BACKUP_BIN"
    log "Menu Backup berhasil dibuat: $MENU_BACKUP_BIN"
}

# ============================================================================
# Menu API — /usr/local/bin/menu-api
# ============================================================================

create_api_menu() {
    log "Membuat menu API: $MENU_API_BIN"

    cat > "$MENU_API_BIN" <<'API_SCRIPT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Menu REST API
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

API_CONFIG="/etc/vpnray/api.conf"
API_SERVICE="vpnray-api"

get_api_status() {
    if systemctl is-active --quiet "$API_SERVICE" 2>/dev/null; then
        echo -e "${GREEN}Running${NC}"
    else
        echo -e "${RED}Stopped${NC}"
    fi
}

get_api_port() {
    if [[ -f "$API_CONFIG" ]]; then
        grep -i "^port=" "$API_CONFIG" 2>/dev/null | cut -d= -f2
    else
        echo "8443"
    fi
}

show_menu() {
    clear
    local status port
    status=$(get_api_status)
    port=$(get_api_port)

    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${WHITE}          ⚡ REST API MENU ⚡                    ${CYAN}│${NC}"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC} %-16s : %-30b ${CYAN}│${NC}\n" "API Status" "$status"
    printf "${CYAN}│${NC} %-16s : ${GREEN}%-28s${NC} ${CYAN}│${NC}\n" "API Port" "$port"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC}  ${WHITE}[1]${NC}  %-41s ${CYAN}│${NC}\n" "Start API Server"
    printf "${CYAN}│${NC}  ${WHITE}[2]${NC}  %-41s ${CYAN}│${NC}\n" "Stop API Server"
    printf "${CYAN}│${NC}  ${WHITE}[3]${NC}  %-41s ${CYAN}│${NC}\n" "Restart API Server"
    printf "${CYAN}│${NC}  ${WHITE}[4]${NC}  %-41s ${CYAN}│${NC}\n" "API Status"
    printf "${CYAN}│${NC}  ${WHITE}[5]${NC}  %-41s ${CYAN}│${NC}\n" "Change API Port"
    printf "${CYAN}│${NC}  ${WHITE}[6]${NC}  %-41s ${CYAN}│${NC}\n" "Generate API Key"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC}  ${RED}[0]${NC}  %-41s ${CYAN}│${NC}\n" "Back to Main Menu"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo ""
}

handle_choice() {
    local choice="$1"
    case "$choice" in
        1)
            echo -e "${GREEN}Memulai API Server...${NC}"
            if systemctl start "$API_SERVICE" 2>/dev/null; then
                echo -e "${GREEN}API Server berhasil dimulai.${NC}"
            else
                echo -e "${RED}Gagal memulai API Server. Pastikan service sudah dikonfigurasi.${NC}"
            fi
            ;;
        2)
            echo -e "${YELLOW}Menghentikan API Server...${NC}"
            if systemctl stop "$API_SERVICE" 2>/dev/null; then
                echo -e "${GREEN}API Server berhasil dihentikan.${NC}"
            else
                echo -e "${RED}Gagal menghentikan API Server.${NC}"
            fi
            ;;
        3)
            echo -e "${YELLOW}Merestart API Server...${NC}"
            if systemctl restart "$API_SERVICE" 2>/dev/null; then
                echo -e "${GREEN}API Server berhasil direstart.${NC}"
            else
                echo -e "${RED}Gagal merestart API Server.${NC}"
            fi
            ;;
        4)
            echo -e "\n${CYAN}=== API Server Status ===${NC}"
            if systemctl is-active --quiet "$API_SERVICE" 2>/dev/null; then
                systemctl status "$API_SERVICE" --no-pager
            else
                echo -e "${YELLOW}API Server tidak berjalan.${NC}"
            fi
            ;;
        5)
            read -rp "Masukkan port baru untuk API: " new_port
            if [[ "$new_port" =~ ^[0-9]+$ ]] && [[ "$new_port" -ge 1024 ]] && [[ "$new_port" -le 65535 ]]; then
                mkdir -p "$(dirname "$API_CONFIG")"
                if [[ -f "$API_CONFIG" ]]; then
                    sed -i "s/^port=.*/port=$new_port/" "$API_CONFIG"
                else
                    echo "port=$new_port" > "$API_CONFIG"
                fi
                echo -e "${GREEN}Port API diubah ke: $new_port${NC}"
                echo -e "${YELLOW}Restart API Server untuk menerapkan perubahan.${NC}"
            else
                echo -e "${RED}Port tidak valid! Gunakan port 1024-65535.${NC}"
            fi
            ;;
        6)
            local api_key
            api_key=$(openssl rand -hex 32 2>/dev/null || head -c 64 /dev/urandom | xxd -p | head -c 64)
            mkdir -p "$(dirname "$API_CONFIG")"
            if [[ -f "$API_CONFIG" ]]; then
                if grep -q "^api_key=" "$API_CONFIG"; then
                    sed -i "s/^api_key=.*/api_key=$api_key/" "$API_CONFIG"
                else
                    echo "api_key=$api_key" >> "$API_CONFIG"
                fi
            else
                echo "api_key=$api_key" > "$API_CONFIG"
            fi
            echo -e "${GREEN}API Key baru: ${WHITE}$api_key${NC}"
            echo -e "${YELLOW}Simpan API Key ini dengan aman!${NC}"
            ;;
        0) exit 0 ;;
        *)
            echo -e "${RED}Input tidak valid! Silakan pilih 0-6.${NC}"
            sleep 1
            ;;
    esac
}

while true; do
    show_menu
    read -rp "Pilih Menu [0-6]: " choice
    handle_choice "$choice"
    if [[ "$choice" != "0" ]]; then
        echo ""
        read -rp "Tekan Enter untuk kembali..."
    fi
done
API_SCRIPT

    chmod +x "$MENU_API_BIN"
    log "Menu API berhasil dibuat: $MENU_API_BIN"
}

# ============================================================================
# Menu Bot — /usr/local/bin/menu-bot
# ============================================================================

create_bot_menu() {
    log "Membuat menu Bot: $MENU_BOT_BIN"

    cat > "$MENU_BOT_BIN" <<'BOT_SCRIPT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Menu Telegram Bot
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

BOT_CONFIG="/etc/vpnray/bot.conf"
BOT_SERVICE="vpnray-bot"

get_bot_status() {
    if systemctl is-active --quiet "$BOT_SERVICE" 2>/dev/null; then
        echo -e "${GREEN}Running${NC}"
    else
        echo -e "${RED}Stopped${NC}"
    fi
}

get_bot_token() {
    if [[ -f "$BOT_CONFIG" ]]; then
        local token
        token=$(grep -i "^bot_token=" "$BOT_CONFIG" 2>/dev/null | cut -d= -f2)
        if [[ -n "$token" ]]; then
            echo "${token:0:10}...${token: -5}"
        else
            echo "Not Set"
        fi
    else
        echo "Not Set"
    fi
}

show_menu() {
    clear
    local status token_display
    status=$(get_bot_status)
    token_display=$(get_bot_token)

    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${WHITE}          ⚡ TELEGRAM BOT MENU ⚡               ${CYAN}│${NC}"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC} %-16s : %-30b ${CYAN}│${NC}\n" "Bot Status" "$status"
    printf "${CYAN}│${NC} %-16s : ${GREEN}%-28s${NC} ${CYAN}│${NC}\n" "Bot Token" "$token_display"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC}  ${WHITE}[1]${NC}  %-41s ${CYAN}│${NC}\n" "Register Bot Token"
    printf "${CYAN}│${NC}  ${WHITE}[2]${NC}  %-41s ${CYAN}│${NC}\n" "Start Bot"
    printf "${CYAN}│${NC}  ${WHITE}[3]${NC}  %-41s ${CYAN}│${NC}\n" "Stop Bot"
    printf "${CYAN}│${NC}  ${WHITE}[4]${NC}  %-41s ${CYAN}│${NC}\n" "Bot Status"
    printf "${CYAN}│${NC}  ${WHITE}[5]${NC}  %-41s ${CYAN}│${NC}\n" "Set Admin ID"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC}  ${RED}[0]${NC}  %-41s ${CYAN}│${NC}\n" "Back to Main Menu"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo ""
}

handle_choice() {
    local choice="$1"
    case "$choice" in
        1)
            read -rp "Masukkan Bot Token dari @BotFather: " bot_token
            if [[ -z "$bot_token" ]]; then
                echo -e "${RED}Bot Token tidak boleh kosong!${NC}"
                return
            fi
            mkdir -p "$(dirname "$BOT_CONFIG")"
            if [[ -f "$BOT_CONFIG" ]]; then
                if grep -q "^bot_token=" "$BOT_CONFIG"; then
                    sed -i "s/^bot_token=.*/bot_token=$bot_token/" "$BOT_CONFIG"
                else
                    echo "bot_token=$bot_token" >> "$BOT_CONFIG"
                fi
            else
                echo "bot_token=$bot_token" > "$BOT_CONFIG"
            fi
            chmod 600 "$BOT_CONFIG"
            echo -e "${GREEN}Bot Token berhasil disimpan.${NC}"
            ;;
        2)
            echo -e "${GREEN}Memulai Telegram Bot...${NC}"
            if systemctl start "$BOT_SERVICE" 2>/dev/null; then
                echo -e "${GREEN}Bot berhasil dimulai.${NC}"
            else
                echo -e "${RED}Gagal memulai Bot. Pastikan token sudah dikonfigurasi.${NC}"
            fi
            ;;
        3)
            echo -e "${YELLOW}Menghentikan Telegram Bot...${NC}"
            if systemctl stop "$BOT_SERVICE" 2>/dev/null; then
                echo -e "${GREEN}Bot berhasil dihentikan.${NC}"
            else
                echo -e "${RED}Gagal menghentikan Bot.${NC}"
            fi
            ;;
        4)
            echo -e "\n${CYAN}=== Telegram Bot Status ===${NC}"
            if systemctl is-active --quiet "$BOT_SERVICE" 2>/dev/null; then
                systemctl status "$BOT_SERVICE" --no-pager
            else
                echo -e "${YELLOW}Bot tidak berjalan.${NC}"
            fi
            if [[ -f "$BOT_CONFIG" ]]; then
                echo ""
                echo -e "${CYAN}Konfigurasi:${NC}"
                grep -v "bot_token" "$BOT_CONFIG" 2>/dev/null
                echo "bot_token: $(get_bot_token)"
            fi
            ;;
        5)
            read -rp "Masukkan Telegram Admin ID (numeric): " admin_id
            if [[ "$admin_id" =~ ^[0-9]+$ ]]; then
                mkdir -p "$(dirname "$BOT_CONFIG")"
                if [[ -f "$BOT_CONFIG" ]]; then
                    if grep -q "^admin_id=" "$BOT_CONFIG"; then
                        sed -i "s/^admin_id=.*/admin_id=$admin_id/" "$BOT_CONFIG"
                    else
                        echo "admin_id=$admin_id" >> "$BOT_CONFIG"
                    fi
                else
                    echo "admin_id=$admin_id" > "$BOT_CONFIG"
                fi
                chmod 600 "$BOT_CONFIG"
                echo -e "${GREEN}Admin ID berhasil disimpan: $admin_id${NC}"
            else
                echo -e "${RED}Admin ID harus berupa angka!${NC}"
            fi
            ;;
        0) exit 0 ;;
        *)
            echo -e "${RED}Input tidak valid! Silakan pilih 0-5.${NC}"
            sleep 1
            ;;
    esac
}

while true; do
    show_menu
    read -rp "Pilih Menu [0-5]: " choice
    handle_choice "$choice"
    if [[ "$choice" != "0" ]]; then
        echo ""
        read -rp "Tekan Enter untuk kembali..."
    fi
done
BOT_SCRIPT

    chmod +x "$MENU_BOT_BIN"
    log "Menu Bot berhasil dibuat: $MENU_BOT_BIN"
}

# ============================================================================
# Menu System — /usr/local/bin/menu-system
# ============================================================================

create_system_menu() {
    log "Membuat menu System: $MENU_SYSTEM_BIN"

    cat > "$MENU_SYSTEM_BIN" <<'SYSTEM_SCRIPT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Menu System & Server Settings
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

show_menu() {
    clear
    local tz kernel
    tz=$(timedatectl 2>/dev/null | grep "Time zone" | awk '{print $3}' || cat /etc/timezone 2>/dev/null || echo "N/A")
    kernel=$(uname -r)

    echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${WHITE}          ⚡ SYSTEM & SERVER SETTINGS ⚡         ${CYAN}│${NC}"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC} %-16s : ${GREEN}%-28s${NC} ${CYAN}│${NC}\n" "Timezone" "$tz"
    printf "${CYAN}│${NC} %-16s : ${GREEN}%-28s${NC} ${CYAN}│${NC}\n" "Kernel" "$kernel"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC}  ${WHITE}[1]${NC}  %-41s ${CYAN}│${NC}\n" "Reboot VPS"
    printf "${CYAN}│${NC}  ${WHITE}[2]${NC}  %-41s ${CYAN}│${NC}\n" "Change Timezone"
    printf "${CYAN}│${NC}  ${WHITE}[3]${NC}  %-41s ${CYAN}│${NC}\n" "Change Banner / MOTD"
    printf "${CYAN}│${NC}  ${WHITE}[4]${NC}  %-41s ${CYAN}│${NC}\n" "Auto Reboot Settings"
    printf "${CYAN}│${NC}  ${WHITE}[5]${NC}  %-41s ${CYAN}│${NC}\n" "Clear Log"
    printf "${CYAN}│${NC}  ${WHITE}[6]${NC}  %-41s ${CYAN}│${NC}\n" "Memory Usage"
    printf "${CYAN}│${NC}  ${WHITE}[7]${NC}  %-41s ${CYAN}│${NC}\n" "Kernel Info"
    echo -e "${CYAN}│─────────────────────────────────────────────────│${NC}"
    printf "${CYAN}│${NC}  ${RED}[0]${NC}  %-41s ${CYAN}│${NC}\n" "Back to Main Menu"
    echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
    echo ""
}

handle_choice() {
    local choice="$1"
    case "$choice" in
        1)
            echo -e "${YELLOW}VPS akan direboot dalam 5 detik...${NC}"
            echo -e "${YELLOW}Tekan Ctrl+C untuk membatalkan.${NC}"
            sleep 5
            reboot
            ;;
        2)
            echo -e "${CYAN}Timezone saat ini: $(timedatectl 2>/dev/null | grep 'Time zone' | awk '{print $3}')${NC}"
            echo ""
            echo "Timezone populer:"
            echo "  1. Asia/Jakarta (WIB)"
            echo "  2. Asia/Makassar (WITA)"
            echo "  3. Asia/Jayapura (WIT)"
            echo "  4. Asia/Singapore"
            echo "  5. Asia/Tokyo"
            echo "  6. UTC"
            echo "  7. Input manual"
            read -rp "Pilih [1-7]: " tz_choice
            case "$tz_choice" in
                1) timedatectl set-timezone Asia/Jakarta 2>/dev/null ;;
                2) timedatectl set-timezone Asia/Makassar 2>/dev/null ;;
                3) timedatectl set-timezone Asia/Jayapura 2>/dev/null ;;
                4) timedatectl set-timezone Asia/Singapore 2>/dev/null ;;
                5) timedatectl set-timezone Asia/Tokyo 2>/dev/null ;;
                6) timedatectl set-timezone UTC 2>/dev/null ;;
                7)
                    read -rp "Masukkan timezone (contoh: Asia/Jakarta): " custom_tz
                    if timedatectl set-timezone "$custom_tz" 2>/dev/null; then
                        true
                    else
                        echo -e "${RED}Timezone tidak valid: $custom_tz${NC}"
                        return
                    fi
                    ;;
                *) echo -e "${RED}Pilihan tidak valid!${NC}"; return ;;
            esac
            echo -e "${GREEN}Timezone berhasil diubah ke: $(timedatectl 2>/dev/null | grep 'Time zone' | awk '{print $3}')${NC}"
            ;;
        3)
            echo -e "${CYAN}=== Change Banner / MOTD ===${NC}"
            local banner_file="/etc/banner"
            if [[ -f "$banner_file" ]]; then
                echo -e "${GREEN}Banner saat ini:${NC}"
                cat "$banner_file"
                echo ""
            fi
            echo "  [1] Set banner default"
            echo "  [2] Input banner custom"
            echo "  [3] Kosongkan banner"
            read -rp "Pilih: " banner_choice
            case "$banner_choice" in
                1)
                    cat > "$banner_file" <<'DEFAULT_BANNER'
<br>
========================================
   VPN Tunneling AutoScript
   Powered by AutoScript Team
========================================
<br>
DEFAULT_BANNER
                    echo -e "${GREEN}Banner default berhasil diterapkan.${NC}"
                    ;;
                2)
                    echo "Masukkan banner baru (akhiri dengan baris kosong):"
                    local banner_text=""
                    while IFS= read -r line; do
                        [[ -z "$line" ]] && break
                        banner_text+="$line"$'\n'
                    done
                    echo "$banner_text" > "$banner_file"
                    echo -e "${GREEN}Banner custom berhasil diterapkan.${NC}"
                    ;;
                3)
                    > "$banner_file"
                    echo -e "${GREEN}Banner dikosongkan.${NC}"
                    ;;
                *)
                    echo -e "${RED}Pilihan tidak valid!${NC}"
                    ;;
            esac
            ;;
        4)
            echo -e "${CYAN}=== Auto Reboot Settings ===${NC}"
            echo "  [1] Aktifkan Auto Reboot (Daily 04:00)"
            echo "  [2] Nonaktifkan Auto Reboot"
            echo "  [3] Lihat Status"
            read -rp "Pilih: " ar_choice
            case "$ar_choice" in
                1)
                    echo "0 4 * * * root /sbin/reboot" > /etc/cron.d/auto-reboot-vpn
                    chmod 644 /etc/cron.d/auto-reboot-vpn
                    echo -e "${GREEN}Auto reboot harian diaktifkan (04:00).${NC}"
                    ;;
                2)
                    rm -f /etc/cron.d/auto-reboot-vpn
                    echo -e "${GREEN}Auto reboot dinonaktifkan.${NC}"
                    ;;
                3)
                    if [[ -f /etc/cron.d/auto-reboot-vpn ]]; then
                        echo -e "${GREEN}Auto reboot aktif:${NC}"
                        cat /etc/cron.d/auto-reboot-vpn
                    else
                        echo -e "${YELLOW}Auto reboot tidak aktif.${NC}"
                    fi
                    ;;
                *)
                    echo -e "${RED}Pilihan tidak valid!${NC}"
                    ;;
            esac
            ;;
        5)
            echo -e "${YELLOW}Membersihkan log...${NC}"
            local log_files=(
                "/root/syslog.log"
                "/var/log/syslog"
                "/var/log/auth.log"
                "/var/log/nginx/access.log"
                "/var/log/nginx/error.log"
                "/var/log/xray/access.log"
                "/var/log/xray/error.log"
                "/var/log/haproxy.log"
            )
            for lf in "${log_files[@]}"; do
                if [[ -f "$lf" ]]; then
                    > "$lf"
                    echo -e "  ${GREEN}Cleared: $lf${NC}"
                fi
            done
            echo -e "${GREEN}Log berhasil dibersihkan.${NC}"
            ;;
        6)
            echo -e "\n${CYAN}=== Memory Usage ===${NC}"
            free -h
            echo ""
            echo -e "${CYAN}=== Swap Usage ===${NC}"
            swapon --show 2>/dev/null || echo "No swap configured"
            echo ""
            echo -e "${CYAN}=== Disk Usage ===${NC}"
            df -h / 2>/dev/null
            ;;
        7)
            echo -e "\n${CYAN}=== Kernel Info ===${NC}"
            printf "%-16s : %s\n" "Kernel" "$(uname -r)"
            printf "%-16s : %s\n" "Architecture" "$(uname -m)"
            printf "%-16s : %s\n" "OS" "$(uname -o)"
            printf "%-16s : %s\n" "Hostname" "$(uname -n)"
            printf "%-16s : %s\n" "Platform" "$(uname -i 2>/dev/null || echo 'N/A')"
            echo ""
            echo -e "${CYAN}=== CPU Info ===${NC}"
            grep "model name" /proc/cpuinfo 2>/dev/null | head -1 | cut -d: -f2 | xargs
            printf "%-16s : %s\n" "CPU Cores" "$(nproc 2>/dev/null || echo 'N/A')"
            printf "%-16s : %s\n" "Load Average" "$(awk '{printf "%.2f, %.2f, %.2f", $1, $2, $3}' /proc/loadavg 2>/dev/null)"
            ;;
        0) exit 0 ;;
        *)
            echo -e "${RED}Input tidak valid! Silakan pilih 0-7.${NC}"
            sleep 1
            ;;
    esac
}

while true; do
    show_menu
    read -rp "Pilih Menu [0-7]: " choice
    handle_choice "$choice"
    if [[ "$choice" != "0" ]]; then
        echo ""
        read -rp "Tekan Enter untuk kembali..."
    fi
done
SYSTEM_SCRIPT

    chmod +x "$MENU_SYSTEM_BIN"
    log "Menu System berhasil dibuat: $MENU_SYSTEM_BIN"
}

# ============================================================================
# Running Services — /usr/local/bin/running
# ============================================================================

create_running_script() {
    log "Membuat script Running Services: $RUNNING_BIN"

    cat > "$RUNNING_BIN" <<'RUNNING_SCRIPT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Running Services Check
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

check_service() {
    local name="$1"
    local service="$2"
    local status

    if systemctl is-active --quiet "$service" 2>/dev/null; then
        status="${GREEN}● Running${NC}"
    else
        status="${RED}○ Not Running${NC}"
    fi
    printf "  %-24s : %b\n" "$name" "$status"
}

check_process() {
    local name="$1"
    local process="$2"
    local status

    if pgrep -x "$process" &>/dev/null; then
        status="${GREEN}● Running${NC}"
    elif pgrep -f "$process" &>/dev/null; then
        status="${GREEN}● Running${NC}"
    else
        status="${RED}○ Not Running${NC}"
    fi
    printf "  %-24s : %b\n" "$name" "$status"
}

check_port() {
    local name="$1"
    local port="$2"
    local status

    if ss -tlnp 2>/dev/null | grep -q ":${port} "; then
        status="${GREEN}● Listening${NC}"
    else
        status="${RED}○ Not Listening${NC}"
    fi
    printf "  %-24s : %b\n" "$name (port $port)" "$status"
}

clear
echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${WHITE}          ⚡ RUNNING SERVICES STATUS ⚡           ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo ""

echo -e "${CYAN}=== SSH & Transport ===${NC}"
check_service "SSH (OpenSSH)"       "sshd"
check_service "Dropbear"            "dropbear"
check_service "Stunnel4"            "stunnel4"
check_service "Squid Proxy"         "squid"

echo ""
echo -e "${CYAN}=== Web & Proxy ===${NC}"
check_service "Nginx"               "nginx"
check_service "HAProxy"             "haproxy"

echo ""
echo -e "${CYAN}=== VPN Protocols ===${NC}"
check_process "Xray-core"           "xray"
check_process "Hysteria2"           "hysteria"
check_process "Trojan-Go"           "trojan-go"
check_service "OpenVPN"             "openvpn"
check_service "SoftEther"           "softether-vpnserver"

echo ""
echo -e "${CYAN}=== Tunneling Tools ===${NC}"
check_process "BadVPN (UDPGW)"      "badvpn-udpgw"
check_process "OHP Server"          "ohp"
check_process "SSH WebSocket"       "sshws"

echo ""
echo -e "${CYAN}=== Network & Security ===${NC}"
check_process "Cloudflare WARP"     "warp-svc"
check_service "Fail2Ban"            "fail2ban"
check_service "Cron"                "cron"

echo ""
echo -e "${CYAN}=== API & Bot ===${NC}"
check_service "VPNRay API"          "vpnray-api"
check_service "VPNRay Bot"          "vpnray-bot"

echo ""
RUNNING_SCRIPT

    chmod +x "$RUNNING_BIN"
    log "Script Running Services berhasil dibuat: $RUNNING_BIN"
}

# ============================================================================
# Speedtest — /usr/local/bin/speedtest
# ============================================================================

create_speedtest_script() {
    log "Membuat script Speedtest: $SPEEDTEST_BIN"

    cat > "$SPEEDTEST_BIN" <<'SPEEDTEST_SCRIPT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Speedtest Wrapper
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}          ⚡ SPEEDTEST BY OOKLA ⚡               ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo ""

# Check for Ookla speedtest binary
if command -v /usr/bin/speedtest &>/dev/null; then
    echo -e "${GREEN}Menjalankan Speedtest (Ookla)...${NC}"
    echo ""
    /usr/bin/speedtest --accept-license --accept-gdpr 2>/dev/null
elif command -v speedtest-cli &>/dev/null; then
    echo -e "${GREEN}Menjalankan speedtest-cli...${NC}"
    echo ""
    speedtest-cli --simple
else
    echo -e "${YELLOW}Speedtest belum terinstall. Menginstall speedtest-cli...${NC}"
    if command -v pip3 &>/dev/null; then
        pip3 install speedtest-cli --quiet 2>/dev/null
    elif command -v pip &>/dev/null; then
        pip install speedtest-cli --quiet 2>/dev/null
    elif command -v apt-get &>/dev/null; then
        apt-get install -y speedtest-cli 2>/dev/null
    fi

    if command -v speedtest-cli &>/dev/null; then
        echo -e "${GREEN}Menjalankan speedtest-cli...${NC}"
        echo ""
        speedtest-cli --simple
    else
        echo -e "${RED}Gagal menginstall speedtest. Install manual:${NC}"
        echo "  pip3 install speedtest-cli"
        echo "  atau"
        echo "  apt install speedtest-cli"
    fi
fi

echo ""
SPEEDTEST_SCRIPT

    chmod +x "$SPEEDTEST_BIN"
    log "Script Speedtest berhasil dibuat: $SPEEDTEST_BIN"
}

# ============================================================================
# Bandwidth Monitor — /usr/local/bin/vnstat (wrapper)
# ============================================================================

create_bandwidth_script() {
    log "Membuat script Bandwidth: $BANDWIDTH_BIN"

    cat > "$BANDWIDTH_BIN" <<'BANDWIDTH_SCRIPT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — vnStat Bandwidth Monitor Wrapper
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

VNSTAT_BIN="/usr/bin/vnstat"

echo -e "${CYAN}┌─────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}│${NC}          ⚡ BANDWIDTH MONITOR ⚡                ${CYAN}│${NC}"
echo -e "${CYAN}└─────────────────────────────────────────────────┘${NC}"
echo ""

if [[ ! -x "$VNSTAT_BIN" ]]; then
    if ! command -v vnstat &>/dev/null; then
        echo -e "${YELLOW}vnStat belum terinstall. Menginstall...${NC}"
        apt-get install -y vnstat 2>/dev/null
        systemctl enable vnstat 2>/dev/null
        systemctl start vnstat 2>/dev/null

        if ! command -v vnstat &>/dev/null; then
            echo -e "${RED}Gagal menginstall vnStat.${NC}"
            echo "  Install manual: apt install vnstat"
            exit 1
        fi
        VNSTAT_BIN=$(command -v vnstat)
    else
        VNSTAT_BIN=$(command -v vnstat)
    fi
fi

# Detect primary network interface
iface=$(ip route 2>/dev/null | grep default | awk '{print $5}' | head -1)
if [[ -z "$iface" ]]; then
    iface="eth0"
fi

echo -e "${CYAN}=== Summary (Interface: $iface) ===${NC}"
"$VNSTAT_BIN" -i "$iface" 2>/dev/null || "$VNSTAT_BIN" 2>/dev/null
echo ""

echo -e "${CYAN}=== Daily Statistics ===${NC}"
"$VNSTAT_BIN" -i "$iface" -d 2>/dev/null || "$VNSTAT_BIN" -d 2>/dev/null
echo ""

echo -e "${CYAN}=== Monthly Statistics ===${NC}"
"$VNSTAT_BIN" -i "$iface" -m 2>/dev/null || "$VNSTAT_BIN" -m 2>/dev/null
echo ""
BANDWIDTH_SCRIPT

    chmod +x "$BANDWIDTH_BIN"
    log "Script Bandwidth berhasil dibuat: $BANDWIDTH_BIN"
}

# ============================================================================
# Menu Functions File — /etc/vpnray/menu-functions.sh
# ============================================================================

create_menu_functions() {
    log "Membuat menu functions: $MENU_FUNCTIONS"

    mkdir -p "$(dirname "$MENU_FUNCTIONS")"

    cat > "$MENU_FUNCTIONS" <<'FUNCTIONS_SCRIPT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Menu Functions Library
# ============================================================================
# Fungsi-fungsi yang dipanggil oleh menu protocol sub-menus.
# File ini di-source oleh menu-ssh, menu-vmess, dll.
# Implementasi lengkap tersedia setelah Tahap 8.
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

ACCOUNT_DIR="/etc/vpnray/accounts"

# Generic account listing function
_list_accounts() {
    local protocol="$1"
    local acct_dir="$ACCOUNT_DIR/$protocol"

    echo -e "${CYAN}=== Daftar Akun ${protocol^^} ===${NC}"
    echo ""

    if [[ ! -d "$acct_dir" ]]; then
        echo -e "${YELLOW}Direktori akun tidak ditemukan: $acct_dir${NC}"
        return
    fi

    local count=0
    printf "%-4s %-15s %-12s %-10s\n" "No" "Username" "Expiry" "Status"
    echo "--------------------------------------------"

    for f in "$acct_dir"/*.json; do
        [[ -f "$f" ]] || continue
        ((count++))
        if command -v jq &>/dev/null; then
            local username expiry status
            username=$(jq -r '.username // .user // "N/A"' "$f" 2>/dev/null)
            expiry=$(jq -r '.expiry // "N/A"' "$f" 2>/dev/null)
            status=$(jq -r '.status // "N/A"' "$f" 2>/dev/null)
            printf "%-4s %-15s %-12s %-10s\n" "$count" "$username" "$expiry" "$status"
        else
            printf "%-4s %s\n" "$count" "$(basename "$f" .json)"
        fi
    done

    if [[ $count -eq 0 ]]; then
        echo -e "${YELLOW}Tidak ada akun yang ditemukan.${NC}"
    fi
    echo ""
    echo "Total: $count akun"
}

# Generic stub function for unimplemented features
_stub_function() {
    local action="$1"
    local protocol="$2"
    echo -e "${YELLOW}Fungsi ${action}_${protocol}_account belum tersedia.${NC}"
    echo -e "${YELLOW}Fitur ini akan diimplementasikan di Tahap 8.${NC}"
}

# Generate functions for each protocol
for proto in ssh vmess vless trojan shadowsocks socks hysteria2 trojan-go; do
    safe_proto="${proto//-/_}"

    eval "create_${safe_proto}_account() { _stub_function 'create' '${proto}'; }"
    eval "bulk_create_${safe_proto}_account() { _stub_function 'bulk_create' '${proto}'; }"
    eval "delete_${safe_proto}_account() { _stub_function 'delete' '${proto}'; }"
    eval "extend_${safe_proto}_account() { _stub_function 'extend' '${proto}'; }"
    eval "check_login_${safe_proto}_account() { _stub_function 'check_login' '${proto}'; }"
    eval "detail_${safe_proto}_account() { _stub_function 'detail' '${proto}'; }"
    eval "lock_${safe_proto}_account() { _stub_function 'lock' '${proto}'; }"
    eval "unlock_${safe_proto}_account() { _stub_function 'unlock' '${proto}'; }"
    eval "limit_ip_${safe_proto}_account() { _stub_function 'limit_ip' '${proto}'; }"
    eval "limit_quota_${safe_proto}_account() { _stub_function 'limit_quota' '${proto}'; }"
    eval "ban_${safe_proto}_account() { _stub_function 'ban' '${proto}'; }"
    eval "unban_${safe_proto}_account() { _stub_function 'unban' '${proto}'; }"
    eval "recover_${safe_proto}_account() { _stub_function 'recover' '${proto}'; }"
    eval "list_${safe_proto}_account() { _list_accounts '${proto}'; }"
done
FUNCTIONS_SCRIPT

    chmod +x "$MENU_FUNCTIONS"
    log "Menu functions berhasil dibuat: $MENU_FUNCTIONS"
}

# ============================================================================
# Register Menu Commands
# ============================================================================

register_menu_commands() {
    log "Mendaftarkan menu commands..."

    local scripts=(
        "$MENU_BIN"
        "$MENU_SSH_BIN"
        "$MENU_VMESS_BIN"
        "$MENU_VLESS_BIN"
        "$MENU_TROJAN_BIN"
        "$MENU_SS_BIN"
        "$MENU_SOCKS_BIN"
        "$MENU_HYSTERIA2_BIN"
        "$MENU_TROJAN_GO_BIN"
        "$MENU_SOFTETHER_BIN"
        "$MENU_WARP_BIN"
        "$MENU_BACKUP_BIN"
        "$MENU_API_BIN"
        "$MENU_BOT_BIN"
        "$MENU_SYSTEM_BIN"
        "$RUNNING_BIN"
        "$SPEEDTEST_BIN"
        "$BANDWIDTH_BIN"
    )

    for script in "${scripts[@]}"; do
        if [[ -f "$script" ]]; then
            chmod +x "$script"
            log "  Executable: $script"
        else
            log_warn "  Script tidak ditemukan: $script"
        fi
    done

    log "Semua menu commands berhasil didaftarkan."
}

# ============================================================================
# Setup Profile Menu (Auto-show on Login)
# ============================================================================

setup_profile_menu() {
    log "Mengkonfigurasi auto-menu pada login..."

    local profile_file="/root/.profile"
    local marker="# VPN-AUTOSCRIPT-MENU"

    # Remove existing menu auto-start if present
    if [[ -f "$profile_file" ]]; then
        sed -i "/${marker}/d" "$profile_file"
        sed -i '/\/usr\/local\/bin\/menu/d' "$profile_file"
    fi

    # Add menu auto-display on login
    {
        echo ""
        echo "${marker}"
        echo "if [[ -x /usr/local/bin/menu ]] && [[ \$- == *i* ]]; then"
        echo "    /usr/local/bin/menu"
        echo "fi"
    } >> "$profile_file"

    log "Auto-menu pada login berhasil dikonfigurasi: $profile_file"
}

# ============================================================================
# Main Function
# ============================================================================

main() {
    # Inisialisasi log
    {
        echo "=== VPN Tunneling AutoScript — Tahap 7 ==="
        echo "Waktu mulai: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "============================================"
    } >> "$LOG_FILE"

    print_header

    log "Memulai Tahap 7: Setup Menu Sistem & CLI Dashboard..."

    # Pengecekan prasyarat
    log "Memulai pengecekan prasyarat..."
    check_root
    check_os
    check_arch
    check_virt
    check_tahap6
    log "Semua pengecekan prasyarat berhasil."

    echo ""
    echo -e "${BLUE}Semua prasyarat terpenuhi. Memulai pembuatan menu...${NC}"
    echo ""

    # 1. Buat menu functions library
    create_menu_functions

    # 2. Buat menu utama
    create_main_menu

    # 3. Buat protocol sub-menus
    create_ssh_menu
    create_vmess_menu
    create_vless_menu
    create_trojan_menu
    create_shadowsocks_menu
    create_socks_menu
    create_hysteria2_menu
    create_trojan_go_menu

    # 4. Buat menu layanan tambahan
    create_softether_menu
    create_warp_menu

    # 5. Buat menu manajemen
    create_backup_menu
    create_api_menu
    create_bot_menu
    create_system_menu

    # 6. Buat script utilitas
    create_running_script
    create_speedtest_script
    create_bandwidth_script

    # 7. Daftarkan semua commands
    register_menu_commands

    # 8. Setup auto-menu pada login
    setup_profile_menu

    # Selesai
    echo ""
    echo -e "${GREEN}=============================================="
    echo "  Tahap 7 selesai!"
    echo "  Menu sistem & CLI dashboard berhasil dikonfigurasi."
    echo ""
    echo "  Menu Scripts:"
    echo "    Menu Utama     : $MENU_BIN"
    echo "    SSH & OpenVPN  : $MENU_SSH_BIN"
    echo "    VMess          : $MENU_VMESS_BIN"
    echo "    VLESS          : $MENU_VLESS_BIN"
    echo "    Trojan         : $MENU_TROJAN_BIN"
    echo "    Shadowsocks    : $MENU_SS_BIN"
    echo "    Socks          : $MENU_SOCKS_BIN"
    echo "    Hysteria2      : $MENU_HYSTERIA2_BIN"
    echo "    Trojan-Go      : $MENU_TROJAN_GO_BIN"
    echo "    SoftEther      : $MENU_SOFTETHER_BIN"
    echo "    WARP           : $MENU_WARP_BIN"
    echo "    Backup         : $MENU_BACKUP_BIN"
    echo "    API            : $MENU_API_BIN"
    echo "    Bot            : $MENU_BOT_BIN"
    echo "    System         : $MENU_SYSTEM_BIN"
    echo ""
    echo "  Utility Scripts:"
    echo "    Running        : $RUNNING_BIN"
    echo "    Speedtest      : $SPEEDTEST_BIN"
    echo "    Bandwidth      : $BANDWIDTH_BIN"
    echo ""
    echo "  Menu Functions   : $MENU_FUNCTIONS"
    echo ""
    echo "  Sistem siap untuk instalasi REST API & Bot (Tahap 8)."
    echo -e "==============================================${NC}"
    echo ""

    log "Tahap 7 selesai. Menu sistem & CLI dashboard berhasil dikonfigurasi."
}

main "$@"
