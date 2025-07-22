#!/usr/bin/env bash
set -e

# Sandbox環境でAnsibleプレイブックを実行するスクリプト

# 使用方法表示
show_help() {
    echo "===== Arch Linux Ansible Sandbox ====="
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help           このヘルプを表示"
    echo "  -c, --check          ドライラン（変更を実行しない）"
    echo "  -v, --verbose        詳細出力"
    echo "  -vv, --extra-verbose 超詳細出力"
    echo "  --tags TAGS          指定したタグのみ実行"
    echo "  --skip-tags TAGS     指定したタグをスキップ"
    echo "  --limit HOSTS        実行対象ホストを制限"
    echo "  --role ROLE          指定したロールのみ実行（便利オプション）"
    echo ""
    echo "Available roles:"
    echo "  init    - System installation and partitioning (tagged as 'never' by default)"
    echo "  base    - Essential system configuration and packages"  
    echo "  cui     - Modern command line interface tools"
    echo ""
    echo "Examples:"
    echo "  $0                    # 全ロール実行（initは除く）"
    echo "  $0 --role cui         # CUIロールのみ実行"
    echo "  $0 --role base --check # baseロールのドライラン"
    echo "  $0 --tags base,cui    # base と cui ロールを実行"
    echo "  $0 --tags init        # initロール実行（システムインストール）"
    echo "  $0 --skip-tags cui    # cui以外のロールを実行"
    echo ""
}

# ヘルプ表示
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

echo "===== Arch Linux Ansible Sandbox ====="

# オプション設定
OPTS=()

# 引数解析
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--check)
            OPTS+=(--check)
            shift
            ;;
        -v|--verbose)
            OPTS+=(-v)
            shift
            ;;
        -vv|--extra-verbose)
            OPTS+=(-vv)
            shift
            ;;
        --tags)
            OPTS+=(--tags "$2")
            shift 2
            ;;
        --skip-tags)
            OPTS+=(--skip-tags "$2")
            shift 2
            ;;
        --limit)
            OPTS+=(--limit "$2")
            shift 2
            ;;
        --role)
            # ロール名をタグに変換（便利パラメータ）
            OPTS+=(--tags "$2")
            shift 2
            ;;
        *)
            echo "❌ Unknown option: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
done

# community.general確認
echo "📦 Ansible collectionの確認..."
if ! ansible-galaxy collection list 2>/dev/null | grep -q "community.general"; then
    echo "📦 community.generalをインストール..."
    ansible-galaxy collection install community.general
fi

# 接続テスト
echo "🔗 接続テスト..."
if ! ansible sandbox -i inventories/sandbox.yml -m ping --vault-password-file .vault_pass --extra-vars "@password.yml"; then
    echo "❌ 接続に失敗しました。inventory設定とSSH接続を確認してください。"
    exit 1
fi

# 実行予定のロール/タグを表示
if [[ " ${OPTS[*]} " =~ " --tags " ]]; then
    for ((i=0; i<${#OPTS[@]}; i++)); do
        if [[ "${OPTS[i]}" == "--tags" ]]; then
            echo "🎯 実行予定のタグ: ${OPTS[i+1]}"
            break
        fi
    done
elif [[ " ${OPTS[*]} " =~ " --skip-tags " ]]; then
    for ((i=0; i<${#OPTS[@]}; i++)); do
        if [[ "${OPTS[i]}" == "--skip-tags" ]]; then
            echo "⏭️  スキップするタグ: ${OPTS[i+1]}"
            break
        fi
    done
else
    echo "🎯 実行予定: 全ロール (initタグは除く)"
fi

# ドライランかどうかを表示
if [[ " ${OPTS[*]} " =~ " --check " ]]; then
    echo "🧪 ドライラン モード（変更は実行されません）"
fi

# プレイブック実行
echo "🚀 Ansibleプレイブック実行..."
ansible-playbook -i inventories/sandbox.yml playbook/sandbox.yml "${OPTS[@]}" --vault-password-file .vault_pass --extra-vars "@password.yml"

echo "✅ 完了"