<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&weight=700&size=28&pause=1000&color=00F7FF&center=true&vCenter=true&width=600&lines=⚡+VPN+TUNNELING+AUTOSCRIPT+⚡;All-In-One+Installer+for+VPS" alt="VPN Tunneling Autoscript">
</p>

<h1 align="center">🚀 VPN Tunneling AutoScript Installer</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Version-2.0.0-blue?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">
  <img src="https://img.shields.io/badge/Status-Development-yellow?style=for-the-badge" alt="Status">
  <img src="https://img.shields.io/badge/Shell-Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white" alt="Shell">
  <img src="https://img.shields.io/badge/Xray--core-Latest-blueviolet?style=for-the-badge" alt="Xray">
  <img src="https://img.shields.io/badge/Hysteria2-Supported-orange?style=for-the-badge" alt="Hysteria2">
</p>

<p align="center">
  Script bash installer All-In-One (AIO) untuk VPN Tunneling di VPS berbasis Ubuntu & Debian.<br>
  Mendukung multi-protocol <b>Xray-core</b> (VMess, VLESS, Trojan, Shadowsocks, Socks),<br>
  <b>Hysteria2</b>, <b>SSH Tunneling</b>, <b>SlowDNS</b>, <b>UDP Custom</b>, <b>BadVPN</b>,<br>
  <b>OpenVPN</b>, <b>SoftEther</b>, <b>Cloudflare WARP</b>, dan banyak lagi.
</p>

---

## 📋 Daftar Isi

- [Tentang Project](#-tentang-project)
- [Komponen Utama](#-komponen-utama)
- [OS yang Didukung](#-os-yang-didukung)
- [Persyaratan Sistem](#-persyaratan-sistem)
- [Daftar Port & Protocol](#-daftar-port--protocol)
- [Daftar Path WebSocket & gRPC](#-daftar-path-websocket--grpc)
- [Fitur Utama](#-fitur-utama)
- [Fitur Protocol & Tunneling](#-fitur-protocol--tunneling)
- [Fitur Manajemen Akun](#-fitur-manajemen-akun)
- [Fitur Jaringan & CDN](#-fitur-jaringan--cdn)
- [Fitur Bot, Panel & Integrasi](#-fitur-bot-panel--integrasi)
- [Fitur Keamanan](#-fitur-keamanan)
- [Fitur Monitoring & Logging](#-fitur-monitoring--logging)
- [Fitur Sistem & Optimasi](#-fitur-sistem--optimasi)
- [Struktur Direktori](#-struktur-direktori)
- [Instalasi](#-instalasi)
- [Perintah Menu](#-perintah-menu)
- [REST API](#-rest-api)
- [Konfigurasi Lanjutan](#-konfigurasi-lanjutan)
- [Troubleshooting / FAQ](#-troubleshooting--faq)
- [Referensi Repository](#-referensi-repository)
- [Roadmap](#-roadmap)
- [Changelog](#-changelog)
- [Lisensi](#-lisensi)

---

## 📖 Tentang Project

**VPN Tunneling AutoScript** adalah script otomasi berbasis bash yang dirancang untuk mempermudah instalasi dan konfigurasi layanan VPN tunneling pada VPS. Script ini mendukung berbagai protokol modern dan legacy, menjadikannya solusi All-In-One (AIO) paling lengkap untuk kebutuhan tunneling.

Script ini cocok untuk:
- 🏪 **VPN Provider** yang ingin deploy server cepat
- 🧑‍💻 **System Administrator** yang butuh tunneling secure
- 📡 **Reseller VPN** yang membutuhkan manajemen akun lengkap
- 🔧 **Developer** yang ingin mengintegrasikan via REST API
- 🎮 **Gamer** yang butuh UDP tunneling (BadVPN/UDP Custom)
- 📺 **Streaming Enthusiast** yang butuh bypass geo-restriction

---

## 🧩 Komponen Utama

| Komponen | Deskripsi |
|----------|-----------|
| **Xray-core** | Multi-protocol proxy (VMess, VLESS, Trojan, Shadowsocks, Socks) |
| **Hysteria2** | Protokol UDP modern berbasis QUIC, ultra-fast |
| **Nginx** | Reverse proxy & web server untuk TLS termination |
| **HAProxy** | Load balancer untuk port 80/443 |
| **Stunnel** | SSL/TLS tunnel untuk SSH & OpenVPN |
| **Dropbear** | Lightweight SSH server |
| **OpenSSH** | SSH server utama |
| **OpenVPN** | VPN TCP/UDP/TLS |
| **SoftEther VPN** | Multi-protocol VPN server (SSTP, L2TP, IPSec, OpenVPN) |
| **SlowDNS/DNSTT** | DNS tunneling |
| **BadVPN/UDPGW** | UDP gateway untuk game & VoIP |
| **UDP Custom** | UDP tunneling custom port |
| **Squid Proxy** | HTTP proxy |
| **Dante/Socks5** | Socks5 proxy server |
| **OHP** | Open HTTP Puncher |
| **Trojan-Go** | Trojan versi Go (lebih cepat) |
| **Cloudflare WARP** | WireGuard via Cloudflare |
| **Rclone** | Cloud storage backup & restore |
| **Fail2ban** | Intrusion prevention system |
| **Certbot/Acme.sh** | SSL certificate management |
| **vnStat** | Network traffic monitoring |
| **Webmin** | Web-based system admin panel |

---

## 💻 OS yang Didukung

### Ubuntu

| Versi | Status | Codename |
|-------|--------|----------|
| Ubuntu 20.04 LTS | ✅ **Stable** | focal |
| Ubuntu 22.04 LTS | ✅ **Stable** | jammy |
| Ubuntu 24.04 LTS | ✅ **Stable** | noble |

### Debian

| Versi | Status | Codename |
|-------|--------|----------|
| Debian 10 | ✅ **Stable** | buster |
| Debian 11 | ✅ **Stable** | bullseye |
| Debian 12 | ✅ **Stable** | bookworm |

---

## ⚙️ Persyaratan Sistem

| Sistem | Minimal | Disarankan |
|--------|---------|------------|
| **Virtualisasi** | KVM / Xen | KVM / Xen |
| **CPU Arch** | amd64 (64-bit) | amd64 (64-bit) |
| **CPU** | 1 Core | 2 Cores atau lebih |
| **RAM** | 512 MB | 1 GB atau lebih |
| **Storage** | 15 GB | 20 GB atau lebih |
| **Network** | 1x IPv4, Disable IPv6, Open Port | 1x IPv4, Disable IPv6, Open Port |
| **OS** | Fresh/Clean Install | Fresh/Clean Install |
| **Akses** | Root | Root |
| **Domain** | Sudah diarahkan ke IP VPS | Sudah diarahkan ke IP VPS |
| **Cloudflare** | Akun Cloudflare aktif | Akun Cloudflare + API Key |

### Provider VPS yang Direkomendasikan

| Provider | Status |
|----------|--------|
| AWS Lightsail | ✅ Tested |
| DigitalOcean | ✅ Tested |
| Linode | ✅ Tested |
| Vultr | ✅ Tested |
| OVH | ✅ Compatible |
| Biznet | ✅ Compatible |
| APIK Media | ✅ Compatible |
| iDCLC | ✅ Compatible |
| IP ServerOne | ✅ Compatible |
| Atha Media | ✅ Compatible |
| Media Antar Nusa | ✅ Compatible |

> ⚠️ **Penting:** Pastikan provider VPS mengizinkan penggunaan VPN Server. Server yang tersuspend karena larangan penggunaan VPN oleh provider VPS adalah di luar kuasa admin.

---

## 🌐 Daftar Port & Protocol

### 🔒 Xray Protocol — TLS (Port 443)

| Service | Transport | Port | TLS | ALPN |
|---------|-----------|------|-----|------|
| **VMess WS TLS** | WebSocket | 443 | ✅ TLS | h2, http/1.1 |
| **VMess gRPC TLS** | gRPC | 443 | ✅ TLS | h2 |
| **VMess HTTP Upgrade** | HTTP Upgrade | 443 | ✅ TLS | h2, http/1.1 |
| **VLESS WS TLS** | WebSocket | 443 | ✅ TLS | h2, http/1.1 |
| **VLESS gRPC TLS** | gRPC | 443 | ✅ TLS | h2 |
| **VLESS HTTP Upgrade** | HTTP Upgrade | 443 | ✅ TLS | h2, http/1.1 |
| **Trojan WS TLS** | WebSocket | 443 | ✅ TLS | h2, http/1.1 |
| **Trojan gRPC TLS** | gRPC | 443 | ✅ TLS | h2 |
| **Trojan TCP TLS** | TCP | random | ✅ TLS | h2, http/1.1 |
| **Trojan HTTP Upgrade** | HTTP Upgrade | 443 | ✅ TLS | h2, http/1.1 |
| **Shadowsocks WS TLS** | WebSocket | 443 | ✅ TLS | h2, http/1.1 |
| **Shadowsocks gRPC TLS** | gRPC | 443 | ✅ TLS | h2 |
| **Socks WS TLS** | WebSocket | 443 | ✅ TLS | h2, http/1.1 |
| **Socks gRPC TLS** | gRPC | 443 | ✅ TLS | h2 |

### 🔓 Xray Protocol — Non-TLS (Port 80)

| Service | Transport | Port | TLS |
|---------|-----------|------|-----|
| **VMess WS Non-TLS** | WebSocket | 80, 443 | ❌ None |
| **VLESS WS Non-TLS** | WebSocket | 80, 443 | ❌ None |
| **Trojan WS Non-TLS** | WebSocket | 80, 443 | ❌ None |
| **Shadowsocks WS Non-TLS** | WebSocket | 80, 443 | ❌ None |
| **Shadowsocks TCP Non-TLS** | TCP | random | ❌ None |
| **Socks WS Non-TLS** | WebSocket | 80, 443 | ❌ None |
| **Socks TCP Non-TLS** | TCP | random | ❌ None |

### ⚡ Hysteria2 Protocol

| Service | Transport | Port | Protocol |
|---------|-----------|------|----------|
| **Hysteria2** | QUIC/UDP | Load Balance `random` | UDP |
| **Hysteria2** | QUIC/UDP | Non-LB `80`, `443` | UDP |

### 🔑 SSH Tunneling

| Service | Port | Keterangan |
|---------|------|------------|
| **OpenSSH** | 22 | Default SSH port |
| **Dropbear** | 80, 143, 443 | Lightweight SSH |
| **Dropbear Stunnel** | 446 | Dropbear via SSL |
| **Dropbear Stunnel WS** | 445 | Dropbear WS via SSL |
| **SSH WebSocket** | 80, 443, 8880 | SSH over WebSocket |
| **SSH WebSocket TLS** | 80, 443, 445 (Stunnel) | SSH WS via TLS |
| **SSH SlowDNS** | 53, 5300, 2222 | DNS Tunneling via SlowDNS/DNSTT |

### 🟢 OpenVPN

| Service | Port | Keterangan |
|---------|------|------------|
| **OpenVPN TCP** | 1194, 2294 | OpenVPN via TCP |
| **OpenVPN UDP** | 2200, 2295 | OpenVPN via UDP |
| **OpenVPN TLS** | 2296 (Stunnel) | OpenVPN via SSL/TLS |
| **OpenVPN OHP** | 2087 | OpenVPN via OHP |

### 🔵 SoftEther VPN

| Service | Port | Keterangan |
|---------|------|------------|
| **SoftEther Remote** | 5555 | Remote management |
| **SoftEther OpenVPN TCP/UDP** | 1194 | OpenVPN compatible |
| **SoftEther OpenVPN TLS** | 1195 (Stunnel) | OpenVPN via SSL |
| **SoftEther SSTP** | 4433 | SSTP protocol |
| **SoftEther L2TP/IPSec** | 500, 1701, 4500 | L2TP/IPSec |

### 🟡 Trojan-Go

| Service | Port | Keterangan |
|---------|------|------------|
| **Trojan-Go WS TLS** | 80, 443 | Trojan-Go via WebSocket |

### 🛠️ Proxy & UDP Services

| Service | Port | Keterangan |
|---------|------|------------|
| **HTTP Proxy / Squid** | 3128, 8080 | HTTP proxy server |
| **Socks5 Proxy** | 80, 443, 990, 1080 | Socks5 proxy |
| **OHP OpenSSH** | 2083 | Open HTTP Puncher untuk SSH |
| **OHP Dropbear** | 2084 | OHP untuk Dropbear |
| **OHP OpenVPN** | 2087 | OHP untuk OpenVPN |
| **BadVPN/UDPGW** | 7100, 7200, 7300, 7400, 7500, 7600, 7700, 7800, 7900 | UDP Gateway |
| **UDP Custom** | 1-65535 | UDP tunneling custom |
| **UDP Request** | 1-65535 | UDP request handler |

### 🌍 CDN & Tunnel Services

| Service | Port | Keterangan |
|---------|------|------------|
| **Cloudflare WARP** | 51820 | WireGuard via Cloudflare |
| **Cloudflare Argo Tunnel** | dynamic | Tunnel via Cloudflare |
| **Nginx Webserver** | 443, 80, 81, 663 | Reverse proxy & web server |
| **HAProxy Loadbalancer** | 443, 80 | Load balancer port 80/443 |
| **DNS Server** | 443, 53 | DNS service |
| **DNS Client** | 443, 88 | DNS client |
| **API Service** | 9000 | REST API endpoint |
| **vnStat Web** | 8899 | Bandwidth monitoring web |

---

## 🔗 Daftar Path WebSocket & gRPC

### Xray Path

| Service | Path WS | gRPC Service Name |
|---------|---------|-------------------|
| **VMess WS** | `/vmessws` | - |
| **VMess gRPC** | - | `vmess-grpc` |
| **VMess HTTP Upgrade** | `/vmess-httpupgrade` | - |
| **VLESS WS** | `/vlessws` | - |
| **VLESS gRPC** | - | `vless-grpc` |
| **VLESS HTTP Upgrade** | `/vless-httpupgrade` | - |
| **Trojan WS** | `/trojanws` | - |
| **Trojan gRPC** | - | `trojan-grpc` |
| **Trojan HTTP Upgrade** | `/trojan-httpupgrade` | - |
| **Shadowsocks WS** | `/ssws` | - |
| **Shadowsocks gRPC** | - | `ss-grpc` |
| **Socks WS** | `/socksws` | - |
| **Socks gRPC** | - | `socks-grpc` |
| **SSH WS** | `/ssh` | - |
| **Trojan-Go WS** | `/trojan-go` | - |

> 💡 **Dynamic Path:** Semua path mendukung dynamic routing. Contoh: `/ssh` bisa diakses via `/whatever/ssh/whatever` selama mengandung keyword path.

### Path dengan Query (V2Ray / XRay)

```
Path with Query:
  /YOURPATH?type=xray-vmess-ws-ntls
  /YOURPATH?type=xray-vmess-ws-tls
  /YOURPATH?type=xray-vless-ws-ntls
  /YOURPATH?type=xray-vless-ws-tls
  /YOURPATH?type=xray-trojan-ws-ntls
  /YOURPATH?type=xray-trojan-ws-tls
  /YOURPATH?type=xray-shadowsocks-ws-ntls
  /YOURPATH?type=xray-shadowsocks-ws-tls
  /YOURPATH?type=xray-socks-ws-ntls
  /YOURPATH?type=xray-socks-ws-tls

Path without Query (Clash compatible):
  /YOURPATH/xray-vmess-ws-tls
  /YOURPATH/xray-vless-ws-tls
  /YOURPATH/xray-trojan-ws-tls
  /YOURPATH/xray-shadowsocks-ws-tls
  /YOURPATH/xray-socks-ws-tls
```

> 🔁 Ganti `YOURPATH` dengan method path Anda. Path **tanpa** `?` mendukung Clash.

### ALPN Support

| Protocol | Description |
|----------|-------------|
| HTTP/1.1 | Standard HTTP |
| h2 | HTTP/2 (Multiplexing) |
| h3 *(coming soon)* | HTTP/3 (QUIC-based) |

---

## ✨ Fitur Utama

| Fitur | Deskripsi |
|-------|-----------|
| 🎛️ **Full CLI Dashboard** | Menu interaktif dengan UI menarik (box drawing, warna) |
| 📊 **Multi Protocol Multi Port** | Support semua protokol dalam satu server |
| 🌐 **All CDN Support** | Kompatibel dengan Cloudflare, AWS CloudFront, dll |
| 🔃 **Load Balance 80/443** | Load balancing untuk port 80 dan 443 via HAProxy |
| 📡 **Pointing Domain Cloudflare** | Otomatis pointing domain via Cloudflare API |
| 🔐 **Auto Install SSL** | Otomatis install & renew sertifikat SSL (Certbot/Acme.sh) |
| 💾 **Backup & Restore** | Backup dan restore konfigurasi via Rclone (Google Drive, Dropbox, dll) |
| 🤖 **REST API & Dokumentasi** | API service pada port 9000 untuk integrasi |
| 📱 **Telegram Bot Remote** | Kontrol VPS langsung dari bot Telegram |
| 📱 **Telegram Bot Seller Panel** | Panel penjualan akun via bot Telegram |
| 📱 **Telegram Bot Notification** | Notifikasi otomatis saat akun dibuat/expired |
| 🕐 **Custom Autoreboot** | Jadwal reboot otomatis sesuai keinginan |
| 🔧 **ON/OFF Service Menu** | Kontrol service individual dari menu |
| 🖥️ **vnStat Web Interface** | Monitoring bandwidth via web browser |
| 📜 **HideSSH Web Panel** | Web panel terintegrasi untuk management |
| 📦 **Subscription Link Generator** | Generate & manage subscription link untuk Xray client |
| 🎨 **Auto Generate Clash Config** | Auto generate config Clash (VMess, VLESS, Trojan, SS, Socks) |
| 🔄 **VPNRay JSON Converter** | Converter config untuk custom HTTP |
| 🆓 **Free Domain for Tunnel** | Domain gratis untuk tunneling |
| 💡 **Lightweight CPU** | CPU idle rata-rata 2-3% setelah fresh install |
| ♻️ **Service on Demand** | Jalankan service hanya jika ada akun aktif (hemat resource) |

---

## 🔌 Fitur Protocol & Tunneling

### Xray-core Multi Protocol

| Protocol | WS TLS | WS Non-TLS | gRPC TLS | HTTP Upgrade | TCP TLS |
|----------|--------|------------|----------|--------------|---------|
| **VMess** | ✅ | ✅ | ✅ | ✅ | ❌ |
| **VLESS** | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Trojan** | ✅ | ✅ | ✅ | ✅ | ✅ |
| **Shadowsocks** | ✅ | ✅ | ✅ | ❌ | ✅ (Non-TLS) |
| **Socks** | ✅ | ✅ | ✅ | ❌ | ✅ (Non-TLS) |

### Protokol Tambahan

| Protocol | Status | Deskripsi |
|----------|--------|-----------|
| **Hysteria2** | ✅ Supported | Protokol QUIC/UDP ultra-fast |
| **Trojan-Go** | ✅ Supported | Trojan versi Go, performa tinggi |
| **OpenVPN TCP** | ✅ Supported | VPN via TCP |
| **OpenVPN UDP** | ✅ Supported | VPN via UDP |
| **OpenVPN TLS** | ✅ Supported | VPN via Stunnel TLS |
| **SoftEther VPN** | ✅ Supported | Multi-protocol (SSTP, L2TP, IPSec, OpenVPN) |
| **Cloudflare WARP** | ✅ Supported | WireGuard via Cloudflare |
| **Cloudflare Argo Tunnel** | ✅ Supported | Tunnel via Cloudflare (SSH/XRAY) |

### SSH Tunneling

| Protocol | Status | Deskripsi |
|----------|--------|-----------|
| **SSH WebSocket TLS** | ✅ | SSH over WebSocket dengan TLS |
| **SSH WebSocket Non-TLS** | ✅ | SSH WebSocket tanpa TLS |
| **SSH Stunnel/SSL** | ✅ | SSH via SSL/TLS tunnel |
| **SSH SlowDNS/DNSTT** | ✅ | DNS tunneling untuk SSH |
| **Dropbear SSH** | ✅ | Lightweight SSH server |
| **Dropbear Stunnel** | ✅ | Dropbear via SSL |
| **Dropbear Stunnel WS** | ✅ | Dropbear WebSocket via SSL |

### Proxy & UDP Tunneling

| Protocol | Status | Deskripsi |
|----------|--------|-----------|
| **HTTP Proxy (Squid)** | ✅ | HTTP proxy server |
| **Socks5 Proxy** | ✅ | Socks5 proxy server |
| **OHP (Open HTTP Puncher)** | ✅ | HTTP puncher untuk SSH, Dropbear, OpenVPN |
| **BadVPN/UDPGW** | ✅ | UDP Gateway port 7100-7900 (game, VoIP) |
| **UDP Custom** | ✅ | UDP tunneling custom port 1-65535 |
| **UDP Request** | ✅ | UDP request handler port 1-65535 |

---

## 👤 Fitur Manajemen Akun

### Operasi Akun

| Fitur | SSH | VMess | VLESS | Trojan | Shadowsocks | Socks | Hysteria2 |
|-------|-----|-------|-------|--------|-------------|-------|-----------|
| ➕ Create Account | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| ➕ Bulk Create | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| ❌ Delete Account | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 🔄 Renew/Extend | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 🔒 Lock Account | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 🔓 Unlock Account | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 📋 User Details | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 👥 List Members | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 👁️ Check User Login | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 🖥️ Limit IP Login | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 📦 Limit Quota | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 🚷 Ban/Unban | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 🔄 Recover Expired | ❌ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

### Otomasi Akun

| Fitur | Deskripsi |
|-------|-----------|
| ⏰ **Auto Delete Expired** | Hapus akun expired otomatis setiap hari (cronjob) |
| 🧹 **Auto Clear Log** | Bersihkan log otomatis setiap 10 menit |
| 🔌 **Auto Disconnect Duplicate** | Disconnect session duplikat otomatis |
| 📊 **Bandwidth Per User** | Monitoring penggunaan bandwidth per akun |
| 🗓️ **Expiry Checker** | Cek masa aktif akun SSH & Xray |

---

## 🌍 Fitur Jaringan & CDN

| Fitur | Deskripsi |
|-------|-----------|
| ☁️ **Cloudflare CDN Support** | Kompatibel penuh dengan Cloudflare CDN |
| ☁️ **Cloudflare WARP** | WireGuard via Cloudflare (Domain, GeoIP, IP/CIDR Targeting) |
| ☁️ **Cloudflare Argo Tunnel** | Multi-server tunnel via Cloudflare |
| ☁️ **Auto Update IP to Cloudflare** | DDNS otomatis update IP ke domain Cloudflare |
| 🌐 **AWS CloudFront CDN** | Support CDN HTTP/HTTPS via akun AWS sendiri |
| 📡 **SNI Reverse Proxy** | Reverse proxy berbasis SNI |
| 🔃 **Load Balance 80/443** | HAProxy load balancer untuk multi-service di port yang sama |
| 📺 **Bypass Streaming** | Bypass geo-restriction (Netflix, Disney+, Hotstar, dll) |
| 🚫 **Domain Blacklist Management** | Block domain tertentu via Xray routing |
| 🚫 **BT Download Block** | Blokir download P2P/BitTorrent |
| 🚫 **Auto Block Ads Indo** | Block iklan Indonesia secara default via hosts |
| 🌐 **Multi-Path Xray** | Konfigurasi multi-path untuk Xray |

---

## 🤖 Fitur Bot, Panel & Integrasi

| Fitur | Deskripsi |
|-------|-----------|
| 🤖 **Telegram Bot Remote** | Kontrol VPS langsung dari bot Telegram (CRUD akun, reboot, dll) |
| 🤖 **Telegram Bot Seller Panel** | Panel penjualan otomatis via bot Telegram |
| 🤖 **Telegram Bot Notification** | Notifikasi otomatis saat akun dibuat/expired/login |
| 🌐 **REST API (Port 9000)** | API untuk integrasi web panel, bot, mobile app |
| 🌐 **WebAPI Services** | WebAPI untuk pengembangan web |
| 📊 **HideSSH Web Panel** | Web panel terintegrasi untuk management akun |
| 📊 **vnStat Web Interface** | Monitoring bandwidth via web browser (port 8899) |
| 📊 **Webmin** | Web-based system admin panel |
| 🔗 **Subscription Link** | Generate & manage subscription link untuk client app |
| 🎨 **Clash Config Generator** | Auto generate Clash config (VMess, VLESS, Trojan, SS, Socks) |
| 🔄 **VPNRay JSON Converter** | Converter config custom HTTP & VPNRay format |

---

## 🔐 Fitur Keamanan

```
┌──────────────────────────────────────────────────────────┐
│                    SECURITY FEATURES                      │
├──────────────────────────────────────────────────────────┤
│  ✅ Fail2ban Auto Configuration                          │
│  ✅ SSH Brute-force Protection                           │
│  ✅ Auto Block Indonesian Ads (hosts-based)              │
│  ✅ IP Whitelist / Blacklist                             │
│  ✅ Multi-Login Detection & Notification                 │
│  ✅ Auto Disconnect Duplicate Session                    │
│  ✅ SSL/TLS Encryption (Cloudflare / Let's Encrypt)     │
│  ✅ Firewall UFW/IPTABLES Auto Configuration             │
│  ✅ Service Isolation per User                           │
│  ✅ Auto Log Rotation & Cleanup (10 min)                 │
│  ✅ Domain Blacklist & BT Download Block                 │
│  ✅ Ban/Unban Services per User                          │
│  ✅ Account Lock/Unlock without Delete                   │
│  ✅ IP Login Limit per Account                           │
│  ✅ Bandwidth Quota Limit per Account                    │
│  ✅ Cloudflare SSL / Auto Renew Certificate              │
└──────────────────────────────────────────────────────────┘
```

---

## 📈 Fitur Monitoring & Logging

| Fitur | Deskripsi |
|-------|-----------|
| 📊 **vnStat Monitoring** | Monitor bandwidth real-time via CLI & web |
| 📊 **Bandwidth Per User** | Tracking bandwidth per akun |
| 📊 **Bandwidth Meter Provider API** | Monitor bandwidth langsung dari provider VPS |
| 📋 **Running Services Check** | Cek status semua service yang berjalan |
| 🖥️ **VPS Info & Provider Detail** | Info lengkap VPS: OS, provider, IP, uptime |
| ��� **Installation Log** | Log instalasi tersimpan di `/root/syslog.log` |
| 🧹 **Auto Clear Log / 10 Menit** | Cronjob membersihkan log setiap 10 menit |
| 🏎️ **Speedtest** | Speedtest server by Ookla |
| 📊 **CPU & Memory Usage** | Monitor penggunaan CPU dan RAM |

---

## 🔧 Fitur Sistem & Optimasi

| Fitur | Deskripsi |
|-------|-----------|
| 💾 **SWAP Memory** | Otomatis setup swap file 1GB/2GB (selectable) |
| 💡 **Lightweight CPU** | CPU idle rata-rata 2-3% setelah install |
| ♻️ **Service on Demand** | Service hanya berjalan jika ada akun aktif (hemat resource) |
| 🕐 **Custom Autoreboot** | Jadwal reboot otomatis (default OFF, user set) |
| 🔄 **Change Timezone** | Ubah timezone server (default: Asia/Jakarta GMT+7) |
| 🎨 **Change Dropbear Banner** | Kustomisasi banner Dropbear/OpenSSH |
| 🔄 **Change Dropbear Version** | Ganti versi Dropbear dari menu |
| 🔄 **Switch SSH WS Dropbear↔OpenSSH** | Ganti backend SSH WebSocket |
| 🔄 **Switch SSH Stunnel Dropbear↔OpenSSH** | Ganti backend SSH Stunnel |
| 🔄 **Change Stunnel Port** | Ganti port SSH Stunnel (default 446 → 443) |
| 🎛️ **Admin Access Control** | Menu admin untuk grant root access |
| 🗑️ **Uninstall / Rebuild Menu** | Uninstall script atau rebuild VPS dari menu |
| 🎨 **Disable/Enable VPNRay Coloring** | Toggle warna teks output |
| 🎨 **Disable/Enable Clash Config** | Toggle auto generate Clash config |
| 🎨 **Disable/Enable VPNRay Prefill** | Toggle prefill data akun |
| ☁️ **Backup & Restore Rclone** | Sinkronisasi ke Google Drive, Dropbox, OneDrive, dll |
| 🛡️ **SoftEther VPN Password** | Lihat & manage password SoftEther VPN Server |
| 🔑 **Cloudflare API Key Setup** | Setup Global API Key / Token API |
| 🔑 **AWS CloudFront API Key** | Setup AWS Access Key untuk CDN |

---

## 📂 Struktur Direktori

```
/etc/
├── xray/                        # Konfigurasi Xray-core
│   ├── config.json              # Config utama Xray
│   ├── vmess-ws.json            # Config VMess WS
│   ├── vmess-grpc.json          # Config VMess gRPC
│   ├── vmess-httpupgrade.json   # Config VMess HTTP Upgrade
│   ├── vless-ws.json            # Config VLESS WS
│   ├── vless-grpc.json          # Config VLESS gRPC
│   ├── vless-httpupgrade.json   # Config VLESS HTTP Upgrade
│   ├── trojan-ws.json           # Config Trojan WS
│   ├── trojan-grpc.json         # Config Trojan gRPC
│   ├── trojan-tcp.json          # Config Trojan TCP
│   ├── trojan-httpupgrade.json  # Config Trojan HTTP Upgrade
│   ├── shadowsocks-ws.json      # Config Shadowsocks WS
│   ├── shadowsocks-grpc.json    # Config Shadowsocks gRPC
│   ├── socks-ws.json            # Config Socks WS
│   ├── socks-grpc.json          # Config Socks gRPC
│   ├── xray.crt                 # SSL certificate
│   ├── xray.key                 # SSL private key
│   ├── domain                   # File domain aktif
│   └── cloudflare               # Cloudflare API credentials
├── hysteria2/                   # Konfigurasi Hysteria2
│   └── config.yaml              # Config Hysteria2
├── trojan-go/                   # Konfigurasi Trojan-Go
│   └── config.json              # Config Trojan-Go
├── nginx/                       # Konfigurasi Nginx
│   ├── conf.d/
│   │   └── xray.conf            # Reverse proxy config
│   └── nginx.conf               # Main config
├── haproxy/                     # HAProxy load balancer
│   └── haproxy.cfg
├── openvpn/                     # OpenVPN configuration
│   ├── server-tcp.conf          # OpenVPN TCP config
│   └── server-udp.conf          # OpenVPN UDP config
├── softether/                   # SoftEther VPN
│   └── vpn_server.config
├── stunnel/                     # SSL tunnel config
│   └── stunnel.conf
├── squid/                       # Squid HTTP proxy
│   └── squid.conf
├── fail2ban/                    # Fail2ban config
│   └── jail.local
├── warp/                        # Cloudflare WARP config
│   └── warp.conf
├── cron.d/                      # Cronjob configs
│   ├── auto-clear-log           # Clear log / 10 menit
│   ├── auto-delete-expired      # Hapus akun expired
│   └── auto-reboot              # Custom autoreboot
└── vnstat/                      # vnStat config

/usr/local/bin/                  # Script menu & utility
├── menu                         # Menu utama
├── menu-ssh                     # Menu SSH management
├── menu-vmess                   # Menu VMess management
├── menu-vless                   # Menu VLESS management
├── menu-trojan                  # Menu Trojan management
├── menu-shadowsocks             # Menu Shadowsocks management
├── menu-socks                   # Menu Socks management
├── menu-hysteria2               # Menu Hysteria2 management
├── menu-trojan-go               # Menu Trojan-Go management
├── menu-openvpn                 # Menu OpenVPN management
├── menu-softether               # Menu SoftEther management
├── menu-warp                    # Menu Cloudflare WARP
├── menu-backup                  # Menu backup & restore
├── menu-api                     # Menu API configuration
├── menu-bot                     # Menu Telegram Bot
├── menu-system                  # Menu System settings
├── running                      # Cek service running
├── speedtest                    # Speedtest server
├── auto-clear-log               # Script clear log
├── auto-delete-expired          # Script hapus expired
├── xp-ssh                       # SSH expiry checker
├── xp-xray                      # Xray expiry checker
├── limit-ip-ssh                 # Limit IP SSH
├── limit-ip-xray                # Limit IP Xray
├── limit-quota-xray             # Limit quota Xray
├── lock-ssh                     # Lock akun SSH
├── lock-xray                    # Lock akun Xray
├── cf-domain                    # Cloudflare domain pointing
├── install-ssl                  # Install SSL certificate
├── sshws                        # SSH WebSocket handler
├── udp-custom                   # UDP Custom handler
├── badvpn-udpgw                 # BadVPN UDPGW service
└── ohp                          # Open HTTP Puncher

/home/vps/                       # Data akun & backup
├── public_html/                 # Web directory
└── backup/                      # Local backup directory

~/.config/rclone/                # Rclone config
└── rclone.conf                  # Cloud storage config
```

---

## 🚀 Instalasi

### Tahap 1: Update Sistem & Reboot

```bash
export DEBIAN_FRONTEND=noninteractive
addgroup dip &>/dev/null
apt-get update -y --allow-releaseinfo-change && \
apt-get install --reinstall -y grub && \
apt-get upgrade -y --fix-missing && \
update-grub && \
sleep 2 && \
reboot
```

### Tahap 2: Install Dependencies & Jalankan Installer

```bash
export DEBIAN_FRONTEND=noninteractive
source /etc/os-release
sysctl -w net.ipv6.conf.all.disable_ipv6=1 && \
sysctl -w net.ipv6.conf.default.disable_ipv6=1 && \
apt-get update && \
apt-get --reinstall --fix-missing install -y whois bzip2 gzip coreutils wget screen nscd curl tmux gnupg perl dnsutils && \
wget --inet4-only --no-check-certificate -O setup.sh "https://raw.githubusercontent.com/kertasbaru/autoscript/main/install.sh" && \
chmod +x setup.sh && \
screen -S setup ./setup.sh
```

### Tahap 2 (Alternatif): Menggunakan Cloudflare API Key Pribadi

```bash
export DEBIAN_FRONTEND=noninteractive
source /etc/os-release
sysctl -w net.ipv6.conf.all.disable_ipv6=1 && \
sysctl -w net.ipv6.conf.default.disable_ipv6=1 && \
apt-get update && \
apt-get --reinstall --fix-missing install -y whois bzip2 gzip coreutils wget screen nscd curl tmux gnupg perl dnsutils && \
wget --inet4-only --no-check-certificate -O setup.sh "https://raw.githubusercontent.com/kertasbaru/autoscript/main/install.sh" && \
chmod +x setup.sh && \
screen -S setup ./setup.sh "CFAPIKEY"

# Ganti CFAPIKEY dengan API Key Cloudflare milikmu
```

#### Cara Membuat Cloudflare API Key

1. Pergi ke https://dash.cloudflare.com/profile/api-tokens
2. Pilih `Create Token`
3. Pilih template `Edit zone DNS`, lalu `Use template`
4. Beri nama API Key, pilih domain yang akan digunakan
5. Klik `Continue to Summary`
6. Klik `Create Token`
7. Copy dan simpan API Key (hanya ditampilkan sekali)

### Jika Proses Terhenti / Disconnect

```bash
screen -r setup
```

### Lihat Log Instalasi

```bash
cat /root/syslog.log
```

---

## 📟 Perintah Menu

### Menu Utama

```
┌─────────────────────────────────────────────────┐
│          ⚡ VPN TUNNELING AUTOSCRIPT ⚡          │
│─────────────────────────────────────────────────│
│  [1]  SSH & OpenVPN Menu                        │
│  [2]  VMess Menu                                │
│  [3]  VLESS Menu                                │
│  [4]  Trojan Menu                               │
│  [5]  Shadowsocks Menu                          │
│  [6]  Socks Menu                                │
│  [7]  Hysteria2 Menu                            │
│  [8]  Trojan-Go Menu                            │
│  [9]  SoftEther VPN Menu                        │
│  [10] Cloudflare WARP Menu                      │
│  [11] System & Server Settings                  │
│  [12] Backup & Restore                          │
│  [13] API & Bot Menu                            │
│  [14] Reboot VPS                                │
│  [15] Running Services                          │
│  [16] Speedtest                                 │
│  [17] vnStat Bandwidth                          │
│  [18] Script Info                               │
│  [0]  Exit                                      │
└─────────────────────────────────────────────────┘
```

### Sub-Menu Tiap Protocol

```
┌─────────────────────────────────────────────────┐
│          ⚡ PROTOCOL MANAGEMENT ⚡               │
│─────────────────────────────────────────────────│
│  [1]  Create Account                            │
│  [2]  Bulk Create Accounts                      │
│  [3]  Delete Account                            │
│  [4]  Extend/Renew Account                      │
│  [5]  Check User Login                          │
│  [6]  User Details                              │
│  [7]  Lock Account                              │
│  [8]  Unlock Account                            │
│  [9]  Limit IP Login                            │
│  [10] Limit Quota                               │
│  [11] Ban Account                               │
│  [12] Unban Account                             │
│  [13] Recover Expired                           │
│  [14] List All Members                          │
│  [0]  Back to Main Menu                         │
└─────────────────────────────────────────────────┘
```

### Command Shortcut

| Command | Fungsi |
|---------|--------|
| `menu` | Menu utama |
| `menu-ssh` | Menu SSH & OpenVPN |
| `menu-vmess` | Menu VMess |
| `menu-vless` | Menu VLESS |
| `menu-trojan` | Menu Trojan |
| `menu-shadowsocks` | Menu Shadowsocks |
| `menu-socks` | Menu Socks |
| `menu-hysteria2` | Menu Hysteria2 |
| `menu-trojan-go` | Menu Trojan-Go |
| `menu-openvpn` | Menu OpenVPN |
| `menu-softether` | Menu SoftEther |
| `menu-warp` | Menu Cloudflare WARP |
| `menu-backup` | Menu backup & restore |
| `menu-api` | Menu API |
| `menu-bot` | Menu Telegram Bot |
| `menu-system` | Menu System settings |
| `running` | Lihat service berjalan |
| `speedtest` | Jalankan speedtest |
| `vnstat` | Monitor bandwidth |

---

## 🤖 REST API

Script ini dilengkapi dengan **REST API** yang berjalan pada **port 9000** untuk memungkinkan integrasi dengan:
- 🤖 **Bot Telegram**
- 📊 **Web Panel / Dashboard**
- 📱 **Aplikasi Mobile**
- 🔄 **Automation Tools**
- 🛒 **E-commerce / Seller Panel**

### Daftar Endpoint

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| `POST` | `/api/ssh/create` | Buat akun SSH |
| `POST` | `/api/vmess/create` | Buat akun VMess |
| `POST` | `/api/vless/create` | Buat akun VLESS |
| `POST` | `/api/trojan/create` | Buat akun Trojan |
| `POST` | `/api/shadowsocks/create` | Buat akun Shadowsocks |
| `POST` | `/api/socks/create` | Buat akun Socks |
| `POST` | `/api/hysteria2/create` | Buat akun Hysteria2 |
| `POST` | `/api/trojan-go/create` | Buat akun Trojan-Go |
| `DELETE` | `/api/{protocol}/delete` | Hapus akun |
| `GET` | `/api/{protocol}/list` | List semua akun |
| `GET` | `/api/{protocol}/detail/{user}` | Detail akun |
| `PUT` | `/api/{protocol}/renew` | Perpanjang akun |
| `PUT` | `/api/{protocol}/lock` | Lock akun |
| `PUT` | `/api/{protocol}/unlock` | Unlock akun |
| `PUT` | `/api/{protocol}/ban` | Ban akun |
| `PUT` | `/api/{protocol}/unban` | Unban akun |
| `PUT` | `/api/{protocol}/limit-ip` | Set limit IP |
| `PUT` | `/api/{protocol}/limit-quota` | Set limit quota |
| `GET` | `/api/server/status` | Status server |
| `GET` | `/api/server/bandwidth` | Bandwidth stats |
| `GET` | `/api/server/running` | Running services |
| `POST` | `/api/backup` | Backup ke cloud |
| `POST` | `/api/restore` | Restore dari cloud |
| `GET` | `/api/subscription/{user}` | Get subscription link |
| `GET` | `/api/clash/{user}` | Get Clash config |
| `POST` | `/api/server/reboot` | Reboot server |

### Contoh Request — Buat Akun VMess

```bash
curl -X POST http://your-server:9000/api/vmess/create \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "username": "user01",
    "exp": 30,
    "quota": 100,
    "ip_limit": 2
  }'
```

### Contoh Response

```json
{
  "status": "success",
  "data": {
    "username": "user01",
    "protocol": "vmess",
    "uuid": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "expired": "2026-04-09",
    "quota": "100 GB",
    "ip_limit": 2,
    "port_tls": 443,
    "port_nontls": 80,
    "path_ws": "/vmessws",
    "path_httpupgrade": "/vmess-httpupgrade",
    "service_name_grpc": "vmess-grpc",
    "link_tls": "vmess://...",
    "link_nontls": "vmess://...",
    "link_grpc": "vmess://...",
    "link_httpupgrade": "vmess://...",
    "subscription": "https://your-server:9000/api/subscription/user01",
    "clash_config": "https://your-server:9000/api/clash/user01"
  }
}
```

> 📖 **Dokumentasi lengkap API** tersedia setelah instalasi via perintah `menu-api` atau akses `http://your-server:9000/docs`

---

## ⚙️ Konfigurasi Lanjutan

### File Konfigurasi Utama

| File | Lokasi | Deskripsi |
|------|--------|-----------|
| Xray Config | `/etc/xray/config.json` | Konfigurasi multi-protocol Xray |
| Hysteria2 Config | `/etc/hysteria2/config.yaml` | Konfigurasi Hysteria2 |
| Trojan-Go Config | `/etc/trojan-go/config.json` | Konfigurasi Trojan-Go |
| Nginx Config | `/etc/nginx/conf.d/xray.conf` | Reverse proxy configuration |
| HAProxy Config | `/etc/haproxy/haproxy.cfg` | Load balancer configuration |
| OpenVPN TCP | `/etc/openvpn/server-tcp.conf` | OpenVPN TCP config |
| OpenVPN UDP | `/etc/openvpn/server-udp.conf` | OpenVPN UDP config |
| SoftEther Config | `/etc/softether/vpn_server.config` | SoftEther VPN config |
| WARP Config | `/etc/warp/warp.conf` | Cloudflare WARP config |
| SSL Certificate | `/etc/xray/xray.crt` | SSL certificate file |
| SSL Key | `/etc/xray/xray.key` | SSL private key file |
| Domain Config | `/etc/xray/domain` | File domain aktif |
| Cloudflare Config | `/etc/xray/cloudflare` | Cloudflare API credentials |
| Rclone Config | `~/.config/rclone/rclone.conf` | Rclone backup configuration |
| Stunnel Config | `/etc/stunnel/stunnel.conf` | SSL tunnel config |
| Squid Config | `/etc/squid/squid.conf` | HTTP proxy config |
| Fail2ban Config | `/etc/fail2ban/jail.local` | Intrusion prevention |
| Banner | `/etc/banner` | SSH/Dropbear banner |

### Environment Variables

```bash
# Domain & SSL
DOMAIN="vpn.example.com"
CF_EMAIL="user@example.com"
CF_API_KEY="your-cloudflare-api-key"
CF_ZONE_ID="your-zone-id"

# API Configuration
API_PORT=9000
API_KEY="your-secure-api-key"

# Telegram Bot
BOT_TOKEN="your-telegram-bot-token"
ADMIN_ID="your-telegram-admin-id"

# AWS CloudFront (Optional)
AWS_ACCESS_KEY_ID="your-aws-access-key"
AWS_SECRET_ACCESS_KEY="your-aws-secret-key"

# Timezone
TIMEZONE="Asia/Jakarta"

# Swap
SWAP_SIZE="1G"  # atau "2G"
```

### Tutorial Konfigurasi

#### Auto Reboot

```bash
# Set auto reboot setiap jam 04:00
crontab -l > /tmp/cron.txt
sed -i "/reboot$/d" /tmp/cron.txt
echo -e "\n""0 4 * * * ""$(which reboot)" >> /tmp/cron.txt
crontab /tmp/cron.txt
rm -rf /tmp/cron.txt

# Batalkan auto reboot
crontab -l > /tmp/cron.txt
sed -i "/reboot$/d" /tmp/cron.txt
crontab /tmp/cron.txt
rm -rf /tmp/cron.txt
```

#### Ganti SSH WS Dropbear → OpenSSH

```bash
nano /usr/local/bin/sshws
# Ganti: DEFAULT_HOST = '127.0.0.1:143'
# Menjadi: DEFAULT_HOST = '127.0.0.1:22'
# Lalu reboot VPS
```

#### Ganti SSH Stunnel Dropbear → OpenSSH

```bash
nano /etc/stunnel/server.conf
# Cari bagian [ssh]:
#   [ssh]
#   accept = 446
#   connect = 127.0.0.1:143
# Ganti port 143 (Dropbear) menjadi 22 (OpenSSH):
#   connect = 127.0.0.1:22
systemctl restart stunnel@server
```

#### Disable VPNRay Prefill

```bash
echo 'disable' > /etc/vpnray/vpnray-prefill
# Untuk membatalkan:
rm -rf /etc/vpnray/vpnray-prefill
```

#### Disable Clash Config Generation

```bash
echo 'disable' > /etc/vpnray/vpnray-clash
# Untuk membatalkan:
rm -rf /etc/vpnray/vpnray-clash
```

#### Disable VPNRay Coloring Text

```bash
echo 'disable' > /etc/vpnray/vpnray-color
# Untuk membatalkan:
rm -rf /etc/vpnray/vpnray-color
```

#### Lihat Password SoftEther VPN

```bash
source /etc/softether/params && echo "${MYPASS}"
```

---

## ❓ Troubleshooting / FAQ

<details>
<summary><b>Q: Instalasi gagal / terhenti di tengah jalan?</b></summary>

Jangan masukkan kembali perintah instalasi. Gunakan:
```bash
screen -r setup
```
Lihat log instalasi:
```bash
cat /root/syslog.log
```
</details>

<details>
<summary><b>Q: Domain gagal pointing ke Cloudflare?</b></summary>

Cloudflare telah menurunkan limit DNS Record per domain dari 1000 menjadi 200. Solusi:
1. **Donasikan domain** ke pool bersama via Cloudflare Nameservers
2. **Gunakan API Key pribadi** dari akun Cloudflare sendiri (lihat bagian instalasi)
</details>

<details>
<summary><b>Q: Port 443 hanya bisa diakses oleh SSH Stunnel?</b></summary>

Jika mengganti port Stunnel ke 443, semua layanan lain yang menggunakan port 443 via Nginx (663) akan kehilangan akses. Gunakan hanya jika yakin hanya memakai port 443 SSL untuk SSH Stunnel saja.
</details>

<details>
<summary><b>Q: Bagaimana cara backup ke Google Drive?</b></summary>

Jalankan `menu-backup`, pilih Setup Rclone, ikuti instruksi untuk OAuth Google Drive. Setelah setup, backup bisa dilakukan otomatis atau manual dari menu.
</details>

<details>
<summary><b>Q: VPS CPU usage tinggi?</b></summary>

Script ini dirancang lightweight (2-3% CPU idle). Jika CPU tinggi:
1. Cek jumlah akun aktif dan koneksi bersamaan
2. Pastikan service on demand aktif
3. Pertimbangkan upgrade RAM/CPU VPS
</details>

<details>
<summary><b>Q: Bagaimana cara integrasi Telegram Bot?</b></summary>

1. Buat bot via @BotFather di Telegram
2. Dapatkan Bot Token
3. Jalankan `menu-bot`, masukkan Bot Token dan Admin ID
4. Bot siap digunakan untuk remote management
</details>

---

## 📚 Referensi Repository

Script ini dikembangkan dengan referensi dan inspirasi dari repository-repository open source berikut:

| Repository | Deskripsi |
|------------|-----------|
| [XTLS/Xray-core](https://github.com/XTLS/Xray-core) | Core engine Xray proxy |
| [XTLS/Xray-install](https://github.com/XTLS/Xray-install) | Official Xray installer |
| [apernet/hysteria](https://github.com/apernet/hysteria) | Hysteria2 protocol engine |
| [p4gefau1t/trojan-go](https://github.com/p4gefau1t/trojan-go) | Trojan-Go engine |
| [SoftEtherVPN/SoftEtherVPN](https://github.com/SoftEtherVPN/SoftEtherVPN) | SoftEther VPN server |
| [mack-a/v2ray-agent](https://github.com/mack-a/v2ray-agent) | 8-in-1 Xray/Hysteria2/sing-box script |
| [FN-Rerechan02/Autoscript](https://github.com/FN-Rerechan02/Autoscript) | AIO VPN (SSH, Xray, UDP, OHP, Argo) |
| [GegeDevs/sshvpn-script](https://github.com/GegeDevs/sshvpn-script) | SSH
