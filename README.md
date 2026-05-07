# arch-ansible

Personal Arch Linux setup automation for mainpc / nucbox / sandbox.

## Phase 1: OS インストール (archinstall)

Arch Linux インストール USB で対象マシンを起動してから実行する。

```bash
# 1. git を入手
pacman -S git

# 2. このリポジトリを clone
git clone https://github.com/mikamo3/arch-ansible.git
cd arch-ansible

# 3. インストール実行
./init.sh
```

起動後、対象マシンをメニューから選択してパスワードを入力すると archinstall が実行される。
設定ファイルは `inventories/archinstall/<hostname>.json`。

## Phase 1.5: 初回ネットワーク接続 (nucbox)

archinstall 完了後、`reboot` で再起動する。nucbox はネットワーク設定を Ansible で行うため、
初回のみ手動で接続する（永続化不要）。

```bash
# Wi-Fi
nmtui    # → "ネットワークへの接続" → SSID を選択してパスワード入力

# 有線 (固定 IP で一時接続)
nmcli con add type ethernet con-name tmp ifname enp1s0 \
  ipv4.method manual ipv4.addresses 192.168.100.20/24 \
  ipv4.gateway 192.168.100.1 ipv4.dns 192.168.100.1
nmcli con up tmp
```

Ansible 実行後は `/etc/NetworkManager/system-connections/` に永続プロファイルが配置される。

## Phase 2: Ansible による設定適用

Ansible 実行前に `inventories/host_vars/nucbox/secret.yml` に Wi-Fi 認証情報を登録する。

```bash
ansible-vault edit inventories/host_vars/nucbox/secret.yml
# 以下を追記:
# wifi_ssid: "your-ssid"
# wifi_password: "your-password"
```

archinstall 完了後、`reboot` で再起動する。

### リモート実行 (コントロールマシンから)

SSH 疎通を確認してから実行する。

```bash
ansible all -m ping          # 疎通確認
./run.sh                     # 対話的実行 (fzf)
```

### ローカル実行 (対象マシン上で直接)

対象マシンにログインし、このリポジトリを clone して実行する。

```bash
git clone https://github.com/mikamo3/arch-ansible.git
cd arch-ansible
ansible-playbook playbook/configure.yml --limit $(hostname) -c local
```

### Phase 2 完了後

dotfiles リポジトリの `init.sh` を実行してユーザー環境を構築する。

```bash
git clone https://github.com/mikamo3/dotfiles.git
cd dotfiles
./init.sh
```

## Vault キー一覧

各ホストの `inventories/host_vars/<hostname>/secret.yml` に以下のキーを定義する。
編集: `ansible-vault edit inventories/host_vars/<hostname>/secret.yml`

| キー | 対象ホスト | 説明 |
|---|---|---|
| `ansible_become_password` | 全ホスト | sudo パスワード |
| `wifi_ssid` | nucbox | Wi-Fi SSID |
| `wifi_password` | nucbox | Wi-Fi パスワード |

`.vault_pass` にはVault パスワードを平文で記載する（gitignore 済み）。

## ホスト一覧

| ホスト | 用途 | IP |
|---|---|---|
| mainpc | メイン作業機 | 192.168.100.100 |
| nucbox | ブラウジング / 持ち出し用 (Intel N100) | 192.168.100.20 |
| sandbox | 検証用 VM | 192.168.122.222 |
