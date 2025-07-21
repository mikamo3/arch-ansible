#!/usr/bin/env bash
set -e

# Sandbox環境でAnsibleプレイブックを実行するスクリプト

echo "===== Arch Linux Ansible Sandbox ====="

# ヘルプ表示
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: $0 [OPTIONS]"
    echo "  -h, --help    このヘルプを表示"
    echo "  -c, --check   ドライラン"
    echo "  -v, --verbose 詳細出力"
    exit 0
fi

# オプション設定
OPTS=""
[[ "$1" == "-c" || "$1" == "--check" ]] && OPTS="$OPTS --check"
[[ "$1" == "-v" || "$1" == "--verbose" ]] && OPTS="$OPTS -v"

# community.general確認
if ! ansible-galaxy collection list 2>/dev/null | grep -q "community.general"; then
    echo "📦 community.generalをインストール..."
    ansible-galaxy collection install community.general
fi

# 接続テスト
echo "🔗 接続テスト..."
ansible sandbox -i inventories/sandbox.yml -m ping

# プレイブック実行
echo "🚀 プレイブック実行..."
ansible-playbook -i inventories/sandbox.yml playbook/sandbox.yml $OPTS --vault-password-file .vault_pass

echo "✅ 完了"
