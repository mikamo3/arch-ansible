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

## Phase 2: Ansible による設定適用

OS インストール後、SSH 疎通が取れる状態で実行する。

```bash
# 対話的実行 (fzf)
./run.sh

# 直接実行
ansible-playbook playbook/configure.yml --limit nucbox

# ローカル実行 (対象マシン上で直接)
ansible-playbook playbook/configure.yml --limit $(hostname) -c local
```

## ホスト一覧

| ホスト | 用途 | IP |
|---|---|---|
| mainpc | メイン作業機 | 192.168.100.100 |
| nucbox | ブラウジング / 持ち出し用 (Intel N100) | 192.168.100.20 |
| sandbox | 検証用 VM | 192.168.122.222 |
