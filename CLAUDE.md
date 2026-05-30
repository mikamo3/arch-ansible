# CLAUDE.md

Personal Arch Linux 向け Ansible 自動化。対象: mainpc, nucbox, sandbox (VM)。

セットアップは2段階:
1. **Phase 1**: `./init.sh` (live USB) → archinstall (`inventories/archinstall/<hostname>.json`)
2. **Phase 2**: `playbook/configure.yml` (Ansible)

`old/` は旧実装。設計参考用、移植対象ではない。

## Phase 2 コマンド

```bash
./run.sh                                                                  # 対話的実行 (fzf)
ansible-playbook playbook/configure.yml --limit sandbox                  # 全ロール
ansible-playbook playbook/configure.yml --limit sandbox --tags base      # 特定ロール
ansible-playbook playbook/configure.yml --limit $(hostname) -c local     # ローカル実行
ansible-playbook playbook/configure.yml --check                          # dry-run
ansible all -m ping                                                      # 疎通確認
```

## Architecture

- **Inventory-driven**: マシン固有設定は `inventories/host_vars/<hostname>/main.yml`。ロールでホスト分岐をハードコードしない。
- **Wayland-first**: X11 前提を置かない。
- **Personal use**: production-grade な堅牢化や企業向けパターンを持ち込まない。シンプルさ優先。

## AUR

- ヘルパー: **paru** (`base` ロールが makepkg で bootstrap)。
- `base` 以外のロールは `library/ansible-aur` (git submodule, Collection 構造) の `aur` モジュールを使う。`pacman` モジュールは使わない。
- `base` ロールが `aur_sudo_users` に `/usr/bin/pacman` の NOPASSWD sudo (`/etc/sudoers.d/10-aur-builder`) を付与。既定値は `ansible_user`。ローカル実行も許可するホストではログインユーザーを追加する。後続ロールの全 AUR ビルドはこれに依存。
- `-git` パッケージのインストール確認は `ansible.builtin.package_facts` を使う (例: `'kawazu-git' in ansible_facts.packages`)。ファイル存在チェックやビルドキャッシュには頼らない。

## Style

- **Inline package style**: パッケージはインラインでコメント付きで列挙。変数化しない (個人用途では可読性優先)。
- **Templates over inline**: 設定ファイルは `roles/{role}/templates/*.j2`。
- **Minimal config**: パッケージのデフォルト設定を尊重。必要なものだけ書く。

## Secrets

- `.vault_pass` (gitignore済) に Vault パスワード。`ansible.cfg` から自動参照。
- `inventories/host_vars/<hostname>/secret.yml` (gitignore済) に vault 暗号化された機密情報。主に `ansible_become_password`。編集は `ansible-vault edit`。
- **secret/password/credential/token/vault を含むファイルは読まない・表示しない**。
