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
curl -L https://raw.githubusercontent.com/mikamo3/arch-ansible/master/init.sh -o init.sh
chmod +x init.sh
./init.sh
```

#### 方法3: IPアドレス指定での直接実行

```bash
# ホストマシンで実行（IPアドレスを指定して自動インベントリ生成）
./install_system.sh -t 192.168.1.100

# または対話的にインベントリファイルを選択
./install_system.sh
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

### 3. パスワード設定ファイルの生成

システム設定前に、ユーザーパスワードの設定ファイルを生成：

```bash
# パスワード設定ファイルを生成
./generate_secret.sh

# 既存ファイルを上書きする場合
./generate_secret.sh --force
```

### 4. Ansibleでのパーティショニング・初期構築

別のマシンから、またはVM環境でAnsibleを実行：

```bash
# community.generalコレクションをインストール
ansible-galaxy collection install community.general

# システム設定の実行
./run_playbook.sh

# または直接実行
ansible-playbook -i inventories/sandbox.yml playbook/configure.yml --extra-vars "@vars/secret.yml"
```

## ファイル構成

```
├── init.sh                    # インストールディスク用環境準備スクリプト
├── install_system.sh          # システムインストール実行スクリプト
├── run_playbook.sh           # システム設定実行スクリプト
├── inventories/
│   ├── sandbox.yml           # 実験用VM設定
│   ├── nucbox.yml           # NUCBox設定
│   └── ai.yml               # AI環境設定
├── playbook/
│   ├── install.yml          # システムインストール用（init roleのみ）
│   ├── configure.yml        # システム設定用（init以外の全role）
│   └── main.yml            # レガシー統合playbook
├── generate_secret.sh        # パスワード設定ファイル生成スクリプト
├── vars/
│   └── secret.yml          # 生成される機密情報（gitignore対象）
└── roles/
    ├── init/               # システムインストール（パーティション・chroot）
    ├── base/              # 基本システム・パッケージ管理
    ├── shell/             # シェル環境・CLI ツール
    ├── desktop/           # デスクトップ環境・GUI基盤
    ├── devices/           # ハードウェア固有ドライバー
    ├── storage/           # ストレージ・バックアップ・暗号化
    ├── office/            # オフィス・ドキュメント生産性
    ├── media/             # メディア編集・再生
    ├── development/       # ソフトウェア開発環境
    ├── cad/              # CAD・エンジニアリング設計
    ├── container/         # コンテナランタイム
    ├── virtualization/    # 仮想マシン環境
    └── home/             # ユーザーホームディレクトリ・dotfiles
```

## パーティション構成

UEFI + btrfs + サブボリューム構成：

- `/dev/sdaX1`: EFI システムパーティション (1GB, fat32) → `/boot`
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
      ansible_host: 192.168.122.100
      ansible_port: 22
      ansible_user: ansible
  vars:
    # Init role - システムインストール設定
    init:
      timezone: "Asia/Tokyo"
      locale:
        enabled:
          - "en_US.UTF-8 UTF-8"
          - "ja_JP.UTF-8 UTF-8"
        lang: "ja_JP.UTF-8"
      hostname: "sandboxvm"
      target_disk: /dev/vda
      main_user:
        name: testuser
        groups: [wheel, users]
        shell: /bin/bash

    # 各役割の設定（必要に応じて有効化）
    devices:
      gpu:
        install: true
        type: "vm-qemu"
      audio:
        install: true
      bluetooth:
        install: false
      printer:
        install: false

    desktop:
      environment:
        install: true
        type: "gnome"        # または "hyprland"
      display_manager:
        install: true
        type: "gdm"          # または "ly"
      fonts:
        install: "full"      # または "minimal"
      inputmethod:
        install: true
        method: "fcitx5"

    # container, development, virtualization等も同様に設定可能
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
