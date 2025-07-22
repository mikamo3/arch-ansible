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
    echo "  --init        initロールのみ実行（Arch Linuxインストール用）"
    exit 0
fi

# オプション設定
OPTS=""
TAGS=""
RUN_INIT=false

# 引数解析
for arg in "$@"; do
    case $arg in
        -c|--check)
            OPTS="$OPTS --check"
            ;;
        -v|--verbose)
            OPTS="$OPTS -v"
            ;;
        --init)
            RUN_INIT=true
            TAGS="--tags init"
            ;;
    esac
done

# community.general確認
if ! ansible-galaxy collection list 2>/dev/null | grep -q "community.general"; then
    echo "📦 community.generalをインストール..."
    ansible-galaxy collection install community.general
fi

# 接続テスト
echo "🔗 接続テスト..."
ansible sandbox -i inventories/sandbox.yml -m ping --extra-vars "@password.yml"

# プレイブック実行
if [[ $RUN_INIT == true ]]; then
    echo "🚀 initロール実行（Arch Linuxインストール）..."
    ansible-playbook -i inventories/sandbox.yml playbook/sandbox.yml $OPTS --vault-password-file .vault_pass --extra-vars "@password.yml" $TAGS
else
    echo "🚀 baseロール実行（通常運用）..."
    ansible-playbook -i inventories/sandbox.yml playbook/sandbox.yml $OPTS --vault-password-file .vault_pass --extra-vars "@password.yml"
fi

echo "✅ 完了"
