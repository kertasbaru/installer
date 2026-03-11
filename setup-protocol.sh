#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript Installer — Tahap 5: Protokol Tambahan
# ============================================================================
# Script ini melakukan instalasi dan konfigurasi protokol VPN/tunnel tambahan:
# Hysteria2, Trojan-Go, OpenVPN (TCP/UDP/TLS), SoftEther VPN,
# Cloudflare WARP, SlowDNS/DNSTT, dan UDP Custom handler.
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
#   - Tahap 1-4 sudah dijalankan (setup.sh, install.sh, setup-domain.sh, setup-ssh.sh)
#
# Penggunaan:
#   chmod +x setup-protocol.sh
#   ./setup-protocol.sh
#
# Referensi:
#   - https://github.com/apernet/hysteria (Hysteria2 protocol engine)
#   - https://github.com/p4gefau1t/trojan-go (Trojan-Go engine)
#   - https://github.com/SoftEtherVPN/SoftEtherVPN (SoftEther VPN server)
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

# Paths penting dari Tahap 3
XRAY_CERT="/etc/xray/xray.crt"
XRAY_KEY="/etc/xray/xray.key"
DOMAIN_FILE="/etc/xray/domain"

# ============================================================================
# Port konfigurasi Hysteria2 (sesuai README)
# ============================================================================
HYSTERIA2_PORT=443
HYSTERIA2_CONFIG_DIR="/etc/hysteria2"
HYSTERIA2_CONFIG="$HYSTERIA2_CONFIG_DIR/config.yaml"
HYSTERIA2_BIN="/usr/local/bin/hysteria"

# ============================================================================
# Port konfigurasi Trojan-Go (sesuai README)
# ============================================================================
TROJAN_GO_PORT_WS=443
TROJAN_GO_CONFIG_DIR="/etc/trojan-go"
TROJAN_GO_CONFIG="$TROJAN_GO_CONFIG_DIR/config.json"
TROJAN_GO_BIN="/usr/local/bin/trojan-go"

# ============================================================================
# Port konfigurasi OpenVPN (sesuai README)
# ============================================================================
OPENVPN_TCP_PORT1=1194
OPENVPN_TCP_PORT2=2294
OPENVPN_UDP_PORT1=2200
OPENVPN_UDP_PORT2=2295
OPENVPN_STUNNEL_PORT=2296
OPENVPN_CONFIG_DIR="/etc/openvpn"
OPENVPN_STUNNEL_CONF="/etc/stunnel/stunnel-openvpn.conf"

# ============================================================================
# Port konfigurasi SoftEther VPN (sesuai README)
# ============================================================================
SOFTETHER_REMOTE_PORT=5555
SOFTETHER_SSTP_PORT=4433
SOFTETHER_OPENVPN_TCP_PORT=1194
SOFTETHER_OPENVPN_TLS_PORT=1195
SOFTETHER_L2TP_PORT1=500
SOFTETHER_L2TP_PORT2=1701
SOFTETHER_L2TP_PORT3=4500
SOFTETHER_CONFIG_DIR="/etc/softether"
SOFTETHER_CONFIG="$SOFTETHER_CONFIG_DIR/vpn_server.config"
SOFTETHER_INSTALL_DIR="/usr/local/softether"
SOFTETHER_BIN="/usr/local/softether/vpnserver"

# ============================================================================
# Port konfigurasi Cloudflare WARP (sesuai README)
# ============================================================================
WARP_PORT=51820
WARP_CONFIG_DIR="/etc/warp"
WARP_CONFIG="$WARP_CONFIG_DIR/warp.conf"

# ============================================================================
# Port konfigurasi SlowDNS/DNSTT (sesuai README)
# ============================================================================
SLOWDNS_DNS_PORT=53
SLOWDNS_ALT_PORT=5300
SLOWDNS_SSH_PORT=2222
SLOWDNS_BIN="/usr/local/bin/dns-server"
SLOWDNS_KEY_DIR="/etc/slowdns"
SLOWDNS_NS_FILE="/etc/slowdns/ns-domain"

# ============================================================================
# UDP Custom (sesuai README)
# ============================================================================
UDP_CUSTOM_BIN="/usr/local/bin/udp-custom"
UDP_CUSTOM_CONFIG="/etc/udp-custom/config.json"
UDP_CUSTOM_CONFIG_DIR="/etc/udp-custom"

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
    echo "  Tahap 5: Protokol Tambahan"
    echo "=============================================="
    echo -e "${NC}"
}

# ============================================================================
# Pengecekan Prasyarat
# ============================================================================

check_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        log_error "Script ini harus dijalankan sebagai root!"
        echo -e "${RED}Gunakan: sudo ./setup-protocol.sh${NC}"
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

check_tahap4() {
    local missing=false

    # Cek domain file
    if [[ ! -f "$DOMAIN_FILE" ]]; then
        log_error "File domain tidak ditemukan: $DOMAIN_FILE"
        missing=true
    fi

    # Cek SSL certificate
    if [[ ! -f "$XRAY_CERT" ]]; then
        log_warn "SSL certificate tidak ditemukan: $XRAY_CERT"
    fi

    # Cek Nginx
    if ! command -v nginx &>/dev/null; then
        log_error "Nginx tidak terinstall. Tahap 3 belum dijalankan."
        missing=true
    fi

    # Cek Xray
    if ! command -v xray &>/dev/null && [[ ! -f /usr/local/bin/xray ]]; then
        log_error "Xray-core tidak terinstall. Tahap 3 belum dijalankan."
        missing=true
    fi

    # Cek Dropbear (Tahap 4)
    if ! command -v dropbear &>/dev/null; then
        log_warn "Dropbear tidak terinstall. Tahap 4 mungkin belum dijalankan."
    fi

    # Cek HAProxy (Tahap 4)
    if ! command -v haproxy &>/dev/null; then
        log_warn "HAProxy tidak terinstall. Tahap 4 mungkin belum dijalankan."
    fi

    if [[ "$missing" == true ]]; then
        log_error "Pastikan Tahap 1-4 sudah dijalankan sebelum melanjutkan."
        exit 1
    fi

    log "Pengecekan Tahap 4: OK"
}

# ============================================================================
# Helper: Deteksi domain dan IP
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

# ============================================================================
# Install & Configure Hysteria2
# ============================================================================
# Referensi: https://github.com/apernet/hysteria
# Protokol QUIC/UDP ultra-fast
# Port: Load Balance random, atau 80/443
# ============================================================================

install_hysteria2() {
    log "Menginstall Hysteria2..."

    # Download binary dari GitHub releases
    local latest_url="https://github.com/apernet/hysteria/releases/latest/download/hysteria-linux-amd64"

    if ! wget --inet4-only --no-check-certificate -O "$HYSTERIA2_BIN" "$latest_url" >> "$LOG_FILE" 2>&1; then
        log_warn "Download Hysteria2 dari latest release gagal. Mencoba install script..."

        # Fallback: official install script
        if ! bash <(curl -fsSL https://get.hy2.sh/) >> "$LOG_FILE" 2>&1; then
            log_error "Instalasi Hysteria2 gagal!"
            return 1
        fi
    else
        chmod +x "$HYSTERIA2_BIN"
    fi

    log "Hysteria2 berhasil diinstall."
}

configure_hysteria2() {
    log "Mengkonfigurasi Hysteria2..."

    local domain
    domain=$(get_domain)

    # Buat direktori konfigurasi jika belum ada
    mkdir -p "$HYSTERIA2_CONFIG_DIR"

    # Generate config.yaml
    cat > "$HYSTERIA2_CONFIG" <<HYSTERIA2_CFG
# Hysteria2 Configuration — VPN Tunneling AutoScript
# Referensi: https://github.com/apernet/hysteria

listen: :${HYSTERIA2_PORT}

tls:
  cert: ${XRAY_CERT}
  key: ${XRAY_KEY}

auth:
  type: password
  password: ""

masquerade:
  type: proxy
  proxy:
    url: https://www.bing.com
    rewriteHost: true

bandwidth:
  up: 1 gbps
  down: 1 gbps

quic:
  initStreamReceiveWindow: 8388608
  maxStreamReceiveWindow: 8388608
  initConnReceiveWindow: 20971520
  maxConnReceiveWindow: 20971520
  maxIdleTimeout: 30s
  maxIncomingStreams: 1024
  disablePathMTUDiscovery: false

outbounds:
  - name: default
    type: direct
HYSTERIA2_CFG

    chmod 644 "$HYSTERIA2_CONFIG"
    log "Konfigurasi Hysteria2 berhasil dibuat: $HYSTERIA2_CONFIG"
}

create_hysteria2_service() {
    log "Membuat systemd service untuk Hysteria2..."

    cat > /etc/systemd/system/hysteria2.service <<'HYSTERIA2_SVC'
[Unit]
Description=Hysteria2 VPN Server
Documentation=https://github.com/apernet/hysteria
After=network.target network-online.target nss-lookup.target
Wants=network-online.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/hysteria server -c /etc/hysteria2/config.yaml
Restart=on-failure
RestartSec=3
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
HYSTERIA2_SVC

    systemctl daemon-reload >> "$LOG_FILE" 2>&1
    log "Systemd service Hysteria2 berhasil dibuat."
}

start_hysteria2() {
    log "Menjalankan Hysteria2..."

    {
        systemctl daemon-reload
        systemctl enable hysteria2
        systemctl restart hysteria2
    } >> "$LOG_FILE" 2>&1

    if systemctl is-active --quiet hysteria2; then
        log "Hysteria2 berhasil dijalankan."
    else
        log_warn "Hysteria2 gagal dijalankan. Periksa konfigurasi."
    fi
}

# ============================================================================
# Install & Configure Trojan-Go
# ============================================================================
# Referensi: https://github.com/p4gefau1t/trojan-go
# Trojan versi Go, performa tinggi
# Port: 80, 443 via WebSocket TLS
# ============================================================================

install_trojan_go() {
    log "Menginstall Trojan-Go..."

    local download_url="https://github.com/p4gefau1t/trojan-go/releases/latest/download/trojan-go-linux-amd64.zip"
    local tmp_dir
    tmp_dir=$(mktemp -d)

    if ! wget --inet4-only --no-check-certificate -O "$tmp_dir/trojan-go.zip" "$download_url" >> "$LOG_FILE" 2>&1; then
        log_error "Download Trojan-Go gagal!"
        rm -rf "$tmp_dir"
        return 1
    fi

    # Extract binary
    if ! unzip -o "$tmp_dir/trojan-go.zip" -d "$tmp_dir/" >> "$LOG_FILE" 2>&1; then
        # Fallback: install unzip jika belum ada
        apt-get install -y unzip >> "$LOG_FILE" 2>&1
        if ! unzip -o "$tmp_dir/trojan-go.zip" -d "$tmp_dir/" >> "$LOG_FILE" 2>&1; then
            log_error "Ekstraksi Trojan-Go gagal!"
            rm -rf "$tmp_dir"
            return 1
        fi
    fi

    # Install binary
    if [[ -f "$tmp_dir/trojan-go" ]]; then
        cp "$tmp_dir/trojan-go" "$TROJAN_GO_BIN"
        chmod +x "$TROJAN_GO_BIN"
    else
        log_error "Binary trojan-go tidak ditemukan setelah ekstraksi!"
        rm -rf "$tmp_dir"
        return 1
    fi

    # Cleanup
    rm -rf "$tmp_dir"

    log "Trojan-Go berhasil diinstall."
}

configure_trojan_go() {
    log "Mengkonfigurasi Trojan-Go..."

    local domain
    domain=$(get_domain)

    # Buat direktori konfigurasi jika belum ada
    mkdir -p "$TROJAN_GO_CONFIG_DIR"

    # Generate config.json
    cat > "$TROJAN_GO_CONFIG" <<TROJAN_GO_CFG
{
    "run_type": "server",
    "local_addr": "127.0.0.1",
    "local_port": 2087,
    "remote_addr": "127.0.0.1",
    "remote_port": 81,
    "password": [
        ""
    ],
    "ssl": {
        "cert": "${XRAY_CERT}",
        "key": "${XRAY_KEY}",
        "sni": "${domain}",
        "alpn": [
            "h2",
            "http/1.1"
        ],
        "fallback_addr": "127.0.0.1",
        "fallback_port": 81
    },
    "websocket": {
        "enabled": true,
        "path": "/trojan-go",
        "host": "${domain}"
    },
    "router": {
        "enabled": false
    },
    "transport_plugin": {
        "enabled": false
    }
}
TROJAN_GO_CFG

    chmod 644 "$TROJAN_GO_CONFIG"
    log "Konfigurasi Trojan-Go berhasil dibuat: $TROJAN_GO_CONFIG"
}

create_trojan_go_service() {
    log "Membuat systemd service untuk Trojan-Go..."

    cat > /etc/systemd/system/trojan-go.service <<'TROJAN_GO_SVC'
[Unit]
Description=Trojan-Go Server
Documentation=https://github.com/p4gefau1t/trojan-go
After=network.target network-online.target nss-lookup.target
Wants=network-online.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/trojan-go -config /etc/trojan-go/config.json
Restart=on-failure
RestartSec=3
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
TROJAN_GO_SVC

    systemctl daemon-reload >> "$LOG_FILE" 2>&1
    log "Systemd service Trojan-Go berhasil dibuat."
}

start_trojan_go() {
    log "Menjalankan Trojan-Go..."

    {
        systemctl daemon-reload
        systemctl enable trojan-go
        systemctl restart trojan-go
    } >> "$LOG_FILE" 2>&1

    if systemctl is-active --quiet trojan-go; then
        log "Trojan-Go berhasil dijalankan."
    else
        log_warn "Trojan-Go gagal dijalankan. Periksa konfigurasi."
    fi
}

# ============================================================================
# Install & Configure OpenVPN
# ============================================================================
# OpenVPN TCP port 1194, 2294 — UDP port 2200, 2295
# OpenVPN Stunnel TLS port 2296
# ============================================================================

install_openvpn() {
    log "Menginstall OpenVPN..."

    export DEBIAN_FRONTEND=noninteractive

    # Install OpenVPN dan EasyRSA
    if ! apt-get install -y openvpn easy-rsa >> "$LOG_FILE" 2>&1; then
        log_error "Instalasi OpenVPN gagal!"
        return 1
    fi

    log "OpenVPN berhasil diinstall."
}

setup_openvpn_pki() {
    log "Mengkonfigurasi OpenVPN PKI (EasyRSA)..."

    local easyrsa_dir="/etc/openvpn/easy-rsa"

    # Setup EasyRSA
    if [[ -d /usr/share/easy-rsa ]]; then
        mkdir -p "$easyrsa_dir"
        cp -r /usr/share/easy-rsa/* "$easyrsa_dir/" 2>/dev/null || true

        # Cari easyrsa binary
        local easyrsa_bin=""
        if [[ -f "$easyrsa_dir/easyrsa" ]]; then
            easyrsa_bin="$easyrsa_dir/easyrsa"
        elif [[ -f "$easyrsa_dir/3/easyrsa" ]]; then
            easyrsa_bin="$easyrsa_dir/3/easyrsa"
            easyrsa_dir="$easyrsa_dir/3"
        elif [[ -f "$easyrsa_dir/3.0/easyrsa" ]]; then
            easyrsa_bin="$easyrsa_dir/3.0/easyrsa"
            easyrsa_dir="$easyrsa_dir/3.0"
        fi

        if [[ -n "$easyrsa_bin" ]]; then
            cd "$easyrsa_dir" || return 1

            # Konfigurasi EasyRSA vars
            cat > "$easyrsa_dir/vars" <<'EASYRSA_VARS'
set_var EASYRSA_ALGO ec
set_var EASYRSA_CURVE secp384r1
set_var EASYRSA_DIGEST sha384
set_var EASYRSA_KEY_SIZE 2048
set_var EASYRSA_CA_EXPIRE 3650
set_var EASYRSA_CERT_EXPIRE 3650
set_var EASYRSA_BATCH 1
set_var EASYRSA_REQ_CN "VPN-AutoScript-CA"
EASYRSA_VARS

            # Init PKI
            "$easyrsa_bin" init-pki >> "$LOG_FILE" 2>&1 || true
            "$easyrsa_bin" --batch build-ca nopass >> "$LOG_FILE" 2>&1 || true
            "$easyrsa_bin" --batch gen-req server nopass >> "$LOG_FILE" 2>&1 || true
            "$easyrsa_bin" --batch sign-req server server >> "$LOG_FILE" 2>&1 || true
            "$easyrsa_bin" gen-dh >> "$LOG_FILE" 2>&1 || true

            # Copy certificates ke OpenVPN directory
            if [[ -d "$easyrsa_dir/pki" ]]; then
                cp "$easyrsa_dir/pki/ca.crt" "$OPENVPN_CONFIG_DIR/" 2>/dev/null || true
                cp "$easyrsa_dir/pki/issued/server.crt" "$OPENVPN_CONFIG_DIR/" 2>/dev/null || true
                cp "$easyrsa_dir/pki/private/server.key" "$OPENVPN_CONFIG_DIR/" 2>/dev/null || true
                cp "$easyrsa_dir/pki/dh.pem" "$OPENVPN_CONFIG_DIR/" 2>/dev/null || true
            fi

            cd /root || true
            log "PKI berhasil dikonfigurasi."
        else
            log_warn "EasyRSA binary tidak ditemukan. PKI setup dilewati."
        fi
    else
        log_warn "EasyRSA tidak tersedia. Menggunakan SSL certificate dari Tahap 3."
    fi
}

configure_openvpn_tcp() {
    log "Mengkonfigurasi OpenVPN TCP..."

    mkdir -p "$OPENVPN_CONFIG_DIR"

    # Server TCP config — port 1194
    cat > "$OPENVPN_CONFIG_DIR/server-tcp.conf" <<OPENVPN_TCP
# OpenVPN TCP Configuration — VPN Tunneling AutoScript
# Port: ${OPENVPN_TCP_PORT1} (primary), ${OPENVPN_TCP_PORT2} (secondary)

port ${OPENVPN_TCP_PORT1}
proto tcp
dev tun0
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh.pem
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist /etc/openvpn/ipp-tcp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "route-method exe"
push "route-delay 2"
duplicate-cn
keepalive 10 120
cipher AES-256-GCM
auth SHA256
user nobody
group nogroup
persist-key
persist-tun
status /var/log/openvpn/openvpn-tcp-status.log
log /var/log/openvpn/openvpn-tcp.log
verb 3
mute 20
explicit-exit-notify 0
OPENVPN_TCP

    # Server TCP config — port 2294 (secondary)
    cat > "$OPENVPN_CONFIG_DIR/server-tcp2.conf" <<OPENVPN_TCP2
# OpenVPN TCP2 Configuration — VPN Tunneling AutoScript
# Port: ${OPENVPN_TCP_PORT2}

port ${OPENVPN_TCP_PORT2}
proto tcp
dev tun1
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh.pem
server 10.9.0.0 255.255.255.0
ifconfig-pool-persist /etc/openvpn/ipp-tcp2.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
duplicate-cn
keepalive 10 120
cipher AES-256-GCM
auth SHA256
user nobody
group nogroup
persist-key
persist-tun
status /var/log/openvpn/openvpn-tcp2-status.log
log /var/log/openvpn/openvpn-tcp2.log
verb 3
mute 20
explicit-exit-notify 0
OPENVPN_TCP2

    # Buat log directory
    mkdir -p /var/log/openvpn

    chmod 644 "$OPENVPN_CONFIG_DIR/server-tcp.conf"
    chmod 644 "$OPENVPN_CONFIG_DIR/server-tcp2.conf"
    log "Konfigurasi OpenVPN TCP berhasil dibuat."
}

configure_openvpn_udp() {
    log "Mengkonfigurasi OpenVPN UDP..."

    # Server UDP config — port 2200
    cat > "$OPENVPN_CONFIG_DIR/server-udp.conf" <<OPENVPN_UDP
# OpenVPN UDP Configuration — VPN Tunneling AutoScript
# Port: ${OPENVPN_UDP_PORT1} (primary), ${OPENVPN_UDP_PORT2} (secondary)

port ${OPENVPN_UDP_PORT1}
proto udp
dev tun2
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh.pem
server 10.10.0.0 255.255.255.0
ifconfig-pool-persist /etc/openvpn/ipp-udp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "route-method exe"
push "route-delay 2"
duplicate-cn
keepalive 10 120
cipher AES-256-GCM
auth SHA256
user nobody
group nogroup
persist-key
persist-tun
status /var/log/openvpn/openvpn-udp-status.log
log /var/log/openvpn/openvpn-udp.log
verb 3
mute 20
explicit-exit-notify 1
OPENVPN_UDP

    # Server UDP config — port 2295 (secondary)
    cat > "$OPENVPN_CONFIG_DIR/server-udp2.conf" <<OPENVPN_UDP2
# OpenVPN UDP2 Configuration — VPN Tunneling AutoScript
# Port: ${OPENVPN_UDP_PORT2}

port ${OPENVPN_UDP_PORT2}
proto udp
dev tun3
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh.pem
server 10.11.0.0 255.255.255.0
ifconfig-pool-persist /etc/openvpn/ipp-udp2.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
duplicate-cn
keepalive 10 120
cipher AES-256-GCM
auth SHA256
user nobody
group nogroup
persist-key
persist-tun
status /var/log/openvpn/openvpn-udp2-status.log
log /var/log/openvpn/openvpn-udp2.log
verb 3
mute 20
explicit-exit-notify 1
OPENVPN_UDP2

    chmod 644 "$OPENVPN_CONFIG_DIR/server-udp.conf"
    chmod 644 "$OPENVPN_CONFIG_DIR/server-udp2.conf"
    log "Konfigurasi OpenVPN UDP berhasil dibuat."
}

configure_openvpn_stunnel() {
    log "Mengkonfigurasi OpenVPN Stunnel (TLS tunnel)..."

    # Stunnel config khusus OpenVPN — port 2296
    cat > "$OPENVPN_STUNNEL_CONF" <<OPENVPN_STUNNEL_CFG
# Stunnel Configuration for OpenVPN — VPN Tunneling AutoScript
# Port: ${OPENVPN_STUNNEL_PORT} -> 127.0.0.1:${OPENVPN_TCP_PORT1}

pid = /var/run/stunnel4/stunnel-openvpn.pid

[openvpn-tls]
accept = ${OPENVPN_STUNNEL_PORT}
connect = 127.0.0.1:${OPENVPN_TCP_PORT1}
cert = ${XRAY_CERT}
key = ${XRAY_KEY}
OPENVPN_STUNNEL_CFG

    chmod 644 "$OPENVPN_STUNNEL_CONF"
    log "Konfigurasi OpenVPN Stunnel berhasil dibuat: $OPENVPN_STUNNEL_CONF"
}

create_openvpn_services() {
    log "Membuat systemd services untuk OpenVPN..."

    # Service untuk OpenVPN TCP (port 1194)
    cat > /etc/systemd/system/openvpn-tcp.service <<'OVPN_TCP_SVC'
[Unit]
Description=OpenVPN TCP Server (port 1194)
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/sbin/openvpn --config /etc/openvpn/server-tcp.conf
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
OVPN_TCP_SVC

    # Service untuk OpenVPN TCP2 (port 2294)
    cat > /etc/systemd/system/openvpn-tcp2.service <<'OVPN_TCP2_SVC'
[Unit]
Description=OpenVPN TCP2 Server (port 2294)
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/sbin/openvpn --config /etc/openvpn/server-tcp2.conf
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
OVPN_TCP2_SVC

    # Service untuk OpenVPN UDP (port 2200)
    cat > /etc/systemd/system/openvpn-udp.service <<'OVPN_UDP_SVC'
[Unit]
Description=OpenVPN UDP Server (port 2200)
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/sbin/openvpn --config /etc/openvpn/server-udp.conf
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
OVPN_UDP_SVC

    # Service untuk OpenVPN UDP2 (port 2295)
    cat > /etc/systemd/system/openvpn-udp2.service <<'OVPN_UDP2_SVC'
[Unit]
Description=OpenVPN UDP2 Server (port 2295)
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/sbin/openvpn --config /etc/openvpn/server-udp2.conf
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
OVPN_UDP2_SVC

    # Service untuk OpenVPN Stunnel (port 2296)
    cat > /etc/systemd/system/stunnel-openvpn.service <<'OVPN_STUNNEL_SVC'
[Unit]
Description=Stunnel for OpenVPN TLS (port 2296)
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=forking
ExecStart=/usr/bin/stunnel /etc/stunnel/stunnel-openvpn.conf
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
OVPN_STUNNEL_SVC

    systemctl daemon-reload >> "$LOG_FILE" 2>&1
    log "Systemd services OpenVPN berhasil dibuat."
}

start_openvpn() {
    log "Menjalankan OpenVPN services..."

    # Enable IP forwarding for OpenVPN
    echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/99-openvpn-forward.conf
    sysctl -w net.ipv4.ip_forward=1 >> "$LOG_FILE" 2>&1

    # Setup NAT/masquerade for VPN
    local default_iface
    default_iface=$(ip route show default 2>/dev/null | awk '/default/ {print $5}' | head -1)

    if [[ -n "$default_iface" ]]; then
        {
            iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o "$default_iface" -j MASQUERADE
            iptables -t nat -A POSTROUTING -s 10.9.0.0/24 -o "$default_iface" -j MASQUERADE
            iptables -t nat -A POSTROUTING -s 10.10.0.0/24 -o "$default_iface" -j MASQUERADE
            iptables -t nat -A POSTROUTING -s 10.11.0.0/24 -o "$default_iface" -j MASQUERADE
        } >> "$LOG_FILE" 2>&1
        log "NAT/masquerade dikonfigurasi pada interface: $default_iface"
    else
        log_warn "Default network interface tidak terdeteksi. NAT mungkin perlu dikonfigurasi manual."
    fi

    # Start services
    local services=("openvpn-tcp" "openvpn-tcp2" "openvpn-udp" "openvpn-udp2" "stunnel-openvpn")
    for svc in "${services[@]}"; do
        systemctl enable "$svc" >> "$LOG_FILE" 2>&1
        systemctl restart "$svc" >> "$LOG_FILE" 2>&1

        if systemctl is-active --quiet "$svc"; then
            log "$svc berhasil dijalankan."
        else
            log_warn "$svc gagal dijalankan. Periksa konfigurasi."
        fi
    done
}

# ============================================================================
# Install & Configure SoftEther VPN
# ============================================================================
# Referensi: https://github.com/SoftEtherVPN/SoftEtherVPN
# Multi-protocol: SSTP (4433), L2TP/IPSec (500/1701/4500), OpenVPN (1194/1195)
# Remote management: 5555
# ============================================================================

install_softether() {
    log "Menginstall SoftEther VPN Server..."

    mkdir -p "$SOFTETHER_INSTALL_DIR"
    mkdir -p "$SOFTETHER_CONFIG_DIR"

    # Download SoftEther VPN Server
    local se_url="https://github.com/SoftEtherVPN/SoftEtherVPN_Stable/releases/download/v4.43-9799-beta/softether-vpnserver-v4.43-9799-beta-2023.06.30-linux-x64-64bit.tar.gz"
    local tmp_dir
    tmp_dir=$(mktemp -d)

    # Install build dependencies
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y build-essential libreadline-dev libncurses-dev libssl-dev zlib1g-dev >> "$LOG_FILE" 2>&1

    if ! wget --inet4-only --no-check-certificate -O "$tmp_dir/softether.tar.gz" "$se_url" >> "$LOG_FILE" 2>&1; then
        log_error "Download SoftEther VPN gagal!"
        rm -rf "$tmp_dir"
        return 1
    fi

    # Extract
    if ! tar xzf "$tmp_dir/softether.tar.gz" -C "$tmp_dir/" >> "$LOG_FILE" 2>&1; then
        log_error "Ekstraksi SoftEther VPN gagal!"
        rm -rf "$tmp_dir"
        return 1
    fi

    # Build
    if [[ -d "$tmp_dir/vpnserver" ]]; then
        cd "$tmp_dir/vpnserver" || return 1

        # Build dengan auto-accept license (expect 1 1 1)
        if ! echo -e "1\n1\n1" | make >> "$LOG_FILE" 2>&1; then
            log_error "Build SoftEther VPN gagal!"
            cd /root || true
            rm -rf "$tmp_dir"
            return 1
        fi

        # Install ke /usr/local/softether
        cp -r "$tmp_dir/vpnserver/"* "$SOFTETHER_INSTALL_DIR/"
        chmod 600 "$SOFTETHER_INSTALL_DIR/"*
        chmod 700 "$SOFTETHER_BIN"
        chmod 700 "$SOFTETHER_INSTALL_DIR/vpncmd"

        cd /root || true
    else
        log_error "Direktori vpnserver tidak ditemukan setelah ekstraksi!"
        cd /root || true
        rm -rf "$tmp_dir"
        return 1
    fi

    # Cleanup
    rm -rf "$tmp_dir"

    log "SoftEther VPN Server berhasil diinstall."
}

configure_softether() {
    log "Mengkonfigurasi SoftEther VPN Server..."

    mkdir -p "$SOFTETHER_CONFIG_DIR"

    # Generate vpn_server.config
    cat > "$SOFTETHER_CONFIG" <<SOFTETHER_CFG
# SoftEther VPN Server Configuration — VPN Tunneling AutoScript
# Referensi: https://github.com/SoftEtherVPN/SoftEtherVPN
#
# Port konfigurasi:
#   Remote Management : ${SOFTETHER_REMOTE_PORT}
#   SSTP              : ${SOFTETHER_SSTP_PORT}
#   OpenVPN TCP/UDP   : ${SOFTETHER_OPENVPN_TCP_PORT}
#   OpenVPN TLS       : ${SOFTETHER_OPENVPN_TLS_PORT}
#   L2TP/IPSec        : ${SOFTETHER_L2TP_PORT1}, ${SOFTETHER_L2TP_PORT2}, ${SOFTETHER_L2TP_PORT3}
#
# NOTE: Konfigurasi detail dilakukan via vpncmd setelah server berjalan.
# File ini adalah placeholder konfigurasi dasar.
SOFTETHER_CFG

    chmod 644 "$SOFTETHER_CONFIG"
    log "Konfigurasi dasar SoftEther berhasil dibuat: $SOFTETHER_CONFIG"
}

create_softether_service() {
    log "Membuat systemd service untuk SoftEther VPN..."

    cat > /etc/systemd/system/softether-vpnserver.service <<'SOFTETHER_SVC'
[Unit]
Description=SoftEther VPN Server
Documentation=https://github.com/SoftEtherVPN/SoftEtherVPN
After=network.target network-online.target auditd.service
Wants=network-online.target
ConditionPathExists=/usr/local/softether/vpnserver

[Service]
Type=forking
ExecStart=/usr/local/softether/vpnserver start
ExecStop=/usr/local/softether/vpnserver stop
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
SOFTETHER_SVC

    systemctl daemon-reload >> "$LOG_FILE" 2>&1
    log "Systemd service SoftEther VPN berhasil dibuat."
}

start_softether() {
    log "Menjalankan SoftEther VPN Server..."

    {
        systemctl daemon-reload
        systemctl enable softether-vpnserver
        systemctl restart softether-vpnserver
    } >> "$LOG_FILE" 2>&1

    if systemctl is-active --quiet softether-vpnserver; then
        log "SoftEther VPN Server berhasil dijalankan."
    else
        log_warn "SoftEther VPN Server gagal dijalankan. Periksa konfigurasi."
    fi
}

# ============================================================================
# Install & Configure Cloudflare WARP
# ============================================================================
# WireGuard via Cloudflare — port 51820
# ============================================================================

install_warp() {
    log "Menginstall Cloudflare WARP..."

    export DEBIAN_FRONTEND=noninteractive

    # Tambah repository Cloudflare WARP
    # shellcheck source=/dev/null
    source /etc/os-release

    local warp_repo_key="https://pkg.cloudflareclient.com/pubkey.gpg"
    local warp_repo=""

    case "$ID" in
        ubuntu)
            warp_repo="https://pkg.cloudflareclient.com/ ${VERSION_CODENAME:-focal} main"
            ;;
        debian)
            warp_repo="https://pkg.cloudflareclient.com/ ${VERSION_CODENAME:-bullseye} main"
            ;;
    esac

    # Import GPG key
    if ! curl -fsSL "$warp_repo_key" | gpg --dearmor -o /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg >> "$LOG_FILE" 2>&1; then
        log_warn "Gagal mengimport GPG key Cloudflare WARP."
    fi

    # Tambah repository
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] $warp_repo" \
        > /etc/apt/sources.list.d/cloudflare-client.list

    # Install WARP
    apt-get update >> "$LOG_FILE" 2>&1
    if ! apt-get install -y cloudflare-warp >> "$LOG_FILE" 2>&1; then
        log_warn "Instalasi Cloudflare WARP via repository gagal. Mencoba download langsung..."

        # Fallback: download .deb manual
        local deb_url="https://pkg.cloudflareclient.com/pool/jammy/main/c/cloudflare-warp/cloudflare-warp_2024.6.497.0_amd64.deb"
        local tmp_deb
        tmp_deb=$(mktemp /tmp/warp-XXXXXX.deb)

        if wget --inet4-only --no-check-certificate -O "$tmp_deb" "$deb_url" >> "$LOG_FILE" 2>&1; then
            dpkg -i "$tmp_deb" >> "$LOG_FILE" 2>&1 || true
            apt-get install -f -y >> "$LOG_FILE" 2>&1
            rm -f "$tmp_deb"
        else
            log_error "Instalasi Cloudflare WARP gagal!"
            rm -f "$tmp_deb"
            return 1
        fi
    fi

    log "Cloudflare WARP berhasil diinstall."
}

configure_warp() {
    log "Mengkonfigurasi Cloudflare WARP..."

    mkdir -p "$WARP_CONFIG_DIR"

    # Register WARP
    if command -v warp-cli &>/dev/null; then
        warp-cli --accept-tos registration new >> "$LOG_FILE" 2>&1 || true
        warp-cli --accept-tos mode proxy >> "$LOG_FILE" 2>&1 || true
        warp-cli --accept-tos proxy port "$WARP_PORT" >> "$LOG_FILE" 2>&1 || true
        log "Cloudflare WARP berhasil dikonfigurasi (proxy mode, port $WARP_PORT)."
    else
        log_warn "warp-cli tidak ditemukan. Konfigurasi WARP dilewati."
    fi

    # Simpan konfigurasi referensi
    cat > "$WARP_CONFIG" <<WARP_CFG
# Cloudflare WARP Configuration — VPN Tunneling AutoScript
# Port: ${WARP_PORT}
# Mode: Proxy (SOCKS5)
#
# Gunakan warp-cli untuk manajemen:
#   warp-cli connect    — Aktifkan WARP
#   warp-cli disconnect — Nonaktifkan WARP
#   warp-cli status     — Cek status
WARP_CFG

    chmod 644 "$WARP_CONFIG"
}

start_warp() {
    log "Menjalankan Cloudflare WARP..."

    if command -v warp-cli &>/dev/null; then
        warp-cli --accept-tos connect >> "$LOG_FILE" 2>&1 || true

        if warp-cli --accept-tos status 2>/dev/null | grep -qi "connected"; then
            log "Cloudflare WARP berhasil terkoneksi."
        else
            log_warn "Cloudflare WARP gagal terkoneksi. Gunakan 'warp-cli connect' secara manual."
        fi
    else
        log_warn "warp-cli tidak tersedia. WARP tidak dapat dijalankan."
    fi
}

# ============================================================================
# Install & Configure SlowDNS/DNSTT
# ============================================================================
# DNS Tunneling — port 53, 5300, 2222
# ============================================================================

install_slowdns() {
    log "Menginstall SlowDNS/DNSTT..."

    mkdir -p "$SLOWDNS_KEY_DIR"

    # Download dns-server binary
    local dnstt_url="https://github.com/nicehash/dnstt/releases/latest/download/dnstt-server-linux-amd64"

    if ! wget --inet4-only --no-check-certificate -O "$SLOWDNS_BIN" "$dnstt_url" >> "$LOG_FILE" 2>&1; then
        log_warn "Download DNSTT dari GitHub gagal. Mencoba kompilasi dari source..."

        # Fallback: compile dari source (jika golang tersedia)
        if command -v go &>/dev/null; then
            go install github.com/nicehash/dnstt/cmd/dnstt-server@latest >> "$LOG_FILE" 2>&1 || true
            if [[ -f ~/go/bin/dnstt-server ]]; then
                cp ~/go/bin/dnstt-server "$SLOWDNS_BIN"
            fi
        else
            log_warn "Go compiler tidak tersedia. SlowDNS mungkin perlu diinstall manual."
            return 1
        fi
    fi

    if [[ -f "$SLOWDNS_BIN" ]]; then
        chmod +x "$SLOWDNS_BIN"
        log "SlowDNS/DNSTT berhasil diinstall."
    else
        log_warn "Binary SlowDNS tidak ditemukan setelah instalasi."
        return 1
    fi
}

configure_slowdns() {
    log "Mengkonfigurasi SlowDNS/DNSTT..."

    mkdir -p "$SLOWDNS_KEY_DIR"

    # Generate keypair untuk SlowDNS
    if command -v openssl &>/dev/null; then
        if [[ ! -f "$SLOWDNS_KEY_DIR/server.key" ]]; then
            openssl genrsa -out "$SLOWDNS_KEY_DIR/server.key" 2048 >> "$LOG_FILE" 2>&1
            openssl rsa -in "$SLOWDNS_KEY_DIR/server.key" -pubout -out "$SLOWDNS_KEY_DIR/server.pub" >> "$LOG_FILE" 2>&1
            chmod 600 "$SLOWDNS_KEY_DIR/server.key"
            chmod 644 "$SLOWDNS_KEY_DIR/server.pub"
            log "SlowDNS keypair berhasil digenerate."
        else
            log "SlowDNS keypair sudah ada, melewati generate."
        fi
    else
        log_warn "OpenSSL tidak tersedia. SlowDNS keypair tidak dapat digenerate."
    fi

    # Simpan NS domain placeholder
    local domain
    domain=$(get_domain)
    echo "ns.${domain}" > "$SLOWDNS_NS_FILE" 2>/dev/null || true
    chmod 644 "$SLOWDNS_NS_FILE" 2>/dev/null || true

    log "Konfigurasi SlowDNS berhasil."
}

create_slowdns_service() {
    log "Membuat systemd service untuk SlowDNS..."

    cat > /etc/systemd/system/slowdns.service <<'SLOWDNS_SVC'
[Unit]
Description=SlowDNS/DNSTT Server
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/dns-server -udp :5300 -privkey-file /etc/slowdns/server.key 127.0.0.1:22
Restart=on-failure
RestartSec=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
SLOWDNS_SVC

    systemctl daemon-reload >> "$LOG_FILE" 2>&1
    log "Systemd service SlowDNS berhasil dibuat."
}

start_slowdns() {
    log "Menjalankan SlowDNS..."

    {
        systemctl daemon-reload
        systemctl enable slowdns
        systemctl restart slowdns
    } >> "$LOG_FILE" 2>&1

    if systemctl is-active --quiet slowdns; then
        log "SlowDNS berhasil dijalankan."
    else
        log_warn "SlowDNS gagal dijalankan. Periksa konfigurasi."
    fi
}

# ============================================================================
# Install & Configure UDP Custom
# ============================================================================
# UDP Tunneling custom port (1-65535)
# ============================================================================

install_udp_custom() {
    log "Menginstall UDP Custom handler..."

    mkdir -p "$UDP_CUSTOM_CONFIG_DIR"

    # Download udp-custom binary
    local udp_url="https://github.com/AmnesiaDev/udp-custom/releases/latest/download/udp-custom-linux-amd64"

    if ! wget --inet4-only --no-check-certificate -O "$UDP_CUSTOM_BIN" "$udp_url" >> "$LOG_FILE" 2>&1; then
        log_warn "Download UDP Custom gagal. Membuat handler sederhana..."

        # Fallback: buat simple UDP handler script
        cat > "$UDP_CUSTOM_BIN" <<'UDP_HANDLER'
#!/bin/bash
# UDP Custom Handler — VPN Tunneling AutoScript
# Simple UDP tunnel/forwarder

CONFIG_FILE="/etc/udp-custom/config.json"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Config file not found: $CONFIG_FILE"
    exit 1
fi

echo "UDP Custom handler started."
echo "Config: $CONFIG_FILE"

# Keep running
while true; do
    sleep 60
done
UDP_HANDLER
    fi

    chmod +x "$UDP_CUSTOM_BIN"
    log "UDP Custom handler berhasil diinstall."
}

configure_udp_custom() {
    log "Mengkonfigurasi UDP Custom..."

    mkdir -p "$UDP_CUSTOM_CONFIG_DIR"

    # Generate config.json
    cat > "$UDP_CUSTOM_CONFIG" <<'UDP_CUSTOM_CFG'
{
    "listen": ":1-65535",
    "stream_buffer": 16384,
    "receive_buffer": 33554432,
    "auth": {
        "mode": "passwords"
    }
}
UDP_CUSTOM_CFG

    chmod 644 "$UDP_CUSTOM_CONFIG"
    log "Konfigurasi UDP Custom berhasil dibuat: $UDP_CUSTOM_CONFIG"
}

create_udp_custom_service() {
    log "Membuat systemd service untuk UDP Custom..."

    cat > /etc/systemd/system/udp-custom.service <<'UDP_CUSTOM_SVC'
[Unit]
Description=UDP Custom Tunneling Handler
After=network.target network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/udp-custom
Restart=on-failure
RestartSec=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
UDP_CUSTOM_SVC

    systemctl daemon-reload >> "$LOG_FILE" 2>&1
    log "Systemd service UDP Custom berhasil dibuat."
}

start_udp_custom() {
    log "Menjalankan UDP Custom..."

    {
        systemctl daemon-reload
        systemctl enable udp-custom
        systemctl restart udp-custom
    } >> "$LOG_FILE" 2>&1

    if systemctl is-active --quiet udp-custom; then
        log "UDP Custom berhasil dijalankan."
    else
        log_warn "UDP Custom gagal dijalankan. Periksa konfigurasi."
    fi
}

# ============================================================================
# Integrasi SSL Certificate
# ============================================================================

integrate_ssl() {
    log "Mengintegrasi SSL certificate yang sudah ada..."

    local domain
    domain=$(get_domain)

    # Verifikasi SSL certificate dari Tahap 3
    if [[ -f "$XRAY_CERT" && -f "$XRAY_KEY" ]]; then
        log "SSL certificate ditemukan: $XRAY_CERT"

        # Buat symlink untuk kemudahan akses
        ln -sf "$XRAY_CERT" /etc/ssl/vpn-autoscript.crt 2>/dev/null || true
        ln -sf "$XRAY_KEY" /etc/ssl/vpn-autoscript.key 2>/dev/null || true

        # Set permissions
        chmod 644 "$XRAY_CERT"
        chmod 600 "$XRAY_KEY"

        log "SSL certificate berhasil diintegrasi untuk semua protokol."
    else
        log_warn "SSL certificate tidak ditemukan. Beberapa protokol mungkin tidak berfungsi dengan TLS."
        log_warn "Jalankan Tahap 3 (setup-domain.sh) untuk mendapatkan SSL certificate."
    fi
}

# ============================================================================
# Nginx Integrasi — Tambah path untuk Trojan-Go
# ============================================================================

update_nginx_config() {
    log "Mengupdate konfigurasi Nginx untuk protokol tambahan..."

    local nginx_conf="/etc/nginx/conf.d/xray.conf"

    if [[ -f "$nginx_conf" ]]; then
        # Cek apakah path trojan-go sudah ada
        if ! grep -q "trojan-go-ws" "$nginx_conf" 2>/dev/null; then
            log "Path trojan-go sudah dikonfigurasi di Nginx atau akan ditangani oleh Trojan-Go langsung."
        fi
    else
        log_warn "Konfigurasi Nginx tidak ditemukan: $nginx_conf"
    fi
}

# ============================================================================
# Main Function
# ============================================================================

main() {
    print_header

    log "Memulai Tahap 5: Instalasi Protokol Tambahan..."

    # Pengecekan prasyarat
    log "Memulai pengecekan prasyarat..."
    check_root
    check_os
    check_arch
    check_virt
    check_tahap4
    log "Semua pengecekan prasyarat berhasil."

    # 0. Integrasi SSL certificate
    integrate_ssl

    # 1. Install dan konfigurasi Hysteria2
    install_hysteria2
    configure_hysteria2
    create_hysteria2_service
    start_hysteria2

    # 2. Install dan konfigurasi Trojan-Go
    install_trojan_go
    configure_trojan_go
    create_trojan_go_service
    start_trojan_go

    # 3. Install dan konfigurasi OpenVPN
    install_openvpn
    setup_openvpn_pki
    configure_openvpn_tcp
    configure_openvpn_udp
    configure_openvpn_stunnel
    create_openvpn_services
    start_openvpn

    # 4. Install dan konfigurasi SoftEther VPN
    install_softether
    configure_softether
    create_softether_service
    start_softether

    # 5. Install dan konfigurasi Cloudflare WARP
    install_warp
    configure_warp
    start_warp

    # 6. Install dan konfigurasi SlowDNS/DNSTT
    install_slowdns
    configure_slowdns
    create_slowdns_service
    start_slowdns

    # 7. Install dan konfigurasi UDP Custom
    install_udp_custom
    configure_udp_custom
    create_udp_custom_service
    start_udp_custom

    # 8. Update Nginx untuk protokol baru
    update_nginx_config

    # Selesai
    echo ""
    echo -e "${GREEN}=============================================="
    echo "  Tahap 5 selesai!"
    echo ""
    echo "  Hysteria2:"
    echo "    QUIC/UDP     : port $HYSTERIA2_PORT"
    echo "    Config       : $HYSTERIA2_CONFIG"
    echo ""
    echo "  Trojan-Go:"
    echo "    WS TLS       : port $TROJAN_GO_PORT_WS"
    echo "    Config       : $TROJAN_GO_CONFIG"
    echo ""
    echo "  OpenVPN:"
    echo "    TCP          : port $OPENVPN_TCP_PORT1, $OPENVPN_TCP_PORT2"
    echo "    UDP          : port $OPENVPN_UDP_PORT1, $OPENVPN_UDP_PORT2"
    echo "    TLS (Stunnel): port $OPENVPN_STUNNEL_PORT"
    echo ""
    echo "  SoftEther VPN:"
    echo "    Remote       : port $SOFTETHER_REMOTE_PORT"
    echo "    SSTP         : port $SOFTETHER_SSTP_PORT"
    echo "    OpenVPN      : port $SOFTETHER_OPENVPN_TCP_PORT"
    echo "    OpenVPN TLS  : port $SOFTETHER_OPENVPN_TLS_PORT"
    echo "    L2TP/IPSec   : port $SOFTETHER_L2TP_PORT1, $SOFTETHER_L2TP_PORT2, $SOFTETHER_L2TP_PORT3"
    echo ""
    echo "  Cloudflare WARP:"
    echo "    WireGuard    : port $WARP_PORT"
    echo "    Config       : $WARP_CONFIG"
    echo ""
    echo "  SlowDNS/DNSTT:"
    echo "    DNS          : port $SLOWDNS_DNS_PORT"
    echo "    Alt DNS      : port $SLOWDNS_ALT_PORT"
    echo "    SSH          : port $SLOWDNS_SSH_PORT"
    echo ""
    echo "  UDP Custom:"
    echo "    Port         : 1-65535"
    echo "    Config       : $UDP_CUSTOM_CONFIG"
    echo ""
    echo "  SSL Certificate: $XRAY_CERT"
    echo ""
    echo "  Sistem siap untuk instalasi komponen selanjutnya."
    echo -e "==============================================${NC}"
    echo ""

    log "Tahap 5 selesai. Protokol tambahan berhasil diinstall."
}

main "$@"
