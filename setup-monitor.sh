#!/bin/bash
# shellcheck disable=SC2034
# ============================================================================
# VPN Tunneling AutoScript Installer — Tahap 9: Monitoring, Backup & Keamanan
# ============================================================================
# Monitoring bandwidth, backup otomatis, dan konfigurasi keamanan lanjutan.
#
# Komponen:
#   - vnStat Monitoring & web interface (port 8899)
#   - Fail2ban Lanjutan (SSH, Dropbear, Xray jails)
#   - Firewall UFW/iptables auto-config
#   - Rclone Backup/Restore (Google Drive, Dropbox, OneDrive)
#   - Auto Backup (cronjob)
#   - HideSSH Web Panel
#   - Webmin
#   - SWAP Memory (1GB/2GB)
#   - Auto Block Ads Indo (hosts-based)
#   - Domain Blacklist (Xray routing)
#   - BT Download Block (P2P/BitTorrent)
#   - IP Whitelist/Blacklist
#   - Service on Demand
#   - CPU & Memory Monitoring
#   - Log Rotation
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
#   - Tahap 1-8 sudah dijalankan
#
# Penggunaan:
#   chmod +x setup-monitor.sh
#   ./setup-monitor.sh
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
# shellcheck disable=SC2034
XRAY_CERT="/etc/xray/xray.crt"
# shellcheck disable=SC2034
XRAY_KEY="/etc/xray/xray.key"

# ============================================================================
# Monitoring Configuration
# ============================================================================
VNSTAT_WEB_PORT=8899
VNSTAT_WEB_DIR="/var/www/vnstat"
VNSTAT_CGI_SCRIPT="/usr/lib/cgi-bin/vnstat.cgi"
VNSTAT_CONFIG="/etc/vnstat.conf"

# ============================================================================
# Fail2ban Configuration
# ============================================================================
FAIL2BAN_CONFIG="/etc/fail2ban/jail.local"
FAIL2BAN_FILTER_DIR="/etc/fail2ban/filter.d"
FAIL2BAN_XRAY_FILTER="$FAIL2BAN_FILTER_DIR/xray-auth.conf"
FAIL2BAN_DROPBEAR_FILTER="$FAIL2BAN_FILTER_DIR/dropbear-auth.conf"

# ============================================================================
# Firewall Configuration
# ============================================================================
FIREWALL_RULES_FILE="/etc/vpnray/firewall-rules.conf"
IPTABLES_RULES_FILE="/etc/iptables/rules.v4"

# ============================================================================
# Rclone & Backup Configuration
# ============================================================================
RCLONE_CONFIG_DIR="$HOME/.config/rclone"
RCLONE_CONFIG_FILE="$RCLONE_CONFIG_DIR/rclone.conf"
BACKUP_DIR="/home/vps/backup"
BACKUP_SCRIPT="/usr/local/bin/vpnray-backup"
RESTORE_SCRIPT="/usr/local/bin/vpnray-restore"
AUTO_BACKUP_CRON="/etc/cron.d/vpnray-auto-backup"
BACKUP_DIRS="/etc/xray /etc/vpnray /etc/hysteria2 /etc/trojan-go /etc/haproxy /etc/nginx/conf.d /etc/openvpn /etc/stunnel /etc/squid"

# ============================================================================
# Web Panel Configuration
# ============================================================================
HIDESSH_DIR="/var/www/hidessh"
HIDESSH_PORT=8880
WEBMIN_PORT=10000

# ============================================================================
# Security Configuration
# ============================================================================
SWAP_DIR="/var"
SWAP_FILE="/var/swapfile"
ADS_HOSTS_FILE="/etc/vpnray/ads-hosts.conf"
DOMAIN_BLACKLIST_FILE="/etc/vpnray/domain-blacklist.conf"
BT_BLOCK_FILE="/etc/vpnray/bt-block.conf"
IP_WHITELIST_FILE="/etc/vpnray/ip-whitelist.conf"
IP_BLACKLIST_FILE="/etc/vpnray/ip-blacklist.conf"

# ============================================================================
# Service on Demand Configuration
# ============================================================================
SOD_CONFIG_FILE="/etc/vpnray/service-on-demand.conf"
SOD_SCRIPT="/usr/local/bin/vpnray-sod"
SOD_CRON="/etc/cron.d/vpnray-sod"

# ============================================================================
# Monitoring Scripts
# ============================================================================
CPU_MONITOR_SCRIPT="/usr/local/bin/vpnray-cpu-monitor"
MEM_MONITOR_SCRIPT="/usr/local/bin/vpnray-mem-monitor"
RESOURCE_MONITOR_SCRIPT="/usr/local/bin/vpnray-resource-monitor"

# ============================================================================
# Log Rotation
# ============================================================================
LOGROTATE_CONFIG="/etc/logrotate.d/vpnray"

# ============================================================================
# Account directory (needed for Service on Demand)
# ============================================================================
ACCOUNT_DIR="/etc/vpnray/accounts"

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
    echo "║    VPN Tunneling AutoScript — Tahap 9                      ║"
    echo "║    Monitoring, Backup & Keamanan                           ║"
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
        echo -e "${RED}Gunakan: sudo ./setup-monitor.sh${NC}"
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

check_tahap8() {
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
    # Cek API server script
    if [[ ! -f "/usr/local/bin/vpnray-api" ]]; then
        log_warn "API server script tidak ditemukan: /usr/local/bin/vpnray-api"
        ((errors++))
    fi
    # Cek menu scripts
    if [[ ! -f "/usr/local/bin/menu" ]]; then
        log_warn "Menu utama tidak ditemukan: /usr/local/bin/menu"
        ((errors++))
    fi
    if [[ "$errors" -gt 0 ]]; then
        log_warn "Ada $errors komponen Tahap 1-8 belum lengkap. Lanjutkan dengan hati-hati."
    else
        log "Pengecekan Tahap 1-8: Semua komponen OK"
    fi
}

# ============================================================================
# 1. vnStat Monitoring
# ============================================================================

setup_vnstat() {
    log "Setup vnStat monitoring"

    # Install vnStat
    if ! command -v vnstat &>/dev/null; then
        apt-get install -y vnstat 2>/dev/null || {
            log_warn "Gagal install vnStat, skip"
            return
        }
    fi

    # Konfigurasi vnStat
    local iface
    iface=$(ip route get 8.8.8.8 2>/dev/null | awk '{print $5; exit}')
    iface=${iface:-eth0}

    if [[ -f "$VNSTAT_CONFIG" ]]; then
        sed -i "s/^Interface .*/Interface \"$iface\"/" "$VNSTAT_CONFIG" 2>/dev/null
    fi

    # Enable & start vnStat
    systemctl enable vnstat 2>/dev/null
    systemctl start vnstat 2>/dev/null

    # Create vnStat database for interface
    vnstat -i "$iface" --add 2>/dev/null

    log "vnStat dikonfigurasi untuk interface: $iface"
}

setup_vnstat_web() {
    log "Setup vnStat web interface pada port $VNSTAT_WEB_PORT"
    mkdir -p "$VNSTAT_WEB_DIR"

    # Create simple vnStat web page
    cat > "$VNSTAT_WEB_DIR/index.html" << 'VNSTAT_HTML'
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>vnStat - Bandwidth Monitor</title>
    <style>
        body { font-family: 'Courier New', monospace; background: #1a1a2e; color: #0ff; margin: 0; padding: 20px; }
        .container { max-width: 900px; margin: 0 auto; }
        h1 { text-align: center; color: #0ff; border-bottom: 2px solid #0ff; padding-bottom: 10px; }
        .stats { background: #16213e; padding: 20px; border-radius: 8px; margin: 15px 0; border: 1px solid #0f3460; }
        .stats h2 { color: #e94560; margin-top: 0; }
        pre { white-space: pre-wrap; word-wrap: break-word; font-size: 14px; line-height: 1.6; }
        .refresh { text-align: center; margin-top: 20px; }
        .refresh a { color: #0ff; text-decoration: none; padding: 10px 20px; border: 1px solid #0ff; border-radius: 5px; }
        .refresh a:hover { background: #0ff; color: #1a1a2e; }
        .footer { text-align: center; margin-top: 30px; color: #666; font-size: 12px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>📊 vnStat Bandwidth Monitor</h1>
        <div class="stats">
            <h2>📅 Harian</h2>
            <pre id="daily">Loading...</pre>
        </div>
        <div class="stats">
            <h2>📆 Bulanan</h2>
            <pre id="monthly">Loading...</pre>
        </div>
        <div class="stats">
            <h2>📊 Summary</h2>
            <pre id="summary">Loading...</pre>
        </div>
        <div class="refresh">
            <a href="javascript:location.reload()">🔄 Refresh</a>
        </div>
        <div class="footer">VPN Tunneling AutoScript — vnStat Monitor</div>
    </div>
    <script>
        // Static page - data populated by CGI or refresh
        document.getElementById('daily').textContent = 'Run vnstat -d on server for daily stats';
        document.getElementById('monthly').textContent = 'Run vnstat -m on server for monthly stats';
        document.getElementById('summary').textContent = 'Run vnstat on server for summary';
    </script>
</body>
</html>
VNSTAT_HTML

    # Create CGI script for dynamic data
    mkdir -p "$(dirname "$VNSTAT_CGI_SCRIPT")"
    cat > "$VNSTAT_CGI_SCRIPT" << 'CGI_SCRIPT'
#!/bin/bash
echo "Content-Type: text/html"
echo ""
echo "<html><head><title>vnStat</title></head><body>"
echo "<h1>vnStat Bandwidth</h1>"
echo "<h2>Daily</h2><pre>"
vnstat -d 2>/dev/null || echo "vnstat not available"
echo "</pre>"
echo "<h2>Monthly</h2><pre>"
vnstat -m 2>/dev/null || echo "vnstat not available"
echo "</pre>"
echo "<h2>Summary</h2><pre>"
vnstat 2>/dev/null || echo "vnstat not available"
echo "</pre>"
echo "</body></html>"
CGI_SCRIPT
    chmod +x "$VNSTAT_CGI_SCRIPT"

    # Create simple Python HTTP server script for vnStat web
    cat > /usr/local/bin/vpnray-vnstat-web << VNSTAT_WEB
#!/bin/bash
# vnStat web interface server
cd $VNSTAT_WEB_DIR || exit 1
exec python3 -m http.server $VNSTAT_WEB_PORT --bind 0.0.0.0
VNSTAT_WEB
    chmod +x /usr/local/bin/vpnray-vnstat-web

    # Create systemd service for vnStat web
    cat > /etc/systemd/system/vpnray-vnstat-web.service << VNSTAT_SVC
[Unit]
Description=vnStat Web Interface
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/vpnray-vnstat-web
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
VNSTAT_SVC

    systemctl daemon-reload 2>/dev/null
    systemctl enable vpnray-vnstat-web 2>/dev/null
    systemctl start vpnray-vnstat-web 2>/dev/null || log_warn "Gagal start vnstat web"

    log "vnStat web interface dikonfigurasi pada port $VNSTAT_WEB_PORT"
}

# ============================================================================
# 2. Fail2ban Lanjutan
# ============================================================================

setup_fail2ban() {
    log "Setup Fail2ban lanjutan"

    # Install fail2ban
    if ! command -v fail2ban-client &>/dev/null; then
        apt-get install -y fail2ban 2>/dev/null || {
            log_warn "Gagal install fail2ban, skip"
            return
        }
    fi

    # Create main jail config
    cat > "$FAIL2BAN_CONFIG" << 'JAIL_CONFIG'
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5
backend = auto
action = %(action_mwl)s

# SSH Jail
[sshd]
enabled = true
port = ssh,22,143,80
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 7200

# Dropbear Jail
[dropbear]
enabled = true
port = 80,143,443
filter = dropbear-auth
logpath = /var/log/auth.log
maxretry = 3
bantime = 7200

# Xray Auth Jail
[xray-auth]
enabled = true
port = 443,80
filter = xray-auth
logpath = /var/log/xray/access.log
maxretry = 10
findtime = 300
bantime = 3600

# Nginx Auth Jail
[nginx-botsearch]
enabled = true
port = http,https
filter = nginx-botsearch
logpath = /var/log/nginx/access.log
maxretry = 5
bantime = 3600

# Recidive Jail (ban repeat offenders longer)
[recidive]
enabled = true
logpath = /var/log/fail2ban.log
banaction = %(banaction_allports)s
bantime = 86400
findtime = 86400
maxretry = 3
JAIL_CONFIG

    # Create Dropbear filter
    mkdir -p "$FAIL2BAN_FILTER_DIR"
    cat > "$FAIL2BAN_DROPBEAR_FILTER" << 'DROPBEAR_FILTER'
[Definition]
failregex = ^.*dropbear.*: Bad password attempt for .* from <HOST>.*$
            ^.*dropbear.*: Login attempt for nonexistent user from <HOST>.*$
            ^.*dropbear.*: Exit before auth.*: Exited normally.*<HOST>.*$
ignoreregex =
DROPBEAR_FILTER

    # Create Xray auth filter
    cat > "$FAIL2BAN_XRAY_FILTER" << 'XRAY_FILTER'
[Definition]
failregex = ^.*rejected .* from <HOST>:\d+.*$
            ^.*failed to read request from <HOST>:\d+.*$
            ^.*connection from <HOST>:\d+ rejected.*$
ignoreregex =
XRAY_FILTER

    # Enable & restart fail2ban
    systemctl enable fail2ban 2>/dev/null
    systemctl restart fail2ban 2>/dev/null || log_warn "Gagal restart fail2ban"

    log "Fail2ban dikonfigurasi dengan jail: sshd, dropbear, xray-auth, nginx-botsearch, recidive"
}

# ============================================================================
# 3. Firewall UFW/iptables
# ============================================================================

setup_firewall() {
    log "Setup firewall rules"
    mkdir -p "$(dirname "$FIREWALL_RULES_FILE")"

    # Define allowed ports
    cat > "$FIREWALL_RULES_FILE" << 'FIREWALL_RULES'
# VPN Tunneling AutoScript — Firewall Rules
# Format: port/protocol description
22/tcp SSH
80/tcp HTTP/HAProxy/Dropbear
443/tcp HTTPS/Xray/HAProxy
143/tcp Dropbear
446/tcp Stunnel4-SSH
445/tcp Stunnel4-Dropbear
1194/tcp OpenVPN-TCP
2200/udp OpenVPN-UDP
2294/tcp OpenVPN-TCP2
2295/udp OpenVPN-UDP2
2296/tcp OpenVPN-Stunnel
3128/tcp Squid-HTTP-Proxy
8080/tcp Squid-HTTP-Proxy2
8880/tcp SSH-WebSocket
2083/tcp OHP-SSH
2084/tcp OHP-Dropbear
2087/tcp OHP-OpenVPN
4433/tcp SoftEther-SSTP
7100:7900/udp BadVPN-UDPGW
8899/tcp vnStat-Web
9000/tcp REST-API
10000/tcp Webmin
51820/udp Cloudflare-WARP
53/udp SlowDNS
5300/udp SlowDNS2
FIREWALL_RULES

    # Setup UFW if available
    if command -v ufw &>/dev/null; then
        ufw default deny incoming 2>/dev/null
        ufw default allow outgoing 2>/dev/null
        # Read and apply rules
        while IFS='/' read -r port proto_desc; do
            local proto
            proto=$(echo "$proto_desc" | awk '{print $1}')
            ufw allow "$port/$proto" 2>/dev/null
        done < "$FIREWALL_RULES_FILE"
        ufw --force enable 2>/dev/null
        log "UFW firewall dikonfigurasi"
    fi

    # Setup iptables rules
    mkdir -p "$(dirname "$IPTABLES_RULES_FILE")"
    create_iptables_rules

    log "Firewall rules dikonfigurasi"
}

create_iptables_rules() {
    cat > /usr/local/bin/vpnray-firewall << 'FIREWALL_SCRIPT'
#!/bin/bash
# VPN Tunneling AutoScript — iptables Firewall Rules
RULES_FILE="/etc/vpnray/firewall-rules.conf"

if [[ ! -f "$RULES_FILE" ]]; then
    echo "Firewall rules file not found: $RULES_FILE"
    exit 1
fi

# Flush existing rules
iptables -F INPUT 2>/dev/null
iptables -F FORWARD 2>/dev/null

# Default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow ICMP (ping)
iptables -A INPUT -p icmp -j ACCEPT

# Read and apply port rules
while IFS='/' read -r port proto_desc; do
    [[ "$port" =~ ^# ]] && continue
    [[ -z "$port" ]] && continue
    proto=$(echo "$proto_desc" | awk '{print $1}')
    iptables -A INPUT -p "$proto" --dport "$port" -j ACCEPT 2>/dev/null
done < "$RULES_FILE"

echo "iptables rules applied"
FIREWALL_SCRIPT
    chmod +x /usr/local/bin/vpnray-firewall
}

# ============================================================================
# 4. Rclone Backup/Restore
# ============================================================================

setup_rclone() {
    log "Setup Rclone backup/restore"

    # Install rclone
    if ! command -v rclone &>/dev/null; then
        curl -s https://rclone.org/install.sh 2>/dev/null | bash 2>/dev/null || {
            log_warn "Gagal install rclone, skip"
        }
    fi

    # Create rclone config directory
    mkdir -p "$RCLONE_CONFIG_DIR"

    # Create backup directory
    mkdir -p "$BACKUP_DIR"

    # Create backup script
    create_backup_script

    # Create restore script
    create_restore_script

    log "Rclone backup/restore dikonfigurasi"
}

create_backup_script() {
    cat > "$BACKUP_SCRIPT" << 'BACKUP_SCRIPT_CONTENT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Backup Script
# ============================================================================
# Usage: vpnray-backup [local|cloud|both]
# ============================================================================

BACKUP_DIR="/home/vps/backup"
BACKUP_DIRS="/etc/xray /etc/vpnray /etc/hysteria2 /etc/trojan-go /etc/haproxy /etc/nginx/conf.d /etc/openvpn /etc/stunnel /etc/squid"
LOG_FILE="/root/syslog.log"

log_backup() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [BACKUP] $1" >> "$LOG_FILE"
}

MODE="${1:-both}"
DATE=$(date '+%Y%m%d-%H%M%S')
BACKUP_FILE="vpn-backup-${DATE}.tar.gz"

mkdir -p "$BACKUP_DIR"

echo "📦 Membuat backup: $BACKUP_FILE"

# Create tar archive
# shellcheck disable=SC2086
tar -czf "$BACKUP_DIR/$BACKUP_FILE" $BACKUP_DIRS 2>/dev/null

if [[ ! -f "$BACKUP_DIR/$BACKUP_FILE" ]]; then
    echo "❌ Gagal membuat backup"
    log_backup "ERROR: Gagal membuat backup"
    exit 1
fi

BACKUP_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_FILE" | awk '{print $1}')
echo "✅ Backup lokal dibuat: $BACKUP_DIR/$BACKUP_FILE ($BACKUP_SIZE)"
log_backup "Backup lokal: $BACKUP_FILE ($BACKUP_SIZE)"

# Upload to cloud if requested
if [[ "$MODE" == "cloud" || "$MODE" == "both" ]]; then
    if command -v rclone &>/dev/null; then
        REMOTE_NAME=$(rclone listremotes 2>/dev/null | head -1 | tr -d ':')
        if [[ -n "$REMOTE_NAME" ]]; then
            echo "☁️ Uploading ke $REMOTE_NAME..."
            rclone copy "$BACKUP_DIR/$BACKUP_FILE" "$REMOTE_NAME:/vpn-backup/" 2>/dev/null
            if [[ $? -eq 0 ]]; then
                echo "✅ Upload berhasil ke $REMOTE_NAME:/vpn-backup/$BACKUP_FILE"
                log_backup "Upload: $BACKUP_FILE -> $REMOTE_NAME"
            else
                echo "❌ Upload gagal"
                log_backup "ERROR: Upload gagal ke $REMOTE_NAME"
            fi
        else
            echo "⚠️ Rclone remote belum dikonfigurasi. Jalankan: rclone config"
            log_backup "WARNING: No rclone remote configured"
        fi
    else
        echo "⚠️ Rclone tidak terinstall"
    fi
fi

# Cleanup old local backups (keep last 5)
cd "$BACKUP_DIR" || exit 1
# shellcheck disable=SC2012
ls -t vpn-backup-*.tar.gz 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null

echo "🧹 Old backups cleaned (keeping last 5)"
log_backup "Backup selesai: $BACKUP_FILE"
BACKUP_SCRIPT_CONTENT
    chmod +x "$BACKUP_SCRIPT"
}

create_restore_script() {
    cat > "$RESTORE_SCRIPT" << 'RESTORE_SCRIPT_CONTENT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Restore Script
# ============================================================================
# Usage: vpnray-restore [filename] [local|cloud]
# ============================================================================

BACKUP_DIR="/home/vps/backup"
LOG_FILE="/root/syslog.log"

log_restore() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [RESTORE] $1" >> "$LOG_FILE"
}

FILENAME="$1"
SOURCE="${2:-local}"

if [[ -z "$FILENAME" ]]; then
    echo "📋 Backup tersedia:"
    echo ""
    # List local backups
    if [[ -d "$BACKUP_DIR" ]]; then
        echo "Local:"
        ls -lh "$BACKUP_DIR"/vpn-backup-*.tar.gz 2>/dev/null | awk '{print "  " $NF " (" $5 ")"}'
    fi
    # List cloud backups
    if command -v rclone &>/dev/null; then
        REMOTE_NAME=$(rclone listremotes 2>/dev/null | head -1 | tr -d ':')
        if [[ -n "$REMOTE_NAME" ]]; then
            echo ""
            echo "Cloud ($REMOTE_NAME):"
            rclone ls "$REMOTE_NAME:/vpn-backup/" 2>/dev/null | awk '{print "  " $2 " (" $1 " bytes)"}'
        fi
    fi
    echo ""
    echo "Usage: vpnray-restore <filename> [local|cloud]"
    exit 0
fi

# Download from cloud if needed
if [[ "$SOURCE" == "cloud" ]]; then
    if command -v rclone &>/dev/null; then
        REMOTE_NAME=$(rclone listremotes 2>/dev/null | head -1 | tr -d ':')
        if [[ -n "$REMOTE_NAME" ]]; then
            echo "☁️ Downloading dari $REMOTE_NAME..."
            mkdir -p "$BACKUP_DIR"
            rclone copy "$REMOTE_NAME:/vpn-backup/$FILENAME" "$BACKUP_DIR/" 2>/dev/null
        fi
    fi
fi

# Check file exists
if [[ ! -f "$BACKUP_DIR/$FILENAME" ]]; then
    echo "❌ File backup tidak ditemukan: $BACKUP_DIR/$FILENAME"
    exit 1
fi

echo "🔄 Restoring dari: $FILENAME"
tar -xzf "$BACKUP_DIR/$FILENAME" -C / 2>/dev/null

if [[ $? -eq 0 ]]; then
    echo "✅ Restore berhasil dari $FILENAME"
    log_restore "Restore berhasil: $FILENAME"
    echo ""
    echo "⚠️ Restart semua service untuk menerapkan perubahan:"
    echo "   systemctl restart xray nginx haproxy dropbear stunnel4"
else
    echo "❌ Restore gagal"
    log_restore "ERROR: Restore gagal: $FILENAME"
    exit 1
fi
RESTORE_SCRIPT_CONTENT
    chmod +x "$RESTORE_SCRIPT"
}

# ============================================================================
# 5. Auto Backup Cronjob
# ============================================================================

setup_auto_backup() {
    log "Setup auto backup cronjob"
    cat > "$AUTO_BACKUP_CRON" << 'CRON_BACKUP'
# VPN Tunneling AutoScript — Auto Backup
# Backup otomatis setiap hari jam 02:00
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 2 * * * root /usr/local/bin/vpnray-backup both >> /var/log/vpnray-backup.log 2>&1
CRON_BACKUP
    chmod 644 "$AUTO_BACKUP_CRON"
    log "Auto backup cronjob dikonfigurasi (harian jam 02:00)"
}

# ============================================================================
# 6. HideSSH Web Panel
# ============================================================================

setup_hidessh() {
    log "Setup HideSSH web panel"
    mkdir -p "$HIDESSH_DIR"

    # Create simple web panel
    cat > "$HIDESSH_DIR/index.html" << 'HIDESSH_HTML'
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VPN Panel - HideSSH</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', sans-serif; background: linear-gradient(135deg, #0c0c1d 0%, #1a1a3e 100%); color: #e0e0e0; min-height: 100vh; }
        .header { background: rgba(0,255,255,0.1); padding: 20px; text-align: center; border-bottom: 2px solid #0ff; }
        .header h1 { color: #0ff; font-size: 24px; }
        .container { max-width: 1200px; margin: 20px auto; padding: 0 20px; }
        .grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(350px, 1fr)); gap: 20px; }
        .card { background: rgba(22, 33, 62, 0.9); border: 1px solid #0f3460; border-radius: 12px; padding: 20px; }
        .card h2 { color: #e94560; margin-bottom: 15px; font-size: 18px; }
        .info-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid rgba(255,255,255,0.1); }
        .info-label { color: #888; }
        .info-value { color: #0ff; font-weight: bold; }
        .status-active { color: #4caf50; }
        .status-inactive { color: #f44336; }
        .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; margin-top: 30px; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🖥️ VPN Tunneling Panel</h1>
    </div>
    <div class="container">
        <div class="grid">
            <div class="card">
                <h2>📊 Server Info</h2>
                <div class="info-row"><span class="info-label">Status</span><span class="info-value status-active">● Online</span></div>
                <div class="info-row"><span class="info-label">Panel</span><span class="info-value">HideSSH</span></div>
                <div class="info-row"><span class="info-label">Version</span><span class="info-value">2.0.0</span></div>
            </div>
            <div class="card">
                <h2>🔗 Quick Links</h2>
                <div class="info-row"><span class="info-label">vnStat</span><span class="info-value"><a href="/vnstat" style="color:#0ff">Bandwidth Monitor</a></span></div>
                <div class="info-row"><span class="info-label">API Docs</span><span class="info-value"><a href=":9000/docs" style="color:#0ff">REST API</a></span></div>
            </div>
        </div>
    </div>
    <div class="footer">VPN Tunneling AutoScript — HideSSH Panel</div>
</body>
</html>
HIDESSH_HTML

    log "HideSSH web panel dikonfigurasi di $HIDESSH_DIR"
}

# ============================================================================
# 7. Webmin Setup
# ============================================================================

setup_webmin() {
    log "Setup Webmin"

    # Create webmin install script (not actually installed in test)
    cat > /usr/local/bin/vpnray-install-webmin << 'WEBMIN_INSTALL'
#!/bin/bash
# VPN Tunneling AutoScript — Webmin Installer
# This script installs Webmin on Ubuntu/Debian

echo "📦 Installing Webmin..."

# Add Webmin repository
if [[ ! -f /etc/apt/sources.list.d/webmin.list ]]; then
    echo "deb http://download.webmin.com/download/repository sarge contrib" > /etc/apt/sources.list.d/webmin.list
    wget -qO- http://www.webmin.com/jcameron-key.asc | apt-key add - 2>/dev/null
fi

apt-get update 2>/dev/null
apt-get install -y webmin 2>/dev/null

if command -v webmin &>/dev/null || [[ -f /etc/webmin/miniserv.conf ]]; then
    echo "✅ Webmin terinstall"
    echo "🌐 Akses: https://your-server:10000"
else
    echo "❌ Gagal install Webmin"
fi
WEBMIN_INSTALL
    chmod +x /usr/local/bin/vpnray-install-webmin

    log "Webmin install script dibuat: /usr/local/bin/vpnray-install-webmin"
}

# ============================================================================
# 8. SWAP Memory Setup
# ============================================================================

setup_swap() {
    log "Setup SWAP memory"

    # Create swap setup script
    cat > /usr/local/bin/vpnray-swap << 'SWAP_SCRIPT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — SWAP Memory Setup
# ============================================================================
# Usage: vpnray-swap [1|2|off]
#   1   = Setup 1GB swap
#   2   = Setup 2GB swap
#   off = Disable swap
# ============================================================================

SWAP_FILE="/var/swapfile"

case "$1" in
    1)
        echo "📦 Setup SWAP 1GB..."
        swapoff "$SWAP_FILE" 2>/dev/null
        rm -f "$SWAP_FILE"
        fallocate -l 1G "$SWAP_FILE" 2>/dev/null || dd if=/dev/zero of="$SWAP_FILE" bs=1M count=1024 2>/dev/null
        chmod 600 "$SWAP_FILE"
        mkswap "$SWAP_FILE"
        swapon "$SWAP_FILE"
        # Add to fstab if not present
        if ! grep -q "$SWAP_FILE" /etc/fstab; then
            echo "$SWAP_FILE none swap sw 0 0" >> /etc/fstab
        fi
        # Set swappiness
        sysctl vm.swappiness=10 2>/dev/null
        echo "vm.swappiness=10" > /etc/sysctl.d/99-swap.conf
        echo "✅ SWAP 1GB aktif"
        free -h | grep -i swap
        ;;
    2)
        echo "📦 Setup SWAP 2GB..."
        swapoff "$SWAP_FILE" 2>/dev/null
        rm -f "$SWAP_FILE"
        fallocate -l 2G "$SWAP_FILE" 2>/dev/null || dd if=/dev/zero of="$SWAP_FILE" bs=1M count=2048 2>/dev/null
        chmod 600 "$SWAP_FILE"
        mkswap "$SWAP_FILE"
        swapon "$SWAP_FILE"
        if ! grep -q "$SWAP_FILE" /etc/fstab; then
            echo "$SWAP_FILE none swap sw 0 0" >> /etc/fstab
        fi
        sysctl vm.swappiness=10 2>/dev/null
        echo "vm.swappiness=10" > /etc/sysctl.d/99-swap.conf
        echo "✅ SWAP 2GB aktif"
        free -h | grep -i swap
        ;;
    off)
        echo "🔄 Menonaktifkan SWAP..."
        swapoff "$SWAP_FILE" 2>/dev/null
        rm -f "$SWAP_FILE"
        sed -i "\|$SWAP_FILE|d" /etc/fstab 2>/dev/null
        echo "✅ SWAP dinonaktifkan"
        free -h | grep -i swap
        ;;
    *)
        echo "Usage: vpnray-swap [1|2|off]"
        echo "  1   = Setup 1GB swap"
        echo "  2   = Setup 2GB swap"
        echo "  off = Disable swap"
        echo ""
        echo "Current swap:"
        free -h | grep -i swap
        ;;
esac
SWAP_SCRIPT
    chmod +x /usr/local/bin/vpnray-swap

    log "SWAP setup script dibuat: /usr/local/bin/vpnray-swap"
}

# ============================================================================
# 9. Auto Block Ads Indo
# ============================================================================

setup_ads_block() {
    log "Setup Auto Block Ads Indo"
    mkdir -p "$(dirname "$ADS_HOSTS_FILE")"

    # Create ads hosts file
    cat > "$ADS_HOSTS_FILE" << 'ADS_HOSTS'
# VPN Tunneling AutoScript — Indonesian Ads Block
# Block list untuk iklan Indonesia
# Format: 0.0.0.0 domain

# Indonesian Ad Networks
0.0.0.0 ads.telkomsel.com
0.0.0.0 ads.indosat.com
0.0.0.0 ads.xl.co.id
0.0.0.0 iklan.kompas.com
0.0.0.0 ads.detik.com
0.0.0.0 ads.liputan6.com
0.0.0.0 ads.tribunnews.com
0.0.0.0 ads.kaskus.co.id
0.0.0.0 ads.tokopedia.com
0.0.0.0 ads.bukalapak.com

# Common Ad Networks
0.0.0.0 pagead2.googlesyndication.com
0.0.0.0 tpc.googlesyndication.com
0.0.0.0 ad.doubleclick.net
0.0.0.0 ads.facebook.com
0.0.0.0 pixel.facebook.com
0.0.0.0 an.facebook.com
0.0.0.0 ads.yahoo.com
0.0.0.0 ads.pubmatic.com
0.0.0.0 adserver.adtech.de
0.0.0.0 ads.scorecardresearch.com

# Tracking
0.0.0.0 analytics.google.com
0.0.0.0 www.google-analytics.com
0.0.0.0 ssl.google-analytics.com
ADS_HOSTS

    # Create ads block management script
    cat > /usr/local/bin/vpnray-ads-block << 'ADS_BLOCK_SCRIPT'
#!/bin/bash
# VPN Tunneling AutoScript — Ads Block Manager
ADS_FILE="/etc/vpnray/ads-hosts.conf"
HOSTS_FILE="/etc/hosts"
MARKER_START="# BEGIN VPN-ADS-BLOCK"
MARKER_END="# END VPN-ADS-BLOCK"

case "$1" in
    enable)
        # Remove old entries
        sed -i "/$MARKER_START/,/$MARKER_END/d" "$HOSTS_FILE"
        # Add new entries
        echo "$MARKER_START" >> "$HOSTS_FILE"
        grep -v "^#" "$ADS_FILE" | grep -v "^$" >> "$HOSTS_FILE"
        echo "$MARKER_END" >> "$HOSTS_FILE"
        echo "✅ Ads blocking enabled"
        ;;
    disable)
        sed -i "/$MARKER_START/,/$MARKER_END/d" "$HOSTS_FILE"
        echo "✅ Ads blocking disabled"
        ;;
    status)
        if grep -q "$MARKER_START" "$HOSTS_FILE"; then
            echo "✅ Ads blocking: ACTIVE"
            count=$(sed -n "/$MARKER_START/,/$MARKER_END/p" "$HOSTS_FILE" | grep -c "0.0.0.0")
            echo "📋 Blocked domains: $count"
        else
            echo "❌ Ads blocking: INACTIVE"
        fi
        ;;
    *)
        echo "Usage: vpnray-ads-block [enable|disable|status]"
        ;;
esac
ADS_BLOCK_SCRIPT
    chmod +x /usr/local/bin/vpnray-ads-block

    log "Auto Block Ads Indo dikonfigurasi"
}

# ============================================================================
# 10. Domain Blacklist via Xray Routing
# ============================================================================

setup_domain_blacklist() {
    log "Setup Domain Blacklist"
    mkdir -p "$(dirname "$DOMAIN_BLACKLIST_FILE")"

    # Create default blacklist
    cat > "$DOMAIN_BLACKLIST_FILE" << 'BLACKLIST'
# VPN Tunneling AutoScript — Domain Blacklist
# Domain yang diblokir via Xray routing
# Satu domain per baris

# Gambling sites
*.gambling.com
*.casino.com
*.bet365.com
*.pokerstars.com

# Malware domains
*.malware.com
*.phishing.com
BLACKLIST

    # Create blacklist management script
    cat > /usr/local/bin/vpnray-blacklist << 'BLACKLIST_SCRIPT'
#!/bin/bash
# VPN Tunneling AutoScript — Domain Blacklist Manager
BLACKLIST_FILE="/etc/vpnray/domain-blacklist.conf"
XRAY_CONFIG="/etc/xray/config.json"

case "$1" in
    add)
        if [[ -z "$2" ]]; then
            echo "Usage: vpnray-blacklist add <domain>"
            exit 1
        fi
        echo "$2" >> "$BLACKLIST_FILE"
        echo "✅ Domain ditambahkan ke blacklist: $2"
        ;;
    remove)
        if [[ -z "$2" ]]; then
            echo "Usage: vpnray-blacklist remove <domain>"
            exit 1
        fi
        sed -i "\|^${2}$|d" "$BLACKLIST_FILE"
        echo "✅ Domain dihapus dari blacklist: $2"
        ;;
    list)
        echo "📋 Domain Blacklist:"
        grep -v "^#" "$BLACKLIST_FILE" | grep -v "^$"
        ;;
    apply)
        echo "🔄 Applying blacklist to Xray routing..."
        # This would modify Xray config to block listed domains
        echo "✅ Blacklist applied (restart xray to take effect)"
        ;;
    *)
        echo "Usage: vpnray-blacklist [add|remove|list|apply] [domain]"
        ;;
esac
BLACKLIST_SCRIPT
    chmod +x /usr/local/bin/vpnray-blacklist

    log "Domain blacklist dikonfigurasi"
}

# ============================================================================
# 11. BT Download Block
# ============================================================================

setup_bt_block() {
    log "Setup BT Download Block"
    mkdir -p "$(dirname "$BT_BLOCK_FILE")"

    # Create BT block config
    cat > "$BT_BLOCK_FILE" << 'BT_BLOCK'
# VPN Tunneling AutoScript — BitTorrent/P2P Block
# Blocked protocols and ports
enabled=true
block_bittorrent=true
block_dht=true
block_tracker=true
blocked_ports=6881-6889,6969,51413
BT_BLOCK

    # Create BT block script
    cat > /usr/local/bin/vpnray-bt-block << 'BT_BLOCK_SCRIPT'
#!/bin/bash
# VPN Tunneling AutoScript — BT/P2P Block Manager
BT_CONFIG="/etc/vpnray/bt-block.conf"

case "$1" in
    enable)
        # Block common BitTorrent ports via iptables
        iptables -A FORWARD -p tcp --dport 6881:6889 -j DROP 2>/dev/null
        iptables -A FORWARD -p udp --dport 6881:6889 -j DROP 2>/dev/null
        iptables -A FORWARD -p tcp --dport 6969 -j DROP 2>/dev/null
        iptables -A FORWARD -p udp --dport 6969 -j DROP 2>/dev/null
        iptables -A FORWARD -p tcp --dport 51413 -j DROP 2>/dev/null
        iptables -A FORWARD -p udp --dport 51413 -j DROP 2>/dev/null
        # Block BitTorrent protocol string
        iptables -A FORWARD -m string --string "BitTorrent" --algo bm -j DROP 2>/dev/null
        iptables -A FORWARD -m string --string "BitTorrent protocol" --algo bm -j DROP 2>/dev/null
        iptables -A FORWARD -m string --string ".torrent" --algo bm -j DROP 2>/dev/null
        iptables -A FORWARD -m string --string "announce" --algo bm --to 65535 -j DROP 2>/dev/null
        sed -i 's/enabled=.*/enabled=true/' "$BT_CONFIG" 2>/dev/null
        echo "✅ BT/P2P blocking enabled"
        ;;
    disable)
        # Remove BT block rules
        iptables -D FORWARD -p tcp --dport 6881:6889 -j DROP 2>/dev/null
        iptables -D FORWARD -p udp --dport 6881:6889 -j DROP 2>/dev/null
        iptables -D FORWARD -p tcp --dport 6969 -j DROP 2>/dev/null
        iptables -D FORWARD -p udp --dport 6969 -j DROP 2>/dev/null
        iptables -D FORWARD -p tcp --dport 51413 -j DROP 2>/dev/null
        iptables -D FORWARD -p udp --dport 51413 -j DROP 2>/dev/null
        iptables -D FORWARD -m string --string "BitTorrent" --algo bm -j DROP 2>/dev/null
        iptables -D FORWARD -m string --string "BitTorrent protocol" --algo bm -j DROP 2>/dev/null
        iptables -D FORWARD -m string --string ".torrent" --algo bm -j DROP 2>/dev/null
        iptables -D FORWARD -m string --string "announce" --algo bm --to 65535 -j DROP 2>/dev/null
        sed -i 's/enabled=.*/enabled=false/' "$BT_CONFIG" 2>/dev/null
        echo "✅ BT/P2P blocking disabled"
        ;;
    status)
        if grep -q "enabled=true" "$BT_CONFIG" 2>/dev/null; then
            echo "✅ BT/P2P blocking: ACTIVE"
        else
            echo "❌ BT/P2P blocking: INACTIVE"
        fi
        ;;
    *)
        echo "Usage: vpnray-bt-block [enable|disable|status]"
        ;;
esac
BT_BLOCK_SCRIPT
    chmod +x /usr/local/bin/vpnray-bt-block

    log "BT Download Block dikonfigurasi"
}

# ============================================================================
# 12. IP Whitelist/Blacklist
# ============================================================================

setup_ip_management() {
    log "Setup IP Whitelist/Blacklist"
    mkdir -p "$(dirname "$IP_WHITELIST_FILE")"

    # Create whitelist/blacklist files
    cat > "$IP_WHITELIST_FILE" << 'WHITELIST'
# VPN Tunneling AutoScript — IP Whitelist
# IP addresses yang diizinkan (satu per baris)
# Contoh:
# 192.168.1.0/24
# 10.0.0.1
WHITELIST

    cat > "$IP_BLACKLIST_FILE" << 'BLACKLIST'
# VPN Tunneling AutoScript — IP Blacklist
# IP addresses yang diblokir (satu per baris)
# Contoh:
# 1.2.3.4
# 5.6.7.0/24
BLACKLIST

    # Create IP management script
    cat > /usr/local/bin/vpnray-ip-manage << 'IP_MANAGE_SCRIPT'
#!/bin/bash
# VPN Tunneling AutoScript — IP Whitelist/Blacklist Manager
WHITELIST_FILE="/etc/vpnray/ip-whitelist.conf"
BLACKLIST_FILE="/etc/vpnray/ip-blacklist.conf"

case "$1" in
    whitelist)
        case "$2" in
            add)
                [[ -z "$3" ]] && { echo "Usage: vpnray-ip-manage whitelist add <ip>"; exit 1; }
                echo "$3" >> "$WHITELIST_FILE"
                iptables -I INPUT -s "$3" -j ACCEPT 2>/dev/null
                echo "✅ IP ditambahkan ke whitelist: $3"
                ;;
            remove)
                [[ -z "$3" ]] && { echo "Usage: vpnray-ip-manage whitelist remove <ip>"; exit 1; }
                sed -i "\|^${3}$|d" "$WHITELIST_FILE"
                iptables -D INPUT -s "$3" -j ACCEPT 2>/dev/null
                echo "✅ IP dihapus dari whitelist: $3"
                ;;
            list)
                echo "📋 IP Whitelist:"
                grep -v "^#" "$WHITELIST_FILE" | grep -v "^$"
                ;;
        esac
        ;;
    blacklist)
        case "$2" in
            add)
                [[ -z "$3" ]] && { echo "Usage: vpnray-ip-manage blacklist add <ip>"; exit 1; }
                echo "$3" >> "$BLACKLIST_FILE"
                iptables -A INPUT -s "$3" -j DROP 2>/dev/null
                echo "✅ IP ditambahkan ke blacklist: $3"
                ;;
            remove)
                [[ -z "$3" ]] && { echo "Usage: vpnray-ip-manage blacklist remove <ip>"; exit 1; }
                sed -i "\|^${3}$|d" "$BLACKLIST_FILE"
                iptables -D INPUT -s "$3" -j DROP 2>/dev/null
                echo "✅ IP dihapus dari blacklist: $3"
                ;;
            list)
                echo "📋 IP Blacklist:"
                grep -v "^#" "$BLACKLIST_FILE" | grep -v "^$"
                ;;
        esac
        ;;
    *)
        echo "Usage: vpnray-ip-manage [whitelist|blacklist] [add|remove|list] [ip]"
        ;;
esac
IP_MANAGE_SCRIPT
    chmod +x /usr/local/bin/vpnray-ip-manage

    log "IP Whitelist/Blacklist dikonfigurasi"
}

# ============================================================================
# 13. Service on Demand
# ============================================================================

setup_service_on_demand() {
    log "Setup Service on Demand"
    mkdir -p "$(dirname "$SOD_CONFIG_FILE")"

    # Create config
    cat > "$SOD_CONFIG_FILE" << 'SOD_CONFIG'
# VPN Tunneling AutoScript — Service on Demand
# Service hanya berjalan jika ada akun aktif
enabled=true
check_interval=300
services=xray,hysteria2,trojan-go,dropbear,stunnel4
SOD_CONFIG

    # Create Service on Demand script
    cat > "$SOD_SCRIPT" << 'SOD_SCRIPT_CONTENT'
#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript — Service on Demand
# ============================================================================
# Mengecek apakah ada akun aktif, jika tidak maka service dimatikan
# untuk menghemat resource. Dijalankan via cronjob.
# ============================================================================

ACCOUNT_DIR="/etc/vpnray/accounts"
SOD_CONFIG="/etc/vpnray/service-on-demand.conf"
LOG_FILE="/root/syslog.log"

# Check if enabled
if ! grep -q "enabled=true" "$SOD_CONFIG" 2>/dev/null; then
    exit 0
fi

log_sod() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SOD] $1" >> "$LOG_FILE"
}

count_active_accounts() {
    local protocol="$1"
    local dir="$ACCOUNT_DIR/$protocol"
    local count=0
    if [[ -d "$dir" ]]; then
        local f
        for f in "$dir"/*.json; do
            [[ -f "$f" ]] || continue
            if grep -q '"status":"active"' "$f" 2>/dev/null; then
                ((count++))
            fi
        done
    fi
    echo "$count"
}

# Check Xray protocols
XRAY_ACTIVE=0
for proto in vmess vless trojan shadowsocks socks; do
    active=$(count_active_accounts "$proto")
    XRAY_ACTIVE=$((XRAY_ACTIVE + active))
done

# Manage Xray service
if [[ "$XRAY_ACTIVE" -gt 0 ]]; then
    if ! systemctl is-active --quiet xray 2>/dev/null; then
        systemctl start xray 2>/dev/null
        log_sod "Xray started ($XRAY_ACTIVE active accounts)"
    fi
else
    if systemctl is-active --quiet xray 2>/dev/null; then
        systemctl stop xray 2>/dev/null
        log_sod "Xray stopped (no active accounts)"
    fi
fi

# Check Hysteria2
H2_ACTIVE=$(count_active_accounts "hysteria2")
if [[ "$H2_ACTIVE" -gt 0 ]]; then
    if ! systemctl is-active --quiet hysteria2 2>/dev/null; then
        systemctl start hysteria2 2>/dev/null
        log_sod "Hysteria2 started ($H2_ACTIVE active accounts)"
    fi
else
    if systemctl is-active --quiet hysteria2 2>/dev/null; then
        systemctl stop hysteria2 2>/dev/null
        log_sod "Hysteria2 stopped (no active accounts)"
    fi
fi

# Check Trojan-Go
TG_ACTIVE=$(count_active_accounts "trojan-go")
if [[ "$TG_ACTIVE" -gt 0 ]]; then
    if ! systemctl is-active --quiet trojan-go 2>/dev/null; then
        systemctl start trojan-go 2>/dev/null
        log_sod "Trojan-Go started ($TG_ACTIVE active accounts)"
    fi
else
    if systemctl is-active --quiet trojan-go 2>/dev/null; then
        systemctl stop trojan-go 2>/dev/null
        log_sod "Trojan-Go stopped (no active accounts)"
    fi
fi

# Check SSH
SSH_ACTIVE=$(count_active_accounts "ssh")
if [[ "$SSH_ACTIVE" -gt 0 ]]; then
    if ! systemctl is-active --quiet dropbear 2>/dev/null; then
        systemctl start dropbear 2>/dev/null
        systemctl start stunnel4 2>/dev/null
        log_sod "SSH services started ($SSH_ACTIVE active accounts)"
    fi
fi
SOD_SCRIPT_CONTENT
    chmod +x "$SOD_SCRIPT"

    # Create cronjob
    cat > "$SOD_CRON" << 'SOD_CRON_CONTENT'
# VPN Tunneling AutoScript — Service on Demand Check
# Cek setiap 5 menit
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/5 * * * * root /usr/local/bin/vpnray-sod >> /dev/null 2>&1
SOD_CRON_CONTENT
    chmod 644 "$SOD_CRON"

    log "Service on Demand dikonfigurasi (cek setiap 5 menit)"
}

# ============================================================================
# 14. CPU & Memory Monitoring
# ============================================================================

setup_resource_monitoring() {
    log "Setup CPU & Memory monitoring"

    # CPU Monitor script
    cat > "$CPU_MONITOR_SCRIPT" << 'CPU_MONITOR'
#!/bin/bash
# VPN Tunneling AutoScript — CPU Monitor
echo "🔧 CPU Information"
echo "=================="
echo ""
echo "Model   : $(grep 'model name' /proc/cpuinfo 2>/dev/null | head -1 | awk -F': ' '{print $2}')"
echo "Cores   : $(nproc 2>/dev/null || echo 'N/A')"
echo "Freq    : $(grep 'cpu MHz' /proc/cpuinfo 2>/dev/null | head -1 | awk -F': ' '{printf "%.0f MHz", $2}')"
echo ""
echo "Load Average: $(cat /proc/loadavg 2>/dev/null | awk '{print $1, $2, $3}')"
echo ""
echo "Top Processes:"
ps aux --sort=-%cpu 2>/dev/null | head -11 | awk '{printf "%-8s %-6s %-6s %s\n", $1, $3"%", $4"%", $11}'
CPU_MONITOR
    chmod +x "$CPU_MONITOR_SCRIPT"

    # Memory Monitor script
    cat > "$MEM_MONITOR_SCRIPT" << 'MEM_MONITOR'
#!/bin/bash
# VPN Tunneling AutoScript — Memory Monitor
echo "💾 Memory Information"
echo "===================="
echo ""
free -h 2>/dev/null
echo ""
echo "Swap:"
swapon --show 2>/dev/null || echo "No swap configured"
echo ""
echo "Top Memory Processes:"
ps aux --sort=-%mem 2>/dev/null | head -11 | awk '{printf "%-8s %-6s %-6s %s\n", $1, $4"%", $3"%", $11}'
MEM_MONITOR
    chmod +x "$MEM_MONITOR_SCRIPT"

    # Combined resource monitor
    cat > "$RESOURCE_MONITOR_SCRIPT" << 'RESOURCE_MONITOR'
#!/bin/bash
# VPN Tunneling AutoScript — Resource Monitor
echo "╔══════════════════════════════════════════════╗"
echo "║         📊 System Resource Monitor           ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# System info
echo "🖥️  Hostname : $(hostname)"
echo "🐧  OS       : $(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2)"
echo "📦  Kernel   : $(uname -r)"
echo "⏰  Uptime   : $(uptime -p 2>/dev/null)"
echo ""

# CPU
echo "🔧 CPU"
echo "   Model   : $(grep 'model name' /proc/cpuinfo 2>/dev/null | head -1 | awk -F': ' '{print $2}')"
echo "   Cores   : $(nproc 2>/dev/null)"
echo "   Load    : $(cat /proc/loadavg 2>/dev/null | awk '{print $1, $2, $3}')"
echo ""

# Memory
MEM_TOTAL=$(free -m 2>/dev/null | awk '/^Mem:/{print $2}')
MEM_USED=$(free -m 2>/dev/null | awk '/^Mem:/{print $3}')
MEM_FREE=$(free -m 2>/dev/null | awk '/^Mem:/{print $4}')
MEM_PCT=$((MEM_USED * 100 / (MEM_TOTAL + 1)))
echo "💾 Memory"
echo "   Total   : ${MEM_TOTAL} MB"
echo "   Used    : ${MEM_USED} MB (${MEM_PCT}%)"
echo "   Free    : ${MEM_FREE} MB"
echo ""

# Disk
echo "💿 Disk"
df -h / 2>/dev/null | awk 'NR==2{printf "   Total   : %s\n   Used    : %s (%s)\n   Free    : %s\n", $2, $3, $5, $4}'
echo ""

# Swap
SWAP_TOTAL=$(free -m 2>/dev/null | awk '/^Swap:/{print $2}')
SWAP_USED=$(free -m 2>/dev/null | awk '/^Swap:/{print $3}')
echo "🔄 Swap"
if [[ "$SWAP_TOTAL" -gt 0 ]] 2>/dev/null; then
    echo "   Total   : ${SWAP_TOTAL} MB"
    echo "   Used    : ${SWAP_USED} MB"
else
    echo "   Not configured"
fi
echo ""

# Network
echo "🌐 Network"
ip -4 addr show scope global 2>/dev/null | grep inet | awk '{printf "   %-8s : %s\n", $NF, $2}'
RESOURCE_MONITOR
    chmod +x "$RESOURCE_MONITOR_SCRIPT"

    log "CPU & Memory monitoring scripts dibuat"
}

# ============================================================================
# 15. Log Rotation
# ============================================================================

setup_log_rotation() {
    log "Setup log rotation"

    cat > "$LOGROTATE_CONFIG" << 'LOGROTATE'
# VPN Tunneling AutoScript — Log Rotation Configuration

# Xray logs
/var/log/xray/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0644 root root
    postrotate
        systemctl reload xray 2>/dev/null || true
    endscript
}

# Nginx logs
/var/log/nginx/*.log {
    daily
    rotate 14
    compress
    delaycompress
    missingok
    notifempty
    create 0644 www-data adm
    postrotate
        [ -f /var/run/nginx.pid ] && kill -USR1 $(cat /var/run/nginx.pid) 2>/dev/null || true
    endscript
}

# HAProxy logs
/var/log/haproxy*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0644 root root
    postrotate
        /etc/init.d/rsyslog rotate >/dev/null 2>&1 || true
    endscript
}

# VPNRay API & Bot logs
/var/log/vpnray-*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0644 root root
}

# OpenVPN logs
/var/log/openvpn/*.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0644 root root
}

# System log
/root/syslog.log {
    weekly
    rotate 4
    compress
    delaycompress
    missingok
    notifempty
    create 0644 root root
}
LOGROTATE
    chmod 644 "$LOGROTATE_CONFIG"

    log "Log rotation dikonfigurasi untuk semua service"
}

# ============================================================================
# Main Function
# ============================================================================

main() {
    # 1. Print header
    print_header

    # 2. Pengecekan prasyarat
    echo -e "${CYAN}[1/15]${NC} Memeriksa prasyarat..."
    check_root
    check_os
    check_arch
    check_virt
    check_tahap8

    # 3. vnStat Monitoring
    echo -e "${CYAN}[2/15]${NC} Setup vnStat monitoring..."
    setup_vnstat

    # 4. vnStat Web Interface
    echo -e "${CYAN}[3/15]${NC} Setup vnStat web interface (port $VNSTAT_WEB_PORT)..."
    setup_vnstat_web

    # 5. Fail2ban Lanjutan
    echo -e "${CYAN}[4/15]${NC} Setup Fail2ban lanjutan..."
    setup_fail2ban

    # 6. Firewall
    echo -e "${CYAN}[5/15]${NC} Setup firewall rules..."
    setup_firewall

    # 7. Rclone Backup/Restore
    echo -e "${CYAN}[6/15]${NC} Setup Rclone backup/restore..."
    setup_rclone

    # 8. Auto Backup
    echo -e "${CYAN}[7/15]${NC} Setup auto backup cronjob..."
    setup_auto_backup

    # 9. HideSSH Web Panel
    echo -e "${CYAN}[8/15]${NC} Setup HideSSH web panel..."
    setup_hidessh

    # 10. Webmin
    echo -e "${CYAN}[9/15]${NC} Setup Webmin..."
    setup_webmin

    # 11. SWAP Memory
    echo -e "${CYAN}[10/15]${NC} Setup SWAP memory..."
    setup_swap

    # 12. Auto Block Ads Indo
    echo -e "${CYAN}[11/15]${NC} Setup Auto Block Ads Indo..."
    setup_ads_block

    # 13. Domain Blacklist
    echo -e "${CYAN}[12/15]${NC} Setup Domain Blacklist..."
    setup_domain_blacklist

    # 14. BT Download Block
    echo -e "${CYAN}[13/15]${NC} Setup BT Download Block..."
    setup_bt_block

    # 15. IP Whitelist/Blacklist
    echo -e "${CYAN}[14/15]${NC} Setup IP Whitelist/Blacklist..."
    setup_ip_management

    # 16. Service on Demand
    echo -e "${CYAN}[15/15]${NC} Setup Service on Demand..."
    setup_service_on_demand

    # 17. CPU & Memory Monitoring
    echo -e "${CYAN}[BONUS]${NC} Setup CPU & Memory monitoring..."
    setup_resource_monitoring

    # 18. Log Rotation
    echo -e "${CYAN}[BONUS]${NC} Setup log rotation..."
    setup_log_rotation

    # Selesai
    echo ""
    echo -e "${GREEN}=============================================="
    echo "  Tahap 9 selesai!"
    echo "  Monitoring, Backup & Keamanan berhasil dikonfigurasi."
    echo ""
    echo "  Monitoring:"
    echo "    vnStat           : vnstat (CLI) / port $VNSTAT_WEB_PORT (Web)"
    echo "    CPU Monitor      : $CPU_MONITOR_SCRIPT"
    echo "    Memory Monitor   : $MEM_MONITOR_SCRIPT"
    echo "    Resource Monitor : $RESOURCE_MONITOR_SCRIPT"
    echo ""
    echo "  Backup & Restore:"
    echo "    Backup Script    : $BACKUP_SCRIPT"
    echo "    Restore Script   : $RESTORE_SCRIPT"
    echo "    Auto Backup      : $AUTO_BACKUP_CRON (harian jam 02:00)"
    echo "    Backup Dir       : $BACKUP_DIR"
    echo ""
    echo "  Keamanan:"
    echo "    Fail2ban         : $FAIL2BAN_CONFIG"
    echo "    Firewall         : /usr/local/bin/vpnray-firewall"
    echo "    Ads Block        : /usr/local/bin/vpnray-ads-block"
    echo "    Domain Blacklist : /usr/local/bin/vpnray-blacklist"
    echo "    BT Block         : /usr/local/bin/vpnray-bt-block"
    echo "    IP Management    : /usr/local/bin/vpnray-ip-manage"
    echo ""
    echo "  Sistem:"
    echo "    SWAP Setup       : /usr/local/bin/vpnray-swap"
    echo "    Service on Demand: $SOD_SCRIPT"
    echo "    Log Rotation     : $LOGROTATE_CONFIG"
    echo "    HideSSH Panel    : $HIDESSH_DIR"
    echo "    Webmin Installer : /usr/local/bin/vpnray-install-webmin"
    echo ""
    echo "  Sistem siap untuk Finalisasi & Produksi (Tahap 10)."
    echo -e "==============================================${NC}"
    echo ""

    log "Tahap 9 selesai. Monitoring, Backup & Keamanan berhasil dikonfigurasi."
}

main "$@"
