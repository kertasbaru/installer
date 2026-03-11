<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?font=Fira+Code&weight=700&size=28&pause=1000&color=00F7FF&center=true&vCenter=true&width=600&lines=⚡+VPN+TUNNELING+AUTOSCRIPT+⚡;All-In-One+Installer+for+VPS" alt="VPN Tunneling Autoscript">
</p>

<h1 align="center">🚀 VPN Tunneling AutoScript Installer</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Version-2.0.0-blue?style=for-the-badge" alt="Version">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">
  <img src="https://img.shields.io/badge/Status-Production--Ready-brightgreen?style=for-the-badge" alt="Status">
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

> 📄 Lihat file [`.env.example`](.env.example) untuk template lengkap environment variables.

```bash
# Domain & SSL
DOMAIN="vpn-wuzzstore.my.id"
CF_EMAIL="wuzzstore04@gmail.com"
CF_API_KEY="your-cloudflare-global-api-key"
CF_ZONE_ID="your-cloudflare-zone-id"

# API Configuration
API_PORT=9000
API_KEY="your-api-key-hex-string"

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

**Cara menggunakan:**

```bash
cp .env.example .env
nano .env  # Edit sesuai konfigurasi Anda
source .env
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

### Core Engine & Protocol

| Repository | Deskripsi |
|------------|-----------|
| [XTLS/Xray-core](https://github.com/XTLS/Xray-core) | Core engine Xray proxy |
| [XTLS/Xray-install](https://github.com/XTLS/Xray-install) | Official Xray installer |
| [apernet/hysteria](https://github.com/apernet/hysteria) | Hysteria2 protocol engine |
| [p4gefau1t/trojan-go](https://github.com/p4gefau1t/trojan-go) | Trojan-Go engine |
| [SoftEtherVPN/SoftEtherVPN](https://github.com/SoftEtherVPN/SoftEtherVPN) | SoftEther VPN server |
| [v2fly/v2ray-core](https://github.com/v2fly/v2ray-core) | V2Ray core (referensi protokol) |

### Installer & Script Referensi

| Repository | Deskripsi |
|------------|-----------|
| [mack-a/v2ray-agent](https://github.com/mack-a/v2ray-agent) | 8-in-1 Xray/Hysteria2/sing-box script |
| [FN-Rerechan02/Autoscript](https://github.com/FN-Rerechan02/Autoscript) | AIO VPN (SSH, Xray, UDP, OHP, Argo) |
| [GegeDevs/sshvpn-script](https://github.com/GegeDevs/sshvpn-script) | SSH VPN script |

### Tools & Dependency

| Repository | Deskripsi |
|------------|-----------|
| [acmesh-official/acme.sh](https://github.com/acmesh-official/acme.sh) | SSL certificate management |
| [rclone/rclone](https://github.com/rclone/rclone) | Cloud storage sync (backup/restore) |
| [cloudflare/cloudflare-go](https://github.com/cloudflare/cloudflare-go) | Cloudflare API reference |
| [fail2ban/fail2ban](https://github.com/fail2ban/fail2ban) | Intrusion prevention system |
| [vergoh/vnstat](https://github.com/vergoh/vnstat) | Network traffic monitoring |

### Dokumentasi & Spesifikasi

| Sumber | Deskripsi |
|--------|-----------|
| [Xray Documentation](https://xtls.github.io/) | Dokumentasi resmi Xray-core |
| [Hysteria2 Documentation](https://v2.hysteria.network/) | Dokumentasi resmi Hysteria2 |
| [Cloudflare API v4](https://developers.cloudflare.com/api/) | Referensi API Cloudflare |
| [Telegram Bot API](https://core.telegram.org/bots/api) | Referensi API Telegram Bot |

---

## 🗺️ Roadmap

Roadmap pengembangan script installer dari tahap awal hingga production-ready.

### Status Keseluruhan

```
████████████████████████████████████████ 100%  (Tahap 1-10 selesai)
```

### Overview Tahap

| Tahap | Nama | Status | Script | Deskripsi |
|-------|------|--------|--------|-----------|
| 1 | Update Sistem & Reboot | ✅ Selesai | `setup.sh` | Validasi OS, update sistem, reboot |
| 2 | Install Dependencies & Setup | ✅ Selesai | `install.sh` | Instalasi paket, disable IPv6, setup direktori |
| 3 | Domain, SSL, Nginx & Xray-core | ✅ Selesai | `setup-domain.sh` | Domain, SSL, reverse proxy, multi-protocol Xray |
| 4 | SSH Tunneling, HAProxy & Services | ✅ Selesai | `setup-ssh.sh` | Dropbear, Stunnel, HAProxy, Squid, BadVPN, OHP |
| 5 | Protokol Tambahan | ✅ Selesai | `setup-protocol.sh` | Hysteria2, Trojan-Go, OpenVPN, SoftEther, WARP |
| 6 | Manajemen Akun & User | ✅ Selesai | `setup-account.sh` | CRUD akun per protokol, limit IP/quota, lock/ban |
| 7 | Menu Sistem & CLI Dashboard | ✅ Selesai | `setup-menu.sh` | Menu utama, sub-menu protokol, command shortcut |
| 8 | REST API & Bot Integrasi | ✅ Selesai | `setup-api.sh` | REST API port 9000, Telegram Bot, webhook |
| 9 | Monitoring, Backup & Keamanan | ✅ Selesai | `setup-monitor.sh` | vnStat, Fail2ban lanjutan, Rclone, web panel |
| 10 | Finalisasi & Produksi | ✅ Selesai | `setup-final.sh` | Integrasi, optimasi, auto-installer tunggal |

---

### Tahap 1: Update Sistem & Reboot ✅

> **Script:** `setup.sh` (283 baris) — **SELESAI**

Persiapan awal server: validasi environment dan update sistem operasi.

**Komponen yang diimplementasikan:**

- [x] Validasi root access
- [x] Validasi OS (Ubuntu 20.04/22.04/24.04, Debian 10/11/12)
- [x] Validasi arsitektur (x86_64 only)
- [x] Validasi virtualisasi (KVM/Xen, tolak OpenVZ/LXC)
- [x] Tambah group `dip` (PPP/networking)
- [x] `apt-get update` dengan `--allow-releaseinfo-change`
- [x] Reinstall GRUB bootloader
- [x] `apt-get upgrade` dengan `--fix-missing`
- [x] Update GRUB configuration
- [x] Logging ke `/root/syslog.log`
- [x] System reboot otomatis

**Test:** `tests/test_setup.sh` — 30+ unit test ✅

---

### Tahap 2: Install Dependencies & Setup ✅

> **Script:** `install.sh` (428 baris) — **SELESAI**

Instalasi paket-paket dasar dan persiapan struktur direktori.

**Komponen yang diimplementasikan:**

- [x] Disable IPv6 global (persistent via `sysctl.d`)
- [x] Install 12 dependencies: `whois bzip2 gzip coreutils wget screen nscd curl tmux gnupg perl dnsutils`
- [x] Verifikasi paket kritikal (wget, curl, screen, tmux)
- [x] Setup timezone Asia/Jakarta (GMT+7)
- [x] Buat 13 direktori konfigurasi (`/etc/xray`, `/etc/hysteria2`, `/etc/trojan-go`, `/etc/nginx/conf.d`, `/etc/haproxy`, `/etc/openvpn`, `/etc/softether`, `/etc/stunnel`, `/etc/squid`, `/etc/fail2ban`, `/etc/warp`, `/etc/cron.d`, `/etc/vnstat`)
- [x] Buat 3 direktori data (`/home/vps/public_html`, `/home/vps/backup`, `~/.config/rclone`)
- [x] Simpan Cloudflare API Key (opsional, ke `/etc/xray/cloudflare`)
- [x] Buat file domain placeholder (`/etc/xray/domain`)
- [x] Logging lengkap ke `/root/syslog.log`

**Test:** `tests/test_install.sh` — 65+ unit test ✅

---

### Tahap 3: Domain, SSL, Nginx & Xray-core ✅

> **Script:** `setup-domain.sh` (1.437 baris) — **SELESAI**

Setup domain, sertifikat SSL, reverse proxy Nginx, dan instalasi Xray-core multi-protocol.

**Komponen yang diimplementasikan:**

- [x] Validasi format domain (regex)
- [x] Validasi DNS pointing (dig, bandingkan IP VPS)
- [x] Auto-pointing domain via Cloudflare API v4
- [x] Deteksi IP publik VPS (fallback: ifconfig.me → icanhazip.com)
- [x] Install acme.sh + socat
- [x] Issue SSL certificate (2 metode: Cloudflare DNS API → Standalone HTTP)
- [x] Install & konfigurasi Nginx reverse proxy
- [x] TLS termination di Nginx
- [x] WebSocket proxy (HTTP/1.1 upgrade)
- [x] gRPC proxy (HTTP/2)
- [x] HTTP Upgrade support
- [x] Install Xray-core binary
- [x] Konfigurasi multi-protocol Xray (config.json):
  - [x] VMess: WS TLS, WS Non-TLS, gRPC TLS, HTTP Upgrade
  - [x] VLESS: WS TLS, WS Non-TLS, gRPC TLS, HTTP Upgrade
  - [x] Trojan: WS TLS, WS Non-TLS, gRPC TLS, TCP TLS, HTTP Upgrade
  - [x] Shadowsocks: WS TLS, WS Non-TLS, gRPC TLS, TCP Non-TLS
  - [x] Socks: WS TLS, WS Non-TLS, gRPC TLS, TCP Non-TLS
- [x] Buat systemd service untuk Xray
- [x] Backend port routing (10001-10004)
- [x] Default web page (index.html)

**Test:** `tests/test_setup_domain.sh` — 100+ unit test ✅

---

### Tahap 4: SSH Tunneling, HAProxy & Services ✅

> **Script:** `setup-ssh.sh` (1.240 baris) — **SELESAI**

Instalasi SSH tunneling, load balancer, proxy services, dan UDP gateway.

**Komponen yang diimplementasikan:**

- [x] Validasi Tahap 3 selesai (cek domain, SSL, Nginx, Xray)
- [x] Install & konfigurasi Dropbear SSH (port 80, 143, 443)
- [x] Generate Dropbear host keys (RSA, ECDSA)
- [x] Install & konfigurasi Stunnel4 SSL tunnel (port 446 SSH, port 445 SSH-WS)
- [x] Buat SSH WebSocket handler (Python3, port 8880)
- [x] Install & konfigurasi HAProxy load balancer (port 80, 443)
- [x] Konfigurasi HAProxy SNI routing dan backend
- [x] Install & konfigurasi Squid HTTP proxy (port 3128, 8080)
- [x] Install BadVPN/UDPGW (port 7100-7900, 9 port)
- [x] Install OHP — Open HTTP Puncher (SSH 2083, Dropbear 2084, OpenVPN 2087)
- [x] Setup SSH/Dropbear banner
- [x] Setup cronjob auto-clear-log (setiap 10 menit)
- [x] Setup cronjob auto-delete-expired (template)
- [x] Buat systemd service untuk semua komponen

**Test:** `tests/test_setup_ssh.sh` — 120+ unit test ✅

---

### Tahap 5: Protokol Tambahan ✅

> **Script:** `setup-protocol.sh` (1.460 baris) — **SELESAI**

Instalasi protokol VPN/tunnel tambahan di luar Xray-core.

**Komponen yang diimplementasikan:**

- [x] **Hysteria2** — Install binary dari GitHub, config QUIC/UDP (port 443), systemd service
- [x] **Trojan-Go** — Install binary dari GitHub, config WebSocket TLS (port 443), systemd service
- [x] **OpenVPN** — Install & konfigurasi server TCP (port 1194, 2294) dan UDP (port 2200, 2295)
- [x] **OpenVPN Stunnel** — TLS tunnel untuk OpenVPN (port 2296)
- [x] **OpenVPN PKI** — EasyRSA setup, generate CA/server certificate
- [x] **OpenVPN NAT** — IP forwarding dan masquerade untuk VPN subnet
- [x] **SoftEther VPN** — Install & build dari source, multi-protocol server (SSTP 4433, L2TP/IPSec 500/1701/4500, OpenVPN 1194/1195)
- [x] **Cloudflare WARP** — Install via repository/deb, konfigurasi proxy mode (port 51820)
- [x] **SlowDNS/DNSTT** — Install & konfigurasi DNS tunneling (port 53, 5300, 2222), generate keypair
- [x] **UDP Custom** — Handler UDP tunneling custom port (1-65535), config JSON
- [x] Buat systemd service untuk setiap protokol
- [x] Integrasi SSL certificate yang sudah ada (symlink, permission)

**Test:** `tests/test_setup_protocol.sh` — 163 unit test ✅

---

### Tahap 6: Manajemen Akun & User ✅

> **Script:** `setup-account.sh` — **2.568 baris** | **179 tests**

Script manajemen akun untuk semua protokol. Setiap protokol memiliki operasi CRUD lengkap.

**Komponen yang diimplementasikan:**

- [x] **Akun SSH** — Create, delete, extend, lock/unlock, ban/unban, cek login, limit IP
- [x] **Akun VMess** — Create (UUID), delete, extend, lock/unlock, ban/unban, limit IP, limit quota
- [x] **Akun VLESS** — Create (UUID), delete, extend, lock/unlock, ban/unban, limit IP, limit quota
- [x] **Akun Trojan** — Create (password), delete, extend, lock/unlock, ban/unban, limit IP, limit quota
- [x] **Akun Shadowsocks** — Create (password), delete, extend, lock/unlock, ban/unban, limit IP, limit quota
- [x] **Akun Socks** — Create (user/pass), delete, extend, lock/unlock, ban/unban, limit IP, limit quota
- [x] **Akun Hysteria2** — Create, delete, extend, lock/unlock, ban/unban, limit IP, limit quota
- [x] **Akun Trojan-Go** — Create, delete, extend, lock/unlock, ban/unban
- [x] **Bulk Create** — Buat banyak akun sekaligus (semua protokol)
- [x] **Recover Expired** — Pulihkan akun expired (Xray protocols)
- [x] **Expiry Checker** — Script `xp-ssh` dan `xp-xray` untuk cek masa aktif
- [x] **Auto Delete Expired** — Implementasi logika hapus akun expired (cronjob)
- [x] **Auto Disconnect Duplicate** — Disconnect session duplikat otomatis
- [x] **Bandwidth Per User** — Monitoring penggunaan bandwidth per akun
- [x] **Subscription Link Generator** — Generate link subscription untuk client app
- [x] **Clash Config Generator** — Auto generate Clash config per user
- [x] **VPNRay JSON Converter** — Converter config untuk custom HTTP

**Test:** `tests/test_setup_account.sh`

---

### Tahap 7: Menu Sistem & CLI Dashboard ✅

> **Script:** `setup-menu.sh` — **2.271 baris** | **236 tests**

Instalasi menu interaktif CLI sebagai antarmuka utama pengguna.

**Komponen yang diimplementasikan:**

- [x] **Menu Utama** (`/usr/local/bin/menu`) — Dashboard dengan box drawing dan warna
- [x] **Menu SSH & OpenVPN** (`menu-ssh`) — Manajemen akun SSH, OpenVPN
- [x] **Menu VMess** (`menu-vmess`) — Manajemen akun VMess
- [x] **Menu VLESS** (`menu-vless`) — Manajemen akun VLESS
- [x] **Menu Trojan** (`menu-trojan`) — Manajemen akun Trojan
- [x] **Menu Shadowsocks** (`menu-shadowsocks`) — Manajemen akun Shadowsocks
- [x] **Menu Socks** (`menu-socks`) — Manajemen akun Socks
- [x] **Menu Hysteria2** (`menu-hysteria2`) — Manajemen akun Hysteria2
- [x] **Menu Trojan-Go** (`menu-trojan-go`) — Manajemen akun Trojan-Go
- [x] **Menu SoftEther** (`menu-softether`) — Manajemen SoftEther VPN
- [x] **Menu WARP** (`menu-warp`) — Manajemen Cloudflare WARP
- [x] **Menu Backup** (`menu-backup`) — Backup & restore via Rclone
- [x] **Menu API** (`menu-api`) — Konfigurasi REST API
- [x] **Menu Bot** (`menu-bot`) — Konfigurasi Telegram Bot
- [x] **Menu System** (`menu-system`) — Settings sistem (reboot, timezone, banner, dll)
- [x] **Running Services** (`running`) — Cek status semua service
- [x] **Speedtest** (`speedtest`) — Speedtest by Ookla
- [x] **Bandwidth** (`vnstat`) — Monitor bandwidth
- [x] **Sub-Menu Protocol** — 14 operasi per protokol (create, delete, renew, lock, ban, dll)
- [x] **Auto-complete** — Registrasi command shortcut di `/usr/local/bin/`

**Test:** `tests/test_setup_menu.sh`

---

### Tahap 8: REST API & Bot Integrasi ✅

> **Script:** `setup-api.sh` (1917 baris) — **SELESAI**

REST API service dan integrasi Telegram Bot untuk remote management.

**Komponen yang diimplementasikan:**

- [x] **REST API Service** (port 9000) — Lightweight API server (socat-based)
- [x] **API Authentication** — Token-based auth (Authorization header)
- [x] **Endpoint Akun** (per protokol: SSH, VMess, VLESS, Trojan, SS, Socks, Hysteria2, Trojan-Go):
  - [x] `POST /api/{protocol}/create` — Buat akun
  - [x] `DELETE /api/{protocol}/delete` — Hapus akun
  - [x] `GET /api/{protocol}/list` — List semua akun
  - [x] `GET /api/{protocol}/detail/{user}` — Detail akun
  - [x] `PUT /api/{protocol}/renew` — Perpanjang akun
  - [x] `PUT /api/{protocol}/lock` — Lock akun
  - [x] `PUT /api/{protocol}/unlock` — Unlock akun
  - [x] `PUT /api/{protocol}/ban` — Ban akun
  - [x] `PUT /api/{protocol}/unban` — Unban akun
  - [x] `PUT /api/{protocol}/limit-ip` — Set limit IP
  - [x] `PUT /api/{protocol}/limit-quota` — Set limit quota
- [x] **Endpoint Server**:
  - [x] `GET /api/server/status` — Status server
  - [x] `GET /api/server/bandwidth` — Bandwidth stats
  - [x] `GET /api/server/running` — Running services
  - [x] `POST /api/server/reboot` — Reboot server
- [x] **Endpoint Utilitas**:
  - [x] `POST /api/backup` — Backup ke cloud
  - [x] `POST /api/restore` — Restore dari cloud
  - [x] `GET /api/subscription/{user}` — Get subscription link
  - [x] `GET /api/clash/{user}` — Get Clash config
- [x] **Telegram Bot Remote** — CRUD akun, reboot, info server via bot
- [x] **Telegram Bot Seller Panel** — Panel penjualan otomatis
- [x] **Telegram Bot Notification** — Notifikasi akun dibuat/expired/login
- [x] **Webhook Integration** — Webhook untuk event sistem
- [x] Buat systemd service untuk API server

**Test:** `tests/test_setup_api.sh`

---

### Tahap 9: Monitoring, Backup & Keamanan ✅

> **Script:** `setup-monitor.sh` (1749 baris) — **SELESAI**

Monitoring bandwidth, backup otomatis, dan konfigurasi keamanan lanjutan.

**Komponen yang diimplementasikan:**

- [x] **vnStat Monitoring** — Install & konfigurasi vnStat, web interface (port 8899)
- [x] **Fail2ban Lanjutan** — Konfigurasi jail SSH, Dropbear, Xray brute-force protection
- [x] **Firewall UFW/iptables** — Auto konfigurasi firewall rules
- [x] **Rclone Backup/Restore** — Setup Rclone, integrasi Google Drive/Dropbox/OneDrive
- [x] **Auto Backup** — Cronjob backup otomatis
- [x] **HideSSH Web Panel** — Web panel terintegrasi
- [x] **Webmin** — Web-based system admin panel
- [x] **SWAP Memory** — Otomatis setup swap file (1GB/2GB selectable)
- [x] **Auto Block Ads Indo** — Block iklan Indonesia via hosts file
- [x] **Domain Blacklist** — Block domain tertentu via Xray routing
- [x] **BT Download Block** — Blokir P2P/BitTorrent
- [x] **IP Whitelist/Blacklist** — Manajemen IP akses
- [x] **Service on Demand** — Service hanya berjalan jika ada akun aktif
- [x] **CPU & Memory Monitoring** — Monitor real-time penggunaan resource
- [x] **Log Rotation** — Konfigurasi logrotate untuk semua service

**Test:** `tests/test_setup_monitor.sh`

---

### Tahap 10: Finalisasi & Produksi ✅

> **Script:** `setup-final.sh` — **SELESAI**

Integrasi semua komponen, optimasi, dan pembuatan auto-installer tunggal.

**Komponen yang diimplementasikan:**

- [x] **Auto-Installer Tunggal** — Script tunggal yang menjalankan semua tahap secara berurutan (`vpnray-install`)
- [x] **Integrasi Antar Tahap** — Verifikasi setiap tahap selesai sebelum lanjut
- [x] **Error Recovery** — Resume dari tahap terakhir jika gagal/disconnect (`--resume`, `--from`)
- [x] **Post-Install Verification** — Cek semua service berjalan setelah instalasi (`vpnray-verify`)
- [x] **System Info Display** — Tampilkan info lengkap VPS setelah install (`vpnray-sysinfo`)
- [x] **Uninstall Script** — Script untuk membersihkan semua komponen (`vpnray-uninstall`)
- [x] **Rebuild Menu** — Rebuild VPS dari menu tanpa reinstall OS (`vpnray-rebuild`)
- [x] **Performance Optimization** — Tuning kernel, network, dan service parameters (`vpnray-perftuning`)
- [x] **Security Hardening** — Hardening SSH, disable unnecessary services (`vpnray-hardening`)
- [x] **Documentation Generator** — Auto-generate dokumentasi berdasarkan konfigurasi aktif (`vpnray-docgen`)
- [x] **Version Management** — Update checker dan auto-update script (`vpnray-update`)
- [x] **Full Integration Testing** — End-to-end test semua komponen (`vpnray-test`)
- [x] **Production Checklist** — Checklist verifikasi sebelum produksi (`vpnray-checklist`)

**Test:** `tests/test_setup_final.sh`

---

### Timeline Estimasi

```
Tahap 1-7  : ████████████████████████████████  100%  ✅ Selesai (Infrastruktur + Protokol + Akun + Menu)
Tahap 8    : ████████████████████████████████  100%  ✅ API & Bot
Tahap 9    : ████████████████████████████████  100%  ✅ Monitoring & Security
Tahap 10   : ████████████████████████████████  100%  ✅ Finalisasi & Produksi
```

| Fase | Tahap | Estimasi | Prioritas |
|------|-------|----------|-----------|
| **Fase 1 — Infrastruktur** | Tahap 1-4 | ✅ Selesai | — |
| **Fase 2 — Ekspansi Protokol** | Tahap 5 | ✅ Selesai | — |
| **Fase 3 — User Experience** | Tahap 6-7 | ✅ Selesai | — |
| **Fase 4 — Integrasi** | Tahap 8 | ✅ Selesai | — |
| **Fase 5 — Hardening** | Tahap 9-10 | ✅ Selesai | — |

> **Status:** ✅ Semua tahap (1-10) telah selesai — Production-Ready!

---

## 📝 Changelog

### v1.0.0 — Tahap 10 (Current)
- ✅ Auto-Installer Tunggal — Script `vpnray-install` menjalankan semua tahap (1-9) berurutan
- ✅ Integrasi Antar Tahap — Verifikasi tiap tahap selesai sebelum lanjut ke tahap berikutnya
- ✅ Error Recovery — Resume dari tahap terakhir via `--resume`, mulai dari tahap tertentu via `--from`
- ✅ Post-Install Verification — Script `vpnray-verify` cek services, ports, dan critical files
- ✅ System Info Display — Script `vpnray-sysinfo` tampilkan info lengkap VPS (IP, domain, port, hardware)
- ✅ Uninstall Script — Script `vpnray-uninstall` membersihkan semua komponen dengan konfirmasi safety
- ✅ Rebuild Menu — Script `vpnray-rebuild` rebuild Xray/Nginx/HAProxy/SSL/Services/Akun/Menu
- ✅ Performance Optimization — Script `vpnray-perftuning` tuning BBR, TCP, buffer, file descriptors
- ✅ Security Hardening — Script `vpnray-hardening` hardening SSH, kernel security, file permissions
- ✅ Documentation Generator — Script `vpnray-docgen` auto-generate docs dari konfigurasi aktif
- ✅ Version Management — Script `vpnray-update` update checker dan auto-update
- ✅ Full Integration Testing — Script `vpnray-test` end-to-end test semua komponen
- ✅ Production Checklist — Script `vpnray-checklist` verifikasi 25+ item sebelum produksi
- ✅ State Manager — Script `vpnray-state` untuk tracking install state (get/set/clear)

### v0.9.0 — Tahap 9
- ✅ vnStat Monitoring — Install & konfigurasi, web interface (port 8899)
- ✅ Fail2ban Lanjutan — Jail SSH, Dropbear, Xray auth, nginx, recidive
- ✅ Firewall UFW/iptables — Auto konfigurasi firewall rules (25+ port rules)
- ✅ Rclone Backup/Restore — Script backup/restore dengan cloud integration
- ✅ Auto Backup cronjob (harian jam 02:00)
- ✅ HideSSH Web Panel — Web panel terintegrasi
- ✅ Webmin — Install script untuk web-based admin panel
- ✅ SWAP Memory — Setup swap 1GB/2GB/off via vpnray-swap
- ✅ Auto Block Ads Indo — Block iklan Indonesia via hosts file
- ✅ Domain Blacklist — Block domain via Xray routing
- ✅ BT Download Block — Blokir P2P/BitTorrent via iptables
- ✅ IP Whitelist/Blacklist — Manajemen IP akses
- ✅ Service on Demand — Service hanya berjalan jika ada akun aktif (cronjob 5 menit)
- ✅ CPU & Memory Monitoring — Monitor real-time (vpnray-cpu-monitor, vpnray-mem-monitor, vpnray-resource-monitor)
- ✅ Log Rotation — Konfigurasi logrotate untuk semua service

### v0.8.0 — Tahap 8
- ✅ REST API Server (port 9000) — socat-based HTTP API server
- ✅ API Authentication — Token-based Bearer auth
- ✅ 11 endpoint akun per protokol (create, delete, list, detail, renew, lock, unlock, ban, unban, limit-ip, limit-quota)
- ✅ 8 protokol didukung (SSH, VMess, VLESS, Trojan, Shadowsocks, Socks, Hysteria2, Trojan-Go)
- ✅ Server endpoints (status, bandwidth, running, reboot)
- ✅ Utility endpoints (backup, restore, subscription, clash config)
- ✅ API Documentation endpoint (/api/docs)
- ✅ CORS support
- ✅ Telegram Bot Remote — Long-polling bot dengan /start, /status, /running, /list_*, /bandwidth, /reboot
- ✅ Telegram Bot Seller Panel — Trial & purchase panel
- ✅ Telegram Bot Notification — Event-based notifications
- ✅ Webhook Integration — Account & server event webhooks
- ✅ Systemd services (vpnray-api, vpnray-bot)

### v0.7.0 — Tahap 7
- ✅ Menu Utama (`menu`) — Dashboard interaktif dengan box drawing & server info
- ✅ 8 Protocol Sub-menus (SSH, VMess, VLESS, Trojan, Shadowsocks, Socks, Hysteria2, Trojan-Go)
- ✅ 14 operasi per protokol (create, bulk create, delete, extend, check login, details, lock, unlock, limit IP, limit quota, ban, unban, recover, list)
- ✅ Menu SoftEther VPN — Status, start, stop, restart, config
- ✅ Menu Cloudflare WARP — Enable, disable, status, mode
- ✅ Menu Backup — Backup, restore, Rclone setup, auto backup
- ✅ Menu API — Start, stop, restart, status, port config, API key
- ✅ Menu Telegram Bot — Token registration, start, stop, status, admin ID
- ✅ Menu System — Reboot, timezone, banner, auto reboot, clear log, memory, kernel
- ✅ Running Services script — Status check untuk 14+ services
- ✅ Speedtest script — Ookla speedtest wrapper
- ✅ Bandwidth script — vnstat wrapper
- ✅ Menu functions library (/etc/vpnray/menu-functions.sh)
- ✅ Command shortcuts registered di /usr/local/bin/
- ✅ Auto-menu on login via .profile

### v0.6.0 — Tahap 6
- ✅ SSH account management (create, delete, extend, lock/unlock, ban/unban, cek login, limit IP)
- ✅ VMess account management (UUID, CRUD, lock, ban, limit IP/quota)
- ✅ VLESS account management (UUID, CRUD, lock, ban, limit IP/quota)
- ✅ Trojan account management (password, CRUD, lock, ban, limit IP/quota)
- ✅ Shadowsocks account management (password + chacha20-ietf-poly1305, CRUD)
- ✅ Socks account management (user/pass, CRUD, lock, ban, limit IP/quota)
- ✅ Hysteria2 account management (YAML config, CRUD, limit IP/quota)
- ✅ Trojan-Go account management (JSON config, CRUD, lock/ban)
- ✅ Bulk create accounts (semua protokol, 1-1000 akun)
- ✅ Recover expired accounts (auto re-activate)
- ✅ Expiry checker scripts (xp-ssh, xp-xray)
- ✅ Auto delete expired accounts (cronjob harian)
- ✅ Auto disconnect duplicate sessions (cronjob 5 menit)
- ✅ Bandwidth per user monitoring (Xray API stats)
- ✅ Subscription link generator (vmess://, vless://, trojan://)
- ✅ Clash YAML config generator
- ✅ VPNRay JSON converter
- ✅ Utility scripts: limit-ip-ssh, limit-ip-xray, limit-quota-xray, lock-ssh, lock-xray
- ✅ Account data stored as JSON di /etc/vpnray/accounts/

### v0.5.0 — Tahap 5
- ✅ Hysteria2 QUIC/UDP (port 443) — binary dari apernet/hysteria
- ✅ Trojan-Go WebSocket TLS (port 443) — binary dari p4gefau1t/trojan-go
- ✅ OpenVPN TCP (port 1194, 2294) dan UDP (port 2200, 2295)
- ✅ OpenVPN Stunnel TLS (port 2296)
- ✅ OpenVPN PKI via EasyRSA
- ✅ SoftEther VPN Server (SSTP 4433, L2TP/IPSec, OpenVPN 1194/1195)
- ✅ Cloudflare WARP (port 51820)
- ✅ SlowDNS/DNSTT (port 53, 5300, 2222)
- ✅ UDP Custom handler (port 1-65535)
- ✅ SSL certificate integration untuk semua protokol
- ✅ Systemd service untuk setiap protokol

### v0.4.0 — Tahap 4
- ✅ Dropbear SSH multi-port (80, 143, 443)
- ✅ Stunnel4 SSL tunnel (port 446, 445)
- ✅ SSH WebSocket handler (Python3, port 8880)
- ✅ HAProxy load balancer (port 80, 443)
- ✅ Squid HTTP proxy (port 3128, 8080)
- ✅ BadVPN/UDPGW (port 7100-7900)
- ✅ OHP — Open HTTP Puncher (port 2083, 2084, 2087)
- ✅ SSH banner, cronjob templates

### v0.3.0 — Tahap 3
- ✅ Domain setup & DNS validation
- ✅ Auto-pointing domain via Cloudflare API
- ✅ SSL certificate via acme.sh (Cloudflare DNS + standalone)
- ✅ Nginx reverse proxy (WebSocket, gRPC, HTTP Upgrade)
- ✅ Xray-core multi-protocol (VMess, VLESS, Trojan, Shadowsocks, Socks)
- ✅ Systemd service management

### v0.2.0 — Tahap 2
- ✅ Disable IPv6 (persistent)
- ✅ 12 dependencies terinstall
- ✅ 16 direktori konfigurasi & data
- ✅ Timezone, Cloudflare API Key

### v0.1.0 — Tahap 1
- ✅ Validasi OS, arsitektur, virtualisasi
- ✅ System update & reboot

---

## 📄 Lisensi

```
MIT License

Copyright (c) 2024 kertasbaru

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
