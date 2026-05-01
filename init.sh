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
# 1. 前提チェック
# ---------------------------------------------------------------------------
section "環境チェック"

if [[ $EUID -ne 0 ]]; then
    error "このスクリプトはroot権限で実行してください"
fi

if ! ping -c1 -W3 google.com &>/dev/null; then
    error "インターネットに接続されていません"
fi

if ! command -v archinstall &>/dev/null; then
    error "archinstallが見つかりません。Arch Linux live環境で実行してください"
fi

info "環境チェック OK"

# ---------------------------------------------------------------------------
# 2. マシン選択
# ---------------------------------------------------------------------------
section "マシン選択"

configs=()
while IFS= read -r f; do
    name="$(basename "$f" .json)"
    configs+=("$name")
done < <(find "$CONFIGS_DIR" -name "*.json" | sort)

if [[ ${#configs[@]} -eq 0 ]]; then
    error "設定ファイルが見つかりません: $CONFIGS_DIR"
fi

echo "インストール対象を選択してください:"
for i in "${!configs[@]}"; do
    echo "  $((i+1))) ${configs[$i]}"
done

while true; do
    read -rp "番号を入力 [1-${#configs[@]}]: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#configs[@]} )); then
        selected="${configs[$((choice-1))]}"
        break
    fi
    warn "無効な入力です"
done

config_file="$CONFIGS_DIR/${selected}.json"
info "設定ファイル: $config_file"

# ---------------------------------------------------------------------------
# 3. パスワード入力
# ---------------------------------------------------------------------------
section "パスワード設定"

while true; do
    read -rsp "rootパスワード: " root_pass; echo
    read -rsp "rootパスワード (確認): " root_pass2; echo
    [[ "$root_pass" == "$root_pass2" ]] && break
    warn "パスワードが一致しません。再入力してください"
done

while true; do
    read -rsp "ユーザーパスワード: " user_pass; echo
    read -rsp "ユーザーパスワード (確認): " user_pass2; echo
    [[ "$user_pass" == "$user_pass2" ]] && break
    warn "パスワードが一致しません。再入力してください"
done

# ---------------------------------------------------------------------------
# 4. ユーザー名取得 (configから読む、なければデフォルト)
# ---------------------------------------------------------------------------
username="$(python3 -c "
import json
with open('$config_file') as f:
    cfg = json.load(f)
users = cfg.get('!users', cfg.get('users', []))
print(users[0].get('username', 'mikamo') if users else 'mikamo')
" 2>/dev/null || echo "mikamo")"

info "ユーザー名: $username"

# ---------------------------------------------------------------------------
# 5. archinstall 実行
# ---------------------------------------------------------------------------
section "archinstall 実行"

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

info "設定ファイルの内容を確認してください"
warn "この操作はディスクを完全に消去します"
echo ""

archinstall --config "$config_file" --creds "$tmp_creds"

info "インストール完了"
info "再起動してください: reboot"
