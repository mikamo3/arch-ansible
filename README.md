# arch-ansible

Personal Arch Linux setup automation for mainpc / nucbox / sandbox.

## Phase 1: OS インストール (archinstall)

Arch Linux インストール USB で対象マシンを起動してから実行する。

### Wi-Fi 接続 (有線 LAN が使えない場合)

```bash
iwctl
```

```
device list                        # インターフェース名を確認 (例: wlan0)
station wlan0 scan
station wlan0 get-networks         # SSID 一覧表示
station wlan0 connect <SSID>       # パスワードを求められたら入力
exit
```

接続確認:

```bash
ping -c 1 archlinux.org
```

### インストール実行

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

### ネットワーク事前設定 (chroot)

archinstall 完了後、reboot する前に chroot 内で NM プロファイルを配置しておくと、
初回起動時から自動接続される（Phase 1.5 の手動接続が不要になる）。

```bash
arch-chroot /mnt

git clone https://github.com/mikamo3/arch-ansible.git
cd arch-ansible

# op CLI が使えない chroot 環境では、先に Vault パスワードを配置しておく
printf '%s\n' 'your-vault-password' > .vault_pass
chmod 600 .vault_pass

# 対象ホストの secret.yml を事前に作成する
ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass \
  ansible-vault create inventories/host_vars/$(cat /etc/hostname)/secret.yml
```

`secret.yml` には以下の形式で値を入れる。

```yaml
ansible_become_password: "your-sudo-password"
wifi_ssid: "your-ssid"
wifi_password: "your-wifi-password"
```

```bash
ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass ./init_network.sh
```

完了後は `exit` で chroot を抜けて `reboot`。

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

Ansible 実行前に `inventories/host_vars/<hostname>/secret.yml` に認証情報を登録する。

```bash
ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass \
  ansible-vault edit inventories/host_vars/$(hostname)/secret.yml
# 以下を追記または更新:
# ansible_become_password: "your-sudo-password"
# wifi_ssid: "your-ssid"
# wifi_password: "your-wifi-password"
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

### Sunshine / Moonlight の検証用インストール

既存のリモートデスクトップ設定に合わせて導入する。

- 配信側: `desktop/tasks/remote.yml`。`desktop.display_manager: xrdp` のホスト
  （kamo3ai）に Sunshine を追加する。
- 接続側: `apps/tasks/remote.yml`。`apps.remote: true` のホスト
  （mainpc / nucbox / sandbox）に Remmina と Moonlight を導入する。

```bash
ansible-playbook playbook/configure.yml --limit kamo3ai --tags remote
ansible-playbook playbook/configure.yml --limit mainpc,nucbox,sandbox --tags remote
```

`base` ロールによる paru / sudo 設定が前提。`./run.sh` では `desktop` / `apps` に含まれる。

Ansible はパッケージの導入と Sunshine ユーザーサービスの有効化・起動を行う。
kamo3ai は `devices.gpu.integrated: amd` で
NVIDIA と AMD のドライバーを併用する。初回は `--tags gpu,remote` で適用する。

Sunshine の個人設定は dotfiles 側で管理する。
AMD エンコードの設定例（`~/.config/sunshine/sunshine.conf`）:

```ini
encoder = vaapi
adapter_name = /dev/dri/by-path/pci-0000:09:00.0-render
```

kamo3ai 上での起動状態の確認:

```bash
systemctl --user status app-dev.lizardbyte.app.Sunshine.service
journalctl --user -u app-dev.lizardbyte.app.Sunshine.service -b
```

Ansible はホーム配下への設定ファイル配置を行わない。
サービス有効化に伴う systemd のリンクは作成する。
適用時は対象ユーザーの systemd ユーザーマネージャーが動作している必要がある。
独自の仮想画面・自動ログイン・起動スクリプトは追加しない。
`enable` だけでデスクトップセッションが作られるわけではなく、
再起動後の RDP 未接続状態で配信できるかは別途検証する。
AMD のエンコード指定はデスクトップの描画先を変更しない。
Moonlight との初回ペアリングも別途必要。

参考: [Sunshine 起動手順](https://docs.lizardbyte.dev/projects/sunshine/latest/md_docs_2getting__started.html)、
[Sunshine 設定](https://docs.lizardbyte.dev/projects/sunshine/latest/md_docs_2configuration.html)。

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
| `wifi_ssid` | Wi-Fi を使うホスト | Wi-Fi SSID |
| `wifi_password` | Wi-Fi を使うホスト | Wi-Fi パスワード |

`.vault_pass` にはVault パスワードを平文で記載する（gitignore 済み）。

## Tips

### Bluetooth マウスのペアリング (GUI セットアップ前)

GUI 起動前など、ターミナルのみの環境でペアリングする場合は `bluetoothctl` を使う。

```bash
bluetoothctl
```

```
power on
agent on
default-agent
scan on          # マウスをペアリングモードにしてから実行 → MAC アドレスが表示される
scan off
pair XX:XX:XX:XX:XX:XX
trust XX:XX:XX:XX:XX:XX
connect XX:XX:XX:XX:XX:XX
exit
```

GUI 起動後は Bluetooth 設定画面から通常通り操作できる。

## ホスト一覧

| ホスト | 用途 | IP |
|---|---|---|
| mainpc | メイン作業機 | 192.168.100.100 |
| nucbox | ブラウジング / 持ち出し用 (Intel N100) | 192.168.100.20 |
| sandbox | 検証用 VM | 192.168.122.222 |
| kamo3ai | Stable Diffusion / AI ワークロード | 192.168.100.10 |
