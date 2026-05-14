#!/bin/bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }
section() { echo -e "\n${BLUE}=== $* ===${NC}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$SCRIPT_DIR/inventories/archinstall"

# ---------------------------------------------------------------------------
# 1. Prerequisites check
# ---------------------------------------------------------------------------
section "Environment check"

if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root"
fi

if ! ping -c1 -W3 google.com &>/dev/null; then
    error "No internet connection"
fi

if ! command -v archinstall &>/dev/null; then
    error "archinstall not found. Run this script from an Arch Linux live environment"
fi

info "Environment check OK"

# ---------------------------------------------------------------------------
# 2. Machine selection
# ---------------------------------------------------------------------------
section "Machine selection"

configs=()
while IFS= read -r f; do
    name="$(basename "$f" .json)"
    configs+=("$name")
done < <(find "$CONFIGS_DIR" -name "*.json" | sort)

if [[ ${#configs[@]} -eq 0 ]]; then
    error "No config files found: $CONFIGS_DIR"
fi

echo "Select installation target:"
for i in "${!configs[@]}"; do
    echo "  $((i+1))) ${configs[$i]}"
done

while true; do
    read -rp "Enter number [1-${#configs[@]}]: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#configs[@]} )); then
        selected="${configs[$((choice-1))]}"
        break
    fi
    warn "Invalid input"
done

config_file="$CONFIGS_DIR/${selected}.json"
info "Config file: $config_file"

# ---------------------------------------------------------------------------
# 3. Password input
# ---------------------------------------------------------------------------
section "Password setup"

while true; do
    read -rsp "Root password: " root_pass; echo
    read -rsp "Root password (confirm): " root_pass2; echo
    [[ "$root_pass" == "$root_pass2" ]] && break
    warn "Passwords do not match. Please try again"
done

while true; do
    read -rsp "User password: " user_pass; echo
    read -rsp "User password (confirm): " user_pass2; echo
    [[ "$user_pass" == "$user_pass2" ]] && break
    warn "Passwords do not match. Please try again"
done

# ---------------------------------------------------------------------------
# 4. Get username (from config, fallback to default)
# ---------------------------------------------------------------------------
username="$(python3 -c "
import json
with open('$config_file') as f:
    cfg = json.load(f)
users = cfg.get('!users', cfg.get('users', []))
print(users[0].get('username', 'mikamo') if users else 'mikamo')
" 2>/dev/null || echo "mikamo")"

info "Username: $username"

# ---------------------------------------------------------------------------
# 5. Run archinstall
# ---------------------------------------------------------------------------
section "Running archinstall"

tmp_creds="$(mktemp /tmp/archinstall-creds.XXXXXX.json)"
trap 'rm -f "$tmp_creds"' EXIT

cat > "$tmp_creds" <<EOF
{
  "!root-password": "$root_pass",
  "!users": [
    {
      "username": "$username",
      "!password": "$user_pass",
      "sudo": true
    }
  ]
}
EOF

info "Please verify the config file contents"
warn "This operation will completely wipe the disk"
echo ""

archinstall --config "$config_file" --creds "$tmp_creds"

info "Installation complete"
info "Please reboot: reboot"
