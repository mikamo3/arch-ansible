# Arch Linux Ansible

Arch Linux環境の初期構築・設定を自動化するAnsibleプロジェクトです。

## 概要

- Arch Linuxインストールディスクから自動パーティショニング・初期構築
- UEFI + btrfs + サブボリューム構成をサポート
- 複数マシン（mainpc, portable, ai）の管理

## 使い方

### 1. インストールディスクでの準備

Arch Linuxインストールディスクで起動後、以下を実行してAnsible環境を準備：

#### 方法1: ホストマシンからHTTP経由でダウンロード（推奨）

**ホストマシン側：**
```bash
# プロジェクトディレクトリでHTTPサーバーを起動
cd /home/mikamo/src/github.com/mikamo3/arch-ansible
python -m http.server 8000
# サーバーが http://0.0.0.0:8000 で起動します
```

**VM/インストールディスク側：**
```bash
# ホストマシンのIPアドレスを確認（例: 192.168.1.100）
curl -O http://192.168.1.100:8000/init.sh
chmod +x init.sh
./init.sh
```

#### 方法2: GitHub経由でダウンロード

```bash
curl -L https://raw.githubusercontent.com/mikamo3/arch-ansible/feature/refactor_2/init.sh -o init.sh
chmod +x init.sh
./init.sh
```

#### 方法3: 手動でスクリプトを作成

```bash
cat > init.sh << 'EOF'
# init.shの内容をここに貼り付け
EOF
chmod +x init.sh
./init.sh
```

### 2. ネットワーク設定（必要に応じて）

```bash
# 有線接続（DHCP）
systemctl start dhcpcd

# WiFi接続
iwctl
# [iwd]# station wlan0 scan
# [iwd]# station wlan0 get-networks  
# [iwd]# station wlan0 connect SSID
```

### 3. Ansibleでのパーティショニング・初期構築

別のマシンから、またはVM環境でAnsibleを実行：

```bash
# community.generalコレクションをインストール
ansible-galaxy collection install community.general

# sandbox環境での実行例
ansible-playbook -i inventories/sandbox.yml playbook/sandbox.yml

# 実機での実行例（inventoryを作成後）
ansible-playbook -i inventories/mainpc.yml playbook/mainpc.yml
```

## ファイル構成

```
├── init.sh                    # インストールディスク用環境準備スクリプト
├── inventories/
│   └── sandbox.yml           # 実験用VM設定
├── playbook/
│   └── sandbox.yml           # sandbox用playbook
└── roles/
    └── init/
        ├── defaults/main.yml
        ├── handlers/main.yml
        └── tasks/
            ├── main.yml           # メインタスク
            ├── btrfs_partition.yml # パーティショニング
            └── time_sync.yml      # 時刻同期確認
```

## パーティション構成

UEFI + btrfs + サブボリューム構成：

- `/dev/sdaX1`: EFI システムパーティション (512MB, fat32)
- `/dev/sdaX2`: btrfs ルートパーティション
  - `@`: ルートサブボリューム（/）
  - `@home`: ホームサブボリューム（/home）
  - `@.snapshots`: スナップショット用（/.snapshots）
  - `@pkg`: pacmanキャッシュ用（/var/cache/pacman/pkg）
  - `@log`: ログ用（/var/log）

## 変数設定

inventory（例：inventories/sandbox.yml）で以下を設定：

```yaml
---
sandbox:
  hosts:
    sandboxvm:
      ansible_host: 127.0.0.1
      ansible_port: 2222
      ansible_user: ansible
      target_disk: /dev/vda    # インストール先ディスク
```

## 注意事項

- `target_disk`に指定したディスクは**完全に初期化**されます
- 実行前にデータのバックアップを確実に行ってください
- テスト環境（sandbox）での動作確認を推奨

## トラブルシューティング

### SSH接続エラー

```bash
# VM側でSSH状態確認
systemctl status sshd
ss -tlnp | grep :22

# パスワード確認
passwd ansible
```

### パーティショニングエラー

```bash
# ディスク状態確認
lsblk
fdisk -l

# btrfs-progsインストール確認
pacman -Q btrfs-progs
```
