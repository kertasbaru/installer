#!/bin/bash
# ============================================================================
# Test suite untuk setup.sh — Tahap 1: Update Sistem & Reboot
# ============================================================================
# Menjalankan pengujian unit untuk fungsi-fungsi di setup.sh
# tanpa menjalankan operasi berbahaya (update/reboot).
#
# Penggunaan:
#   chmod +x tests/test_setup.sh
#   ./tests/test_setup.sh
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_PATH="$SCRIPT_DIR/setup.sh"

PASS=0
FAIL=0

# Warna
RED='\033[0;31m'
GREEN='\033[0;32m'
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

echo "=============================================="
echo "  Test Suite: setup.sh (Tahap 1)"
echo "=============================================="
echo ""

# ---- Test 1: File setup.sh ada ----
test_name="setup.sh file exists"
if [[ -f "$SCRIPT_PATH" ]]; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 2: File setup.sh executable ----
test_name="setup.sh is executable"
if [[ -x "$SCRIPT_PATH" ]]; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 3: Bash syntax valid ----
test_name="setup.sh has valid bash syntax"
if bash -n "$SCRIPT_PATH" 2>/dev/null; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 4: Shebang correct ----
test_name="setup.sh has correct shebang (#!/bin/bash)"
first_line=$(head -1 "$SCRIPT_PATH")
assert_eq "$test_name" "#!/bin/bash" "$first_line"

# ---- Test 5: LOG_FILE is defined ----
test_name="LOG_FILE variable is set to /root/syslog.log"
if grep -q 'LOG_FILE="/root/syslog.log"' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 6: Script contains check_root function ----
test_name="Script contains check_root function"
if grep -q 'check_root()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 7: Script contains check_os function ----
test_name="Script contains check_os function"
if grep -q 'check_os()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 8: Script contains check_arch function ----
test_name="Script contains check_arch function"
if grep -q 'check_arch()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 9: Script contains check_virt function ----
test_name="Script contains check_virt function"
if grep -q 'check_virt()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 10: Script contains update_system function ----
test_name="Script contains update_system function"
if grep -q 'update_system()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 11-13: Script supports Ubuntu versions ----
for ver in "20.04" "22.04" "24.04"; do
    test_name="Script supports Ubuntu $ver"
    if grep -q "$ver" "$SCRIPT_PATH"; then
        assert_eq "$test_name" "true" "true"
    else
        assert_eq "$test_name" "true" "false"
    fi
done

# ---- Test 14-16: Script supports Debian versions ----
for ver in 10 11 12; do
    test_name="Script supports Debian $ver"
    if grep -A5 'debian)' "$SCRIPT_PATH" | grep -q "$ver"; then
        assert_eq "$test_name" "true" "true"
    else
        assert_eq "$test_name" "true" "false"
    fi
done

# ---- Test 17: Script checks for x86_64 architecture ----
test_name="Script checks for x86_64 architecture"
if grep -q 'x86_64' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 18: Script rejects OpenVZ ----
test_name="Script rejects OpenVZ virtualization"
if grep -q 'openvz' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 19: Script sets DEBIAN_FRONTEND=noninteractive ----
test_name="Script sets DEBIAN_FRONTEND=noninteractive"
if grep -q 'DEBIAN_FRONTEND=noninteractive' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 20: Script runs apt-get update ----
test_name="Script runs apt-get update"
if grep -q 'apt-get update' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 21: Script runs apt-get upgrade ----
test_name="Script runs apt-get upgrade"
if grep -q 'apt-get upgrade' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 22: Script reinstalls grub ----
test_name="Script reinstalls grub"
if grep -q 'install --reinstall.*grub' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 23: Script runs update-grub ----
test_name="Script runs update-grub"
if grep -q 'update-grub' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 24: Script adds dip group ----
test_name="Script adds dip group"
if grep -q 'addgroup dip' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 25: Script calls reboot ----
test_name="Script calls reboot"
if grep -q 'reboot' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 26: Script contains main function ----
test_name="Script contains main function"
if grep -q 'main()' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 27: Script passes shellcheck ----
test_name="Script passes shellcheck"
if command -v shellcheck &>/dev/null; then
    if shellcheck "$SCRIPT_PATH" 2>/dev/null; then
        assert_eq "$test_name" "true" "true"
    else
        assert_eq "$test_name" "true" "false"
    fi
else
    echo -e "${GREEN}[SKIP]${NC} $test_name (shellcheck not installed)"
fi

# ---- Test 28: Script uses --allow-releaseinfo-change flag ----
test_name="Script uses --allow-releaseinfo-change for apt-get update"
if grep -q '\-\-allow-releaseinfo-change' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 29: Script uses --fix-missing flag for upgrade ----
test_name="Script uses --fix-missing for apt-get upgrade"
if grep -q '\-\-fix-missing' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Test 30: Script logs to syslog.log ----
test_name="Script writes to log file"
if grep -q 'LOG_FILE' "$SCRIPT_PATH"; then
    assert_eq "$test_name" "true" "true"
else
    assert_eq "$test_name" "true" "false"
fi

# ---- Hasil ----
echo ""
echo "=============================================="
echo "  Hasil: $PASS passed, $FAIL failed"
echo "=============================================="

if [[ "$FAIL" -gt 0 ]]; then
    exit 1
fi

exit 0
