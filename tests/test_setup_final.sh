#!/bin/bash
# ============================================================================
# Test suite untuk setup-final.sh — Tahap 10: Finalisasi & Produksi
# ============================================================================
# Menjalankan pengujian unit untuk fungsi-fungsi di setup-final.sh
# tanpa menjalankan operasi berbahaya (install/service management).
#
# Penggunaan:
#   chmod +x tests/test_setup_final.sh
#   ./tests/test_setup_final.sh
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/setup-final.sh"

PASS=0
FAIL=0
SKIP=0

# Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

assert_eq() {
    local test_name="$1"
    local expected="$2"
    local actual="$3"

    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}[PASS]${NC} $test_name"
        ((PASS++))
    else
        echo -e "${RED}[FAIL]${NC} $test_name"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        ((FAIL++))
    fi
}

assert_contains() {
    local test_name="$1"
    local needle="$2"
    local haystack="$3"

    if echo "$haystack" | grep -q "$needle"; then
        echo -e "${GREEN}[PASS]${NC} $test_name"
        ((PASS++))
    else
        echo -e "${RED}[FAIL]${NC} $test_name"
        echo "  Expected to contain: $needle"
        echo "  In: $haystack"
        ((FAIL++))
    fi
}

assert_not_empty() {
    local test_name="$1"
    local value="$2"

    if [[ -n "$value" ]]; then
        echo -e "${GREEN}[PASS]${NC} $test_name"
        ((PASS++))
    else
        echo -e "${RED}[FAIL]${NC} $test_name"
        echo "  Value was empty"
        ((FAIL++))
    fi
}

echo "=============================================="
echo "  Test Suite: setup-final.sh (Tahap 10)"
echo "=============================================="

# ===========================================================================
# Section 1: Script file verification
# ===========================================================================

echo ""
echo "--- Section 1: Script File Verification ---"

# ---- Test: Script file exists ----
assert_eq "Script file exists" "true" "$([[ -f "$SCRIPT_PATH" ]] && echo true || echo false)"

# ---- Test: Script is executable ----
assert_eq "Script is executable" "true" "$([[ -x "$SCRIPT_PATH" ]] && echo true || echo false)"

# ---- Test: Script has bash shebang ----
first_line=$(head -1 "$SCRIPT_PATH")
assert_eq "Script has bash shebang" "#!/bin/bash" "$first_line"

# ---- Test: Script passes syntax check ----
if bash -n "$SCRIPT_PATH" 2>/dev/null; then
    assert_eq "Script passes syntax check" "true" "true"
else
    assert_eq "Script passes syntax check" "true" "false"
fi

# ---- Test: Script file is not empty ----
line_count=$(wc -l < "$SCRIPT_PATH")
assert_eq "Script has significant content (>500 lines)" "true" "$([[ "$line_count" -gt 500 ]] && echo true || echo false)"

# ===========================================================================
# Section 2: Script structure and functions
# ===========================================================================

echo ""
echo "--- Section 2: Script Structure & Functions ---"

script_content=$(cat "$SCRIPT_PATH")

# ---- Test: Core utility functions ----
assert_contains "Has log() function" "^log()" "$script_content"
assert_contains "Has log_warn() function" "^log_warn()" "$script_content"
assert_contains "Has log_error() function" "^log_error()" "$script_content"
assert_contains "Has print_header() function" "^print_header()" "$script_content"

# ---- Test: Prerequisite check functions ----
assert_contains "Has check_root() function" "^check_root()" "$script_content"
assert_contains "Has check_os() function" "^check_os()" "$script_content"
assert_contains "Has check_arch() function" "^check_arch()" "$script_content"
assert_contains "Has check_virt() function" "^check_virt()" "$script_content"
assert_contains "Has check_previous_tahap() function" "^check_previous_tahap()" "$script_content"

# ---- Test: Core feature functions ----
assert_contains "Has create_auto_installer() function" "^create_auto_installer()" "$script_content"
assert_contains "Has setup_state_tracking() function" "^setup_state_tracking()" "$script_content"
assert_contains "Has create_post_install_verify() function" "^create_post_install_verify()" "$script_content"
assert_contains "Has create_sysinfo_script() function" "^create_sysinfo_script()" "$script_content"
assert_contains "Has create_uninstall_script() function" "^create_uninstall_script()" "$script_content"
assert_contains "Has create_rebuild_script() function" "^create_rebuild_script()" "$script_content"
assert_contains "Has create_perftuning_script() function" "^create_perftuning_script()" "$script_content"
assert_contains "Has create_hardening_script() function" "^create_hardening_script()" "$script_content"
assert_contains "Has create_docgen_script() function" "^create_docgen_script()" "$script_content"
assert_contains "Has create_update_script() function" "^create_update_script()" "$script_content"
assert_contains "Has create_integration_test() function" "^create_integration_test()" "$script_content"
assert_contains "Has create_checklist_script() function" "^create_checklist_script()" "$script_content"

# ---- Test: Performance & hardening inline functions ----
assert_contains "Has apply_performance_tuning() function" "^apply_performance_tuning()" "$script_content"
assert_contains "Has apply_security_hardening() function" "^apply_security_hardening()" "$script_content"

# ---- Test: Main function ----
assert_contains "Has main() function" "^main()" "$script_content"
assert_contains "Calls main at end" 'main "\$@"' "$script_content"

# ===========================================================================
# Section 3: Variable definitions
# ===========================================================================

echo ""
echo "--- Section 3: Variable Definitions ---"

# ---- Test: Color variables ----
assert_contains "Defines RED color" "^RED=" "$script_content"
assert_contains "Defines GREEN color" "^GREEN=" "$script_content"
assert_contains "Defines YELLOW color" "^YELLOW=" "$script_content"
assert_contains "Defines BLUE color" "^BLUE=" "$script_content"
assert_contains "Defines CYAN color" "^CYAN=" "$script_content"
assert_contains "Defines NC (reset)" "^NC=" "$script_content"

# ---- Test: Important path variables ----
assert_contains "Defines LOG_FILE" "^LOG_FILE=" "$script_content"
assert_contains "Defines DOMAIN_FILE" "^DOMAIN_FILE=" "$script_content"
assert_contains "Defines XRAY_CONFIG" "^XRAY_CONFIG=" "$script_content"
assert_contains "Defines ACCOUNT_DIR" "^ACCOUNT_DIR=" "$script_content"

# ---- Test: Version management variables ----
assert_contains "Defines SCRIPT_VERSION" "^SCRIPT_VERSION=" "$script_content"
assert_contains "Defines VERSION_FILE" "^VERSION_FILE=" "$script_content"
assert_contains "Defines UPDATE_CHECK_URL" "^UPDATE_CHECK_URL=" "$script_content"

# ---- Test: Script path variables ----
assert_contains "Defines AUTO_INSTALLER_SCRIPT" "^AUTO_INSTALLER_SCRIPT=" "$script_content"
assert_contains "Defines UNINSTALL_SCRIPT" "^UNINSTALL_SCRIPT=" "$script_content"
assert_contains "Defines REBUILD_SCRIPT" "^REBUILD_SCRIPT=" "$script_content"
assert_contains "Defines SYSINFO_SCRIPT" "^SYSINFO_SCRIPT=" "$script_content"
assert_contains "Defines PERFTUNING_SCRIPT" "^PERFTUNING_SCRIPT=" "$script_content"
assert_contains "Defines HARDENING_SCRIPT" "^HARDENING_SCRIPT=" "$script_content"
assert_contains "Defines DOCGEN_SCRIPT" "^DOCGEN_SCRIPT=" "$script_content"
assert_contains "Defines UPDATE_SCRIPT" "^UPDATE_SCRIPT=" "$script_content"
assert_contains "Defines INTEGRATION_TEST_SCRIPT" "^INTEGRATION_TEST_SCRIPT=" "$script_content"
assert_contains "Defines CHECKLIST_SCRIPT" "^CHECKLIST_SCRIPT=" "$script_content"

# ---- Test: State tracking ----
assert_contains "Defines STATE_DIR" "^STATE_DIR=" "$script_content"
assert_contains "Defines STATE_FILE" "^STATE_FILE=" "$script_content"

# ===========================================================================
# Section 4: Auto-Installer Tunggal contents
# ===========================================================================

echo ""
echo "--- Section 4: Auto-Installer Tunggal ---"

# ---- Test: Auto-installer heredoc features ----
assert_contains "Auto-installer supports --resume flag" "\-\-resume" "$script_content"
assert_contains "Auto-installer supports --from flag" "\-\-from" "$script_content"
assert_contains "Auto-installer supports --skip-reboot flag" "\-\-skip-reboot" "$script_content"
assert_contains "Auto-installer supports --dir flag" "\-\-dir" "$script_content"
assert_contains "Auto-installer has save_state function" "save_state()" "$script_content"
assert_contains "Auto-installer has get_state function" "get_state()" "$script_content"
assert_contains "Auto-installer has clear_state function" "clear_state()" "$script_content"

# ---- Test: All 9 tahap scripts are referenced ----
assert_contains "References setup.sh (Tahap 1)" 'echo "setup.sh"' "$script_content"
assert_contains "References install.sh (Tahap 2)" 'echo "install.sh"' "$script_content"
assert_contains "References setup-domain.sh (Tahap 3)" 'echo "setup-domain.sh"' "$script_content"
assert_contains "References setup-ssh.sh (Tahap 4)" 'echo "setup-ssh.sh"' "$script_content"
assert_contains "References setup-protocol.sh (Tahap 5)" 'echo "setup-protocol.sh"' "$script_content"
assert_contains "References setup-account.sh (Tahap 6)" 'echo "setup-account.sh"' "$script_content"
assert_contains "References setup-menu.sh (Tahap 7)" 'echo "setup-menu.sh"' "$script_content"
assert_contains "References setup-api.sh (Tahap 8)" 'echo "setup-api.sh"' "$script_content"
assert_contains "References setup-monitor.sh (Tahap 9)" 'echo "setup-monitor.sh"' "$script_content"

# ---- Test: Tahap names ----
assert_contains "Tahap 1 name" "Update Sistem" "$script_content"
assert_contains "Tahap 2 name" "Install Dependencies" "$script_content"
assert_contains "Tahap 3 name" "Domain, SSL" "$script_content"
assert_contains "Tahap 4 name" "SSH Tunneling" "$script_content"
assert_contains "Tahap 5 name" "Protokol Tambahan" "$script_content"
assert_contains "Tahap 6 name" "Manajemen Akun" "$script_content"
assert_contains "Tahap 7 name" "Menu Sistem" "$script_content"
assert_contains "Tahap 8 name" "REST API" "$script_content"
assert_contains "Tahap 9 name" "Monitoring" "$script_content"

# ===========================================================================
# Section 5: Uninstall Script contents
# ===========================================================================

echo ""
echo "--- Section 5: Uninstall Script ---"

# ---- Test: Uninstall has safety confirmation ----
assert_contains "Uninstall has confirmation prompt" "UNINSTALL" "$script_content"
assert_contains "Uninstall stops services" "systemctl stop" "$script_content"
assert_contains "Uninstall removes systemd services" "systemd/system/vpnray" "$script_content"
assert_contains "Uninstall removes cron jobs" "cron.d/vpnray" "$script_content"
assert_contains "Uninstall removes vpnray config" "rm -rf /etc/vpnray" "$script_content"

# ===========================================================================
# Section 6: Performance Optimization contents
# ===========================================================================

echo ""
echo "--- Section 6: Performance Optimization ---"

# ---- Test: Kernel tuning parameters ----
assert_contains "TCP BBR congestion control" "tcp_congestion_control = bbr" "$script_content"
assert_contains "TCP Fast Open" "tcp_fastopen = 3" "$script_content"
assert_contains "IP forwarding enabled" "ip_forward = 1" "$script_content"
assert_contains "High file descriptor limit" "file-max = 1048576" "$script_content"
assert_contains "Increased somaxconn" "somaxconn = 65535" "$script_content"
assert_contains "BBR qdisc fq" "default_qdisc = fq" "$script_content"
assert_contains "Network buffer max 64MB" "rmem_max = 67108864" "$script_content"
assert_contains "TCP keepalive time 60" "tcp_keepalive_time = 60" "$script_content"

# ---- Test: perftuning script options ----
assert_contains "Perftuning supports apply" "apply)" "$script_content"
assert_contains "Perftuning supports status" "status)" "$script_content"
assert_contains "Perftuning supports revert" "revert)" "$script_content"

# ===========================================================================
# Section 7: Security Hardening contents
# ===========================================================================

echo ""
echo "--- Section 7: Security Hardening ---"

# ---- Test: SSH hardening settings ----
assert_contains "SSH PermitEmptyPasswords" "PermitEmptyPasswords no" "$script_content"
assert_contains "SSH MaxAuthTries" "MaxAuthTries 5" "$script_content"
assert_contains "SSH X11Forwarding" "X11Forwarding no" "$script_content"

# ---- Test: Kernel security parameters ----
assert_contains "Reverse path filter" "rp_filter = 1" "$script_content"
assert_contains "Disable ICMP redirects" "accept_redirects = 0" "$script_content"
assert_contains "Disable source routing" "accept_source_route = 0" "$script_content"
assert_contains "SYN cookies" "tcp_syncookies = 1" "$script_content"
assert_contains "ASLR enabled" "randomize_va_space = 2" "$script_content"
assert_contains "Core dump disabled" "suid_dumpable = 0" "$script_content"
assert_contains "Restrict dmesg" "dmesg_restrict = 1" "$script_content"

# ---- Test: Hardening script options ----
assert_contains "Hardening supports apply" "Applying security hardening" "$script_content"
assert_contains "Hardening supports status" "Security Status" "$script_content"
assert_contains "Hardening supports revert" "Reverting security hardening" "$script_content"

# ===========================================================================
# Section 8: System Info Display contents
# ===========================================================================

echo ""
echo "--- Section 8: System Info Display ---"

# ---- Test: System info shows key information ----
assert_contains "Shows domain info" "Domain" "$script_content"
assert_contains "Shows IP address" "IP Address" "$script_content"
assert_contains "Shows OS info" "OS" "$script_content"
assert_contains "Shows CPU info" "CPU" "$script_content"
assert_contains "Shows RAM info" "RAM" "$script_content"
assert_contains "Shows SWAP info" "SWAP" "$script_content"
assert_contains "Shows Disk info" "Disk" "$script_content"

# ---- Test: Shows service ports ----
assert_contains "Shows SSH port" "22" "$script_content"
assert_contains "Shows REST API port 9000" "9000" "$script_content"
assert_contains "Shows vnStat port 8899" "8899" "$script_content"
assert_contains "Shows Webmin port" "10000" "$script_content"

# ===========================================================================
# Section 9: Documentation Generator contents
# ===========================================================================

echo ""
echo "--- Section 9: Documentation Generator ---"

# ---- Test: Doc generator creates comprehensive docs ----
assert_contains "Doc contains SERVER INFORMATION" "SERVER INFORMATION" "$script_content"
assert_contains "Doc contains SERVICE PORTS" "SERVICE PORTS" "$script_content"
assert_contains "Doc contains WEBSOCKET PATHS" "WEBSOCKET PATHS" "$script_content"
assert_contains "Doc contains ACTIVE ACCOUNTS" "ACTIVE ACCOUNTS" "$script_content"
assert_contains "Doc contains SERVICE STATUS" "SERVICE STATUS" "$script_content"
assert_contains "Doc contains CONFIGURATION FILES" "CONFIGURATION FILES" "$script_content"
assert_contains "Doc contains REST API" "REST API" "$script_content"
assert_contains "Doc contains USEFUL COMMANDS" "USEFUL COMMANDS" "$script_content"

# ===========================================================================
# Section 10: Version Management contents
# ===========================================================================

echo ""
echo "--- Section 10: Version Management ---"

# ---- Test: Version management features ----
assert_contains "Version check feature" "Checking for updates" "$script_content"
assert_contains "Version upgrade feature" "Starting upgrade" "$script_content"
assert_contains "Version stores to file" "VERSION_FILE" "$script_content"
assert_contains "Has version 2.0.0" '2.0.0' "$script_content"

# ===========================================================================
# Section 11: Integration Test contents
# ===========================================================================

echo ""
echo "--- Section 11: Integration Test ---"

# ---- Test: Integration test covers all components ----
assert_contains "Tests core config files" "Core Configuration Files" "$script_content"
assert_contains "Tests account system" "Account System" "$script_content"
assert_contains "Tests menu system" "Menu System" "$script_content"
assert_contains "Tests API & Bot" "API & Bot" "$script_content"
assert_contains "Tests monitoring & security" "Monitoring & Security" "$script_content"
assert_contains "Tests finalisasi scripts" "Finalisasi Scripts" "$script_content"
assert_contains "Tests running services" "Running Services" "$script_content"

# ===========================================================================
# Section 12: Production Checklist contents
# ===========================================================================

echo ""
echo "--- Section 12: Production Checklist ---"

# ---- Test: Checklist categories ----
assert_contains "Checklist: System Requirements" "System Requirements" "$script_content"
assert_contains "Checklist: SSL & Domain" "SSL & Domain" "$script_content"
assert_contains "Checklist: Core Services" "Core Services" "$script_content"
assert_contains "Checklist: Security" "Security" "$script_content"
assert_contains "Checklist: Backup" "Backup" "$script_content"
assert_contains "Checklist: Monitoring" "Monitoring" "$script_content"
assert_contains "Checklist: Version & Docs" "Version & Docs" "$script_content"

# ---- Test: Checklist has PRODUCTION-READY message ----
assert_contains "Production ready message" "PRODUCTION-READY" "$script_content"

# ===========================================================================
# Section 13: Rebuild Menu contents
# ===========================================================================

echo ""
echo "--- Section 13: Rebuild Menu ---"

# ---- Test: Rebuild menu options ----
assert_contains "Rebuild: Xray Config" "Rebuild Xray Config" "$script_content"
assert_contains "Rebuild: Nginx Config" "Rebuild Nginx Config" "$script_content"
assert_contains "Rebuild: HAProxy Config" "Rebuild HAProxy Config" "$script_content"
assert_contains "Rebuild: SSL Certificate" "Rebuild SSL Certificate" "$script_content"
assert_contains "Rebuild: All Services" "Rebuild All Services" "$script_content"
assert_contains "Rebuild: Akun Database" "Rebuild Akun Database" "$script_content"
assert_contains "Rebuild: Menu Scripts" "Rebuild Menu Scripts" "$script_content"
assert_contains "Rebuild: Full Rebuild" "Full Rebuild" "$script_content"

# ===========================================================================
# Section 14: State tracking / Error Recovery
# ===========================================================================

echo ""
echo "--- Section 14: Error Recovery ---"

# ---- Test: State manager commands ----
assert_contains "State get command" "vpnray-state" "$script_content"
assert_contains "State manager has get" 'get)' "$script_content"
assert_contains "State manager has set" 'set)' "$script_content"
assert_contains "State manager has clear" 'clear)' "$script_content"

# ===========================================================================
# Section 15: Referensi / References
# ===========================================================================

echo ""
echo "--- Section 15: References ---"

# ---- Test: Contains README referensi ----
assert_contains "References Xray-core" "XTLS/Xray-core" "$script_content"
assert_contains "References Xray-install" "XTLS/Xray-install" "$script_content"
assert_contains "References Hysteria2" "apernet/hysteria" "$script_content"
assert_contains "References Trojan-Go" "p4gefau1t/trojan-go" "$script_content"
assert_contains "References SoftEther" "SoftEtherVPN/SoftEtherVPN" "$script_content"
assert_contains "References v2ray-agent" "mack-a/v2ray-agent" "$script_content"
assert_contains "References Autoscript" "FN-Rerechan02/Autoscript" "$script_content"
assert_contains "References sshvpn-script" "GegeDevs/sshvpn-script" "$script_content"

# ===========================================================================
# Section 16: OS Support & Checks
# ===========================================================================

echo ""
echo "--- Section 16: OS Support ---"

# ---- Test: Supports all required OS ----
assert_contains "Supports Ubuntu 20.04" "20.04" "$script_content"
assert_contains "Supports Ubuntu 22.04" "22.04" "$script_content"
assert_contains "Supports Ubuntu 24.04" "24.04" "$script_content"
assert_contains "Supports Debian 10" 'Debian 10' "$script_content"
assert_contains "Supports Debian 11" 'Debian 11' "$script_content"
assert_contains "Supports Debian 12" 'Debian 12' "$script_content"

# ---- Test: Rejects unsupported virtualization ----
assert_contains "Rejects OpenVZ" "openvz" "$script_content"
assert_contains "Rejects LXC" "lxc" "$script_content"

# ===========================================================================
# Section 17: Main function flow
# ===========================================================================

echo ""
echo "--- Section 17: Main Function Flow ---"

# ---- Test: Main calls all 13 steps ----
assert_contains "Main calls create_auto_installer" "create_auto_installer" "$script_content"
assert_contains "Main calls setup_state_tracking" "setup_state_tracking" "$script_content"
assert_contains "Main calls create_post_install_verify" "create_post_install_verify" "$script_content"
assert_contains "Main calls create_sysinfo_script" "create_sysinfo_script" "$script_content"
assert_contains "Main calls create_uninstall_script" "create_uninstall_script" "$script_content"
assert_contains "Main calls create_rebuild_script" "create_rebuild_script" "$script_content"
assert_contains "Main calls create_perftuning_script" "create_perftuning_script" "$script_content"
assert_contains "Main calls create_hardening_script" "create_hardening_script" "$script_content"
assert_contains "Main calls create_docgen_script" "create_docgen_script" "$script_content"
assert_contains "Main calls create_update_script" "create_update_script" "$script_content"
assert_contains "Main calls create_integration_test" "create_integration_test" "$script_content"
assert_contains "Main calls create_checklist_script" "create_checklist_script" "$script_content"
assert_contains "Main applies performance tuning" "apply_performance_tuning" "$script_content"
assert_contains "Main applies security hardening" "apply_security_hardening" "$script_content"

# ---- Test: Final completion message ----
assert_contains "Completion message: Tahap 10 selesai" "Tahap 10 selesai" "$script_content"
assert_contains "Shows all tahap complete" "Semua tahap" "$script_content"

# ===========================================================================
# Section 18: Post-Install Verify script contents
# ===========================================================================

echo ""
echo "--- Section 18: Post-Install Verification ---"

# ---- Test: Verify script checks services ----
assert_contains "Verifies xray service" '"xray"' "$script_content"
assert_contains "Verifies nginx service" '"nginx"' "$script_content"
assert_contains "Verifies haproxy service" '"haproxy"' "$script_content"
assert_contains "Verifies fail2ban service" '"fail2ban"' "$script_content"
assert_contains "Verifies vnstat service" '"vnstat"' "$script_content"

# ---- Test: Verify script checks ports ----
assert_contains "Port check for SSH" '22:SSH' "$script_content"
assert_contains "Port check for API" '9000' "$script_content"
assert_contains "Port check for vnStat web" '8899' "$script_content"

# ===========================================================================
# Section 19: Shellcheck Validation
# ===========================================================================

echo ""
echo "--- Section 19: Shellcheck Validation ---"

test_name="Script passes shellcheck"
if command -v shellcheck &>/dev/null; then
    if shellcheck "$SCRIPT_PATH" 2>/dev/null; then
        assert_eq "$test_name" "true" "true"
    else
        assert_eq "$test_name" "true" "false"
    fi
else
    echo -e "${YELLOW}[SKIP]${NC} $test_name (shellcheck not installed)"
    ((SKIP++))
fi

# ---- Hasil ----
echo ""
echo "=============================================="
echo "  Hasil: $PASS passed, $FAIL failed, $SKIP skipped"
echo "=============================================="

if [[ "$FAIL" -gt 0 ]]; then
    exit 1
fi

exit 0
