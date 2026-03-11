#!/bin/bash
# ============================================================================
# VPN Tunneling AutoScript Installer — Tahap 4: SSH Tunneling, HAProxy & Services
# ============================================================================
# Script ini melakukan instalasi dan konfigurasi SSH tunneling (Dropbear,
# Stunnel, SSH WebSocket), HAProxy load balancer, Squid proxy, BadVPN/UDPGW,
# Fail2ban, OHP (Open HTTP Puncher), banner, dan cronjob.
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
#   - Tahap 1-3 sudah dijalankan (setup.sh, install.sh, setup-domain.sh)
#
# Penggunaan:
#   chmod +x setup-ssh.sh
#   ./setup-ssh.sh
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

# Paths penting dari Tahap 3
XRAY_CERT="/etc/xray/xray.crt"
XRAY_KEY="/etc/xray/xray.key"
DOMAIN_FILE="/etc/xray/domain"

# Port konfigurasi SSH (sesuai README)
OPENSSH_PORT=22
DROPBEAR_PORTS="80 143 443"
DROPBEAR_STUNNEL_PORT=446
DROPBEAR_STUNNEL_WS_PORT=445
SSHWS_HTTP_PORT=8880

# Port konfigurasi HAProxy (sesuai README)
HAPROXY_HTTP_PORT=80
HAPROXY_HTTPS_PORT=443

# Port konfigurasi Squid (sesuai README)
SQUID_PORT1=3128
SQUID_PORT2=8080

# Port konfigurasi OHP (sesuai README)
OHP_SSH_PORT=2083
OHP_DROPBEAR_PORT=2084
OHP_OPENVPN_PORT=2087

# Port konfigurasi BadVPN/UDPGW (sesuai README)
BADVPN_PORTS="7100 7200 7300 7400 7500 7600 7700 7800 7900"

# File konfigurasi
STUNNEL_CONF="/etc/stunnel/stunnel.conf"
HAPROXY_CONF="/etc/haproxy/haproxy.cfg"
SQUID_CONF="/etc/squid/squid.conf"
FAIL2BAN_CONF="/etc/fail2ban/jail.local"
BANNER_FILE="/etc/banner"
SSHWS_BIN="/usr/local/bin/sshws"
BADVPN_BIN="/usr/local/bin/badvpn-udpgw"
OHP_BIN="/usr/local/bin/ohp"

# Cronjob configs
CRON_CLEAR_LOG="/etc/cron.d/auto-clear-log"
CRON_DELETE_EXPIRED="/etc/cron.d/auto-delete-expired"

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
    echo "  Tahap 4: SSH Tunneling, HAProxy & Services"
    echo "=============================================="
    echo -e "${NC}"
}

# ============================================================================
# Pengecekan Prasyarat
# ============================================================================

check_root() {
    if [[ "$(id -u)" -ne 0 ]]; then
        log_error "Script ini harus dijalankan sebagai root!"
        echo -e "${RED}Gunakan: sudo ./setup-ssh.sh${NC}"
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

check_tahap3() {
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

    if [[ "$missing" == true ]]; then
        log_error "Pastikan Tahap 3 (setup-domain.sh) sudah dijalankan."
        exit 1
    fi

    log "Pengecekan Tahap 3: OK"
}

# ============================================================================
# Install & Configure Dropbear SSH
# ============================================================================

install_dropbear() {
    log "Menginstall Dropbear SSH..."

    export DEBIAN_FRONTEND=noninteractive

    if ! apt-get install -y dropbear >> "$LOG_FILE" 2>&1; then
        log_error "Instalasi Dropbear gagal!"
        exit 1
    fi

    log "Dropbear berhasil diinstall."
}

configure_dropbear() {
    log "Mengkonfigurasi Dropbear SSH..."

    # Konfigurasi Dropbear — multi-port
    local dropbear_default="/etc/default/dropbear"

    if [[ -f "$dropbear_default" ]]; then
        # Set Dropbear config
        cat > "$dropbear_default" <<'DROPBEAR_CFG'
# Dropbear SSH Configuration — VPN Tunneling AutoScript
NO_START=0
DROPBEAR_PORT=80 143 443
DROPBEAR_EXTRA_ARGS="-p 80 -p 143 -p 443"
DROPBEAR_BANNER="/etc/banner"
DROPBEAR_RECEIVE_WINDOW=65536
DROPBEAR_RSAKEY="/etc/dropbear/dropbear_rsa_host_key"
DROPBEAR_DSSKEY="/etc/dropbear/dropbear_dss_host_key"
DROPBEAR_ECDSAKEY="/etc/dropbear/dropbear_ecdsa_host_key"
DROPBEAR_CFG
        log "Dropbear konfigurasi ditulis ke $dropbear_default"
    fi

    # Buat direktori dropbear jika belum ada
    mkdir -p /etc/dropbear

    # Generate host keys jika belum ada
    if [[ ! -f /etc/dropbear/dropbear_rsa_host_key ]]; then
        if command -v dropbearkey &>/dev/null; then
            dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key >> "$LOG_FILE" 2>&1
            log "Dropbear RSA host key generated."
        fi
    fi

    if [[ ! -f /etc/dropbear/dropbear_ecdsa_host_key ]]; then
        if command -v dropbearkey &>/dev/null; then
            dropbearkey -t ecdsa -f /etc/dropbear/dropbear_ecdsa_host_key >> "$LOG_FILE" 2>&1
            log "Dropbear ECDSA host key generated."
        fi
    fi

    log "Dropbear SSH dikonfigurasi pada port: $DROPBEAR_PORTS"
}

start_dropbear() {
    log "Memulai Dropbear SSH..."

    systemctl enable dropbear >> "$LOG_FILE" 2>&1
    systemctl restart dropbear >> "$LOG_FILE" 2>&1

    if systemctl is-active --quiet dropbear; then
        log "Dropbear berhasil dijalankan."
    else
        log_warn "Dropbear gagal dijalankan. Periksa konfigurasi."
    fi
}

# ============================================================================
# Install & Configure Stunnel
# ============================================================================

install_stunnel() {
    log "Menginstall Stunnel..."

    export DEBIAN_FRONTEND=noninteractive

    if ! apt-get install -y stunnel4 >> "$LOG_FILE" 2>&1; then
        log_error "Instalasi Stunnel gagal!"
        exit 1
    fi

    log "Stunnel berhasil diinstall."
}

configure_stunnel() {
    log "Mengkonfigurasi Stunnel SSL tunnel..."

    # Konfigurasi Stunnel
    cat > "$STUNNEL_CONF" <<STUNNEL_CFG
# ============================================================================
# Stunnel Configuration — VPN Tunneling AutoScript
# ============================================================================
# SSL/TLS tunnel untuk SSH dan WebSocket
#
# Port 446: Dropbear SSH via SSL (Dropbear Stunnel)
# Port 445: Dropbear WebSocket via SSL (Dropbear Stunnel WS)
# ============================================================================

pid = /var/run/stunnel4/stunnel.pid
cert = $XRAY_CERT
key = $XRAY_KEY
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[ssh]
accept = 446
connect = 127.0.0.1:143

[ssh-ws]
accept = 445
connect = 127.0.0.1:8880
STUNNEL_CFG

    log "Stunnel konfigurasi ditulis ke $STUNNEL_CONF"

    # Enable stunnel4
    local stunnel_default="/etc/default/stunnel4"
    if [[ -f "$stunnel_default" ]]; then
        sed -i 's/ENABLED=0/ENABLED=1/g' "$stunnel_default"
        log "Stunnel4 diaktifkan di $stunnel_default"
    fi

    # Buat direktori PID
    mkdir -p /var/run/stunnel4
    chown stunnel4:stunnel4 /var/run/stunnel4 2>/dev/null
}

start_stunnel() {
    log "Memulai Stunnel..."

    systemctl enable stunnel4 >> "$LOG_FILE" 2>&1
    systemctl restart stunnel4 >> "$LOG_FILE" 2>&1

    if systemctl is-active --quiet stunnel4; then
        log "Stunnel berhasil dijalankan."
    else
        log_warn "Stunnel gagal dijalankan. Periksa konfigurasi dan SSL certificate."
    fi
}

# ============================================================================
# SSH WebSocket Handler
# ============================================================================

create_sshws() {
    log "Membuat SSH WebSocket handler..."

    # SSH WebSocket Python handler
    cat > "$SSHWS_BIN" <<'SSHWS_SCRIPT'
#!/usr/bin/env python3
# ============================================================================
# SSH WebSocket Handler — VPN Tunneling AutoScript
# ============================================================================
# Menangani koneksi SSH over WebSocket
# Port: 8880 (HTTP), di-reverse proxy oleh Nginx/HAProxy
# ============================================================================

import socket
import threading
import select
import sys
import os

DEFAULT_HOST = '127.0.0.1:143'
BUFLEN = 4096

class WebSocketProxy(threading.Thread):
    """Thread untuk menangani koneksi WebSocket SSH."""

    def __init__(self, conn, addr):
        threading.Thread.__init__(self)
        self.daemon = True
        self.conn = conn
        self.addr = addr

    def run(self):
        try:
            # Terima HTTP request
            data = self.conn.recv(BUFLEN).decode('utf-8', errors='ignore')

            if not data:
                self.conn.close()
                return

            # Parse host dari header atau gunakan default
            host = DEFAULT_HOST
            for line in data.split('\r\n'):
                if line.lower().startswith('x-real-host:'):
                    host = line.split(':', 1)[1].strip()
                    break

            # Parse host:port
            if ':' in host:
                host_addr, host_port = host.rsplit(':', 1)
                host_port = int(host_port)
            else:
                host_addr = host
                host_port = 143

            # Kirim response 101 Switching Protocols
            response = (
                'HTTP/1.1 101 Switching Protocols\r\n'
                'Upgrade: websocket\r\n'
                'Connection: Upgrade\r\n\r\n'
            )
            self.conn.sendall(response.encode())

            # Connect ke target SSH
            target = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            target.connect((host_addr, host_port))

            # Relay data antara client dan target
            self._relay(self.conn, target)

        except Exception:
            pass
        finally:
            try:
                self.conn.close()
            except Exception:
                pass

    def _relay(self, client, target):
        """Relay data antara client dan target socket."""
        sockets = [client, target]
        while True:
            readable, _, errors = select.select(sockets, [], sockets, 30)

            if errors:
                break

            if not readable:
                break

            for sock in readable:
                try:
                    data = sock.recv(BUFLEN)
                    if not data:
                        return
                    if sock is client:
                        target.sendall(data)
                    else:
                        client.sendall(data)
                except Exception:
                    return


def main():
    """Main entry point."""
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8880

    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('0.0.0.0', port))
    server.listen(128)

    print(f'[SSH-WS] Listening on port {port}...')

    while True:
        try:
            conn, addr = server.accept()
            handler = WebSocketProxy(conn, addr)
            handler.start()
        except KeyboardInterrupt:
            break
        except Exception:
            pass

    server.close()


if __name__ == '__main__':
    main()
SSHWS_SCRIPT

    chmod 755 "$SSHWS_BIN"
    log "SSH WebSocket handler dibuat: $SSHWS_BIN"

    # Buat systemd service untuk SSH WebSocket
    cat > /etc/systemd/system/sshws.service <<SSHWS_SVC
[Unit]
Description=SSH WebSocket Handler
Documentation=https://github.com/kertasbaru/installer
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 $SSHWS_BIN $SSHWS_HTTP_PORT
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
SSHWS_SVC

    log "Systemd service sshws dibuat."

    {
        systemctl daemon-reload
        systemctl enable sshws
        systemctl restart sshws
    } >> "$LOG_FILE" 2>&1

    if systemctl is-active --quiet sshws; then
        log "SSH WebSocket berhasil dijalankan pada port $SSHWS_HTTP_PORT."
    else
        log_warn "SSH WebSocket gagal dijalankan. Periksa Python3."
    fi
}

# ============================================================================
# Install & Configure HAProxy
# ============================================================================

install_haproxy() {
    log "Menginstall HAProxy..."

    export DEBIAN_FRONTEND=noninteractive

    if ! apt-get install -y haproxy >> "$LOG_FILE" 2>&1; then
        log_error "Instalasi HAProxy gagal!"
        exit 1
    fi

    log "HAProxy berhasil diinstall."
}

configure_haproxy() {
    log "Mengkonfigurasi HAProxy load balancer..."

    cat > "$HAPROXY_CONF" <<HAPROXY_CFG
# ============================================================================
# HAProxy Configuration — VPN Tunneling AutoScript
# ============================================================================
# Load balancer untuk port 80 dan 443
# Routing berdasarkan SNI dan path
# ============================================================================

global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon
    tune.ssl.default-dh-param 2048
    maxconn 4096

defaults
    log     global
    mode    tcp
    option  dontlognull
    timeout connect 5s
    timeout client  300s
    timeout server  300s
    retries 3

# ============================================================================
# Frontend — Port 443 (HTTPS / TLS)
# ============================================================================

frontend ft_ssl
    bind *:443
    mode tcp
    option tcplog

    # Inspect TLS SNI
    tcp-request inspect-delay 3s
    tcp-request content accept if { req_ssl_hello_type 1 }

    # Default backend: Nginx HTTPS
    default_backend bk_nginx_https

# ============================================================================
# Frontend — Port 80 (HTTP)
# ============================================================================

frontend ft_http
    bind *:80
    mode tcp
    option tcplog

    # Default backend: Nginx HTTP
    default_backend bk_nginx_http

# ============================================================================
# Backend — Nginx HTTPS (port 663)
# ============================================================================

backend bk_nginx_https
    mode tcp
    server nginx_https 127.0.0.1:663 check

# ============================================================================
# Backend — Nginx HTTP (port 81)
# ============================================================================

backend bk_nginx_http
    mode tcp
    server nginx_http 127.0.0.1:81 check

# ============================================================================
# Backend — Dropbear SSH
# ============================================================================

backend bk_dropbear
    mode tcp
    server dropbear 127.0.0.1:143 check

# ============================================================================
# Backend — SSH WebSocket
# ============================================================================

backend bk_sshws
    mode tcp
    server sshws 127.0.0.1:8880 check
HAPROXY_CFG

    log "HAProxy konfigurasi ditulis ke $HAPROXY_CONF"
}

start_haproxy() {
    log "Memulai HAProxy..."

    systemctl enable haproxy >> "$LOG_FILE" 2>&1
    systemctl restart haproxy >> "$LOG_FILE" 2>&1

    if systemctl is-active --quiet haproxy; then
        log "HAProxy berhasil dijalankan."
    else
        log_warn "HAProxy gagal dijalankan. Periksa konfigurasi dan port conflicts."
    fi
}

# ============================================================================
# Install & Configure Squid HTTP Proxy
# ============================================================================

install_squid() {
    log "Menginstall Squid HTTP proxy..."

    export DEBIAN_FRONTEND=noninteractive

    if ! apt-get install -y squid >> "$LOG_FILE" 2>&1; then
        log_error "Instalasi Squid gagal!"
        exit 1
    fi

    log "Squid berhasil diinstall."
}

configure_squid() {
    log "Mengkonfigurasi Squid HTTP proxy..."

    cat > "$SQUID_CONF" <<SQUID_CFG
# ============================================================================
# Squid Configuration — VPN Tunneling AutoScript
# ============================================================================
# HTTP Proxy pada port 3128 dan 8080
# ============================================================================

# Port
http_port 3128
http_port 8080

# ACL
acl localhost src 127.0.0.1/32
acl to_localhost dst 127.0.0.0/8 0.0.0.0/32

acl localnet src 10.0.0.0/8
acl localnet src 172.16.0.0/12
acl localnet src 192.168.0.0/16

acl SSL_ports port 443
acl Safe_ports port 80
acl Safe_ports port 21
acl Safe_ports port 443
acl Safe_ports port 70
acl Safe_ports port 210
acl Safe_ports port 1025-65535
acl Safe_ports port 280
acl Safe_ports port 488
acl Safe_ports port 591
acl Safe_ports port 777
acl CONNECT method CONNECT

# Access rules
http_access allow localhost
http_access allow localnet
http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access deny all

# Logging
access_log none
cache_log /dev/null

# Performance
visible_hostname VPN-Tunneling
forwarded_for delete
via off
SQUID_CFG

    log "Squid konfigurasi ditulis ke $SQUID_CONF"
}

start_squid() {
    log "Memulai Squid..."

    systemctl enable squid >> "$LOG_FILE" 2>&1
    systemctl restart squid >> "$LOG_FILE" 2>&1

    if systemctl is-active --quiet squid; then
        log "Squid berhasil dijalankan pada port $SQUID_PORT1 dan $SQUID_PORT2."
    else
        log_warn "Squid gagal dijalankan. Periksa konfigurasi."
    fi
}

# ============================================================================
# Install & Configure BadVPN/UDPGW
# ============================================================================

install_badvpn() {
    log "Menginstall BadVPN/UDPGW..."

    # Download badvpn-udpgw binary
    local badvpn_url="https://github.com/ambrop72/badvpn/releases/download/1.999.130/badvpn-udpgw-linux-x86_64"

    if ! wget --inet4-only --no-check-certificate -O "$BADVPN_BIN" "$badvpn_url" >> "$LOG_FILE" 2>&1; then
        # Fallback: kompilasi dari source
        log_warn "Download BadVPN binary gagal. Mencoba kompilasi dari source..."
        if ! apt-get install -y cmake build-essential >> "$LOG_FILE" 2>&1; then
            log_warn "Gagal install build tools. Melewati BadVPN."
            return
        fi

        local badvpn_tmp="/tmp/badvpn-build"
        mkdir -p "$badvpn_tmp"

        if wget --inet4-only --no-check-certificate -O "$badvpn_tmp/badvpn.tar.gz" \
            "https://github.com/ambrop72/badvpn/archive/refs/tags/1.999.130.tar.gz" >> "$LOG_FILE" 2>&1; then
            cd "$badvpn_tmp" || return
            tar -xzf badvpn.tar.gz >> "$LOG_FILE" 2>&1
            cd badvpn-1.999.130 || return
            mkdir build && cd build || return
            cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1 >> "$LOG_FILE" 2>&1
            make >> "$LOG_FILE" 2>&1
            if [[ -f udpgw/badvpn-udpgw ]]; then
                cp udpgw/badvpn-udpgw "$BADVPN_BIN"
            fi
            cd /root || return
            rm -rf "$badvpn_tmp"
        else
            log_warn "Download BadVPN source gagal. Melewati BadVPN."
            return
        fi
    fi

    chmod 755 "$BADVPN_BIN"
    log "BadVPN/UDPGW berhasil diinstall: $BADVPN_BIN"
}

configure_badvpn() {
    log "Mengkonfigurasi BadVPN/UDPGW services..."

    # Buat systemd service untuk setiap port BadVPN
    for port in $BADVPN_PORTS; do
        cat > "/etc/systemd/system/badvpn-udpgw-${port}.service" <<BADVPN_SVC
[Unit]
Description=BadVPN UDPGW Port ${port}
After=network.target

[Service]
Type=simple
ExecStart=$BADVPN_BIN --listen-addr 127.0.0.1:${port} --max-clients 500 --max-connections-for-client 10
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
BADVPN_SVC
    done

    log "Systemd services untuk BadVPN/UDPGW dibuat (port: $BADVPN_PORTS)."
}

start_badvpn() {
    log "Memulai BadVPN/UDPGW services..."

    systemctl daemon-reload >> "$LOG_FILE" 2>&1

    for port in $BADVPN_PORTS; do
        systemctl enable "badvpn-udpgw-${port}" >> "$LOG_FILE" 2>&1
        systemctl restart "badvpn-udpgw-${port}" >> "$LOG_FILE" 2>&1
    done

    # Cek status port utama (7100)
    if systemctl is-active --quiet badvpn-udpgw-7100; then
        log "BadVPN/UDPGW berhasil dijalankan."
    else
        log_warn "BadVPN/UDPGW gagal dijalankan. Periksa binary dan konfigurasi."
    fi
}

# ============================================================================
# Install & Configure Fail2ban
# ============================================================================

install_fail2ban() {
    log "Menginstall Fail2ban..."

    export DEBIAN_FRONTEND=noninteractive

    if ! apt-get install -y fail2ban >> "$LOG_FILE" 2>&1; then
        log_error "Instalasi Fail2ban gagal!"
        exit 1
    fi

    log "Fail2ban berhasil diinstall."
}

configure_fail2ban() {
    log "Mengkonfigurasi Fail2ban..."

    cat > "$FAIL2BAN_CONF" <<'FAIL2BAN_CFG'
# ============================================================================
# Fail2ban Configuration — VPN Tunneling AutoScript
# ============================================================================
# Intrusion prevention untuk SSH brute-force protection
# ============================================================================

[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5
destemail = root@localhost
sendername = Fail2ban
action = %(action_)s

[sshd]
enabled = true
port = ssh,22
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
bantime = 3600

[dropbear]
enabled = true
port = 80,143,443
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
bantime = 3600
FAIL2BAN_CFG

    log "Fail2ban konfigurasi ditulis ke $FAIL2BAN_CONF"
}

start_fail2ban() {
    log "Memulai Fail2ban..."

    systemctl enable fail2ban >> "$LOG_FILE" 2>&1
    systemctl restart fail2ban >> "$LOG_FILE" 2>&1

    if systemctl is-active --quiet fail2ban; then
        log "Fail2ban berhasil dijalankan."
    else
        log_warn "Fail2ban gagal dijalankan. Periksa konfigurasi."
    fi
}

# ============================================================================
# Install OHP (Open HTTP Puncher)
# ============================================================================

install_ohp() {
    log "Menginstall OHP (Open HTTP Puncher)..."

    local ohp_url="https://github.com/lfasmpao/open-http-puncher/releases/download/0.1/ohp-linux-amd64"

    if ! wget --inet4-only --no-check-certificate -O "$OHP_BIN" "$ohp_url" >> "$LOG_FILE" 2>&1; then
        log_warn "Download OHP gagal. Melewati instalasi OHP."
        return
    fi

    chmod 755 "$OHP_BIN"
    log "OHP berhasil diinstall: $OHP_BIN"
}

configure_ohp() {
    log "Mengkonfigurasi OHP services..."

    # OHP untuk OpenSSH (port 2083)
    cat > /etc/systemd/system/ohp-ssh.service <<OHP_SSH_SVC
[Unit]
Description=OHP for OpenSSH (Port 2083)
After=network.target

[Service]
Type=simple
ExecStart=$OHP_BIN -port 2083 -proxy 127.0.0.1:3128 -tunnel 127.0.0.1:22
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
OHP_SSH_SVC

    # OHP untuk Dropbear (port 2084)
    cat > /etc/systemd/system/ohp-dropbear.service <<OHP_DB_SVC
[Unit]
Description=OHP for Dropbear (Port 2084)
After=network.target

[Service]
Type=simple
ExecStart=$OHP_BIN -port 2084 -proxy 127.0.0.1:3128 -tunnel 127.0.0.1:143
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
OHP_DB_SVC

    # OHP untuk OpenVPN (port 2087)
    cat > /etc/systemd/system/ohp-openvpn.service <<OHP_VPN_SVC
[Unit]
Description=OHP for OpenVPN (Port 2087)
After=network.target

[Service]
Type=simple
ExecStart=$OHP_BIN -port 2087 -proxy 127.0.0.1:3128 -tunnel 127.0.0.1:1194
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
OHP_VPN_SVC

    log "OHP services dibuat untuk port $OHP_SSH_PORT, $OHP_DROPBEAR_PORT, $OHP_OPENVPN_PORT."
}

start_ohp() {
    log "Memulai OHP services..."

    systemctl daemon-reload >> "$LOG_FILE" 2>&1

    local ohp_services=(ohp-ssh ohp-dropbear ohp-openvpn)
    for svc in "${ohp_services[@]}"; do
        systemctl enable "$svc" >> "$LOG_FILE" 2>&1
        systemctl restart "$svc" >> "$LOG_FILE" 2>&1
    done

    if systemctl is-active --quiet ohp-ssh; then
        log "OHP services berhasil dijalankan."
    else
        log_warn "OHP services gagal dijalankan. Periksa binary."
    fi
}

# ============================================================================
# Setup SSH Banner
# ============================================================================

setup_banner() {
    log "Membuat SSH banner..."

    cat > "$BANNER_FILE" <<'BANNER_TXT'
<br>
<b>════════════════════════════════</b>
<b>   ⚡ VPN TUNNELING AUTOSCRIPT ⚡</b>
<b>════════════════════════════════</b>
<b>   All-In-One VPN Server</b>
<b>════════════════════════════════</b>
<br>
BANNER_TXT

    chmod 644 "$BANNER_FILE"
    log "SSH banner dibuat: $BANNER_FILE"

    # Konfigurasi OpenSSH untuk menggunakan banner
    local sshd_config="/etc/ssh/sshd_config"
    if [[ -f "$sshd_config" ]]; then
        # Hapus banner config lama jika ada
        sed -i '/^Banner /d' "$sshd_config"
        sed -i '/^#Banner /d' "$sshd_config"

        # Tambahkan banner config
        echo "Banner $BANNER_FILE" >> "$sshd_config"

        log "OpenSSH dikonfigurasi untuk menggunakan banner."

        # Restart sshd
        systemctl restart sshd >> "$LOG_FILE" 2>&1 || systemctl restart ssh >> "$LOG_FILE" 2>&1
    fi
}

# ============================================================================
# Setup Cronjobs
# ============================================================================

setup_cronjobs() {
    log "Mengkonfigurasi cronjobs..."

    # Auto clear log setiap 10 menit
    cat > "$CRON_CLEAR_LOG" <<'CRON_CLEAR'
# Auto Clear Log — VPN Tunneling AutoScript
# Bersihkan log setiap 10 menit
*/10 * * * * root /usr/local/bin/auto-clear-log > /dev/null 2>&1
CRON_CLEAR

    # Buat script auto-clear-log
    cat > /usr/local/bin/auto-clear-log <<'CLEAR_SCRIPT'
#!/bin/bash
# Auto Clear Log — VPN Tunneling AutoScript
# Membersihkan log yang tidak diperlukan

# Clear journal logs yang lebih dari 1 jam
journalctl --vacuum-time=1h > /dev/null 2>&1

# Clear /var/log/*.log yang besar
find /var/log -name "*.log" -size +10M -exec truncate -s 0 {} \; 2>/dev/null

# Clear Xray access log
truncate -s 0 /var/log/xray/access.log 2>/dev/null

# Clear Nginx access log
truncate -s 0 /var/log/nginx/access.log 2>/dev/null
CLEAR_SCRIPT

    chmod 755 /usr/local/bin/auto-clear-log

    # Auto delete expired accounts setiap hari jam 00:00
    cat > "$CRON_DELETE_EXPIRED" <<'CRON_EXPIRED'
# Auto Delete Expired — VPN Tunneling AutoScript
# Hapus akun expired setiap hari jam 00:00
0 0 * * * root /usr/local/bin/auto-delete-expired > /dev/null 2>&1
CRON_EXPIRED

    # Buat script auto-delete-expired (placeholder)
    cat > /usr/local/bin/auto-delete-expired <<'DELETE_SCRIPT'
#!/bin/bash
# Auto Delete Expired — VPN Tunneling AutoScript
# Placeholder: akan diimplementasikan di tahap selanjutnya
# saat menu management akun sudah tersedia

# Cek dan hapus akun SSH expired
# Cek dan hapus akun Xray expired
# Cek dan hapus akun Hysteria2 expired

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Auto delete expired: running" >> /root/syslog.log
DELETE_SCRIPT

    chmod 755 /usr/local/bin/auto-delete-expired

    log "Cronjobs dikonfigurasi:"
    log "  - Auto clear log: setiap 10 menit"
    log "  - Auto delete expired: setiap hari jam 00:00"
}

# ============================================================================
# Main
# ============================================================================

main() {
    # Inisialisasi log (append ke log sebelumnya)
    {
        echo ""
        echo "=== VPN Tunneling AutoScript — Tahap 4 ==="
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
    check_tahap3
    log "Semua pengecekan prasyarat berhasil."

    echo ""
    echo -e "${BLUE}Semua prasyarat terpenuhi. Memulai setup Tahap 4...${NC}"
    echo ""

    # 1. Install dan konfigurasi Dropbear SSH
    install_dropbear
    configure_dropbear
    start_dropbear

    # 2. Install dan konfigurasi Stunnel
    install_stunnel
    configure_stunnel
    start_stunnel

    # 3. Buat SSH WebSocket handler
    create_sshws

    # 4. Install dan konfigurasi HAProxy
    install_haproxy
    configure_haproxy
    start_haproxy

    # 5. Install dan konfigurasi Squid
    install_squid
    configure_squid
    start_squid

    # 6. Install dan konfigurasi BadVPN/UDPGW
    install_badvpn
    configure_badvpn
    start_badvpn

    # 7. Install dan konfigurasi Fail2ban
    install_fail2ban
    configure_fail2ban
    start_fail2ban

    # 8. Install OHP
    install_ohp
    configure_ohp
    start_ohp

    # 9. Setup SSH Banner
    setup_banner

    # 10. Setup Cronjobs
    setup_cronjobs

    # Selesai
    echo ""
    echo -e "${GREEN}=============================================="
    echo "  Tahap 4 selesai!"
    echo ""
    echo "  SSH Tunneling:"
    echo "    OpenSSH      : port $OPENSSH_PORT"
    echo "    Dropbear     : port $DROPBEAR_PORTS"
    echo "    Stunnel SSH  : port $DROPBEAR_STUNNEL_PORT"
    echo "    Stunnel WS   : port $DROPBEAR_STUNNEL_WS_PORT"
    echo "    SSH WS       : port $SSHWS_HTTP_PORT"
    echo ""
    echo "  Load Balancer:"
    echo "    HAProxy HTTP : port $HAPROXY_HTTP_PORT"
    echo "    HAProxy HTTPS: port $HAPROXY_HTTPS_PORT"
    echo ""
    echo "  Proxy:"
    echo "    Squid        : port $SQUID_PORT1, $SQUID_PORT2"
    echo ""
    echo "  OHP:"
    echo "    SSH          : port $OHP_SSH_PORT"
    echo "    Dropbear     : port $OHP_DROPBEAR_PORT"
    echo "    OpenVPN      : port $OHP_OPENVPN_PORT"
    echo ""
    echo "  BadVPN/UDPGW   : port $BADVPN_PORTS"
    echo ""
    echo "  Security:"
    echo "    Fail2ban     : $(systemctl is-active fail2ban 2>/dev/null || echo 'unknown')"
    echo "    Banner       : $BANNER_FILE"
    echo ""
    echo "  Cronjobs:"
    echo "    Clear Log    : setiap 10 menit"
    echo "    Del Expired  : setiap hari jam 00:00"
    echo ""
    echo "  Sistem siap untuk instalasi komponen tambahan."
    echo -e "==============================================${NC}"
    echo ""

    log "Tahap 4 selesai. SSH Tunneling, HAProxy, dan services pendukung berhasil diinstall."
}

main "$@"
