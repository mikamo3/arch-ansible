# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ansible automation for personal Arch Linux machines (mainpc, nucbox). Covers post-installation system configuration. `old/` contains a previous iteration kept for reference.

## Two-Phase Setup Process

1. **Installation Phase**: `init.sh` — run on Arch Linux live USB. Uses archinstall with a per-machine JSON config.
2. **Configuration Phase**: `playbook/configure.yml` — run from remote machine during setup, or locally after setup is complete.

### Phase 1 — Installation

```bash
# リポジトリをcloneして実行 (live USB上で)
git clone https://github.com/mikamo3/arch-ansible
cd arch-ansible
./init.sh
```

- マシンを選択すると `inventories/archinstall/<hostname>.json` を使って archinstall を実行する
- パスワードは対話的に入力する（リポジトリには保存しない）
- 各マシンのJSONは対話式archinstallを実行後に生成されたものを保存したもの

### Phase 2 — Configuration

```bash
# リモートから実行 (セットアップ中)
ansible-playbook -i inventories/hosts.yml playbook/configure.yml --limit mainpc

# ローカルで実行 (運用時)
ansible-playbook -i inventories/hosts.yml playbook/configure.yml --limit mainpc

# 特定ロールのみ
ansible-playbook -i inventories/hosts.yml playbook/configure.yml --tags base,shell

# ドライラン
ansible-playbook -i inventories/hosts.yml playbook/configure.yml --check

# 疎通確認
ansible all -i inventories/hosts.yml -m ping
```

## Repository Structure

```
init.sh                  # Phase 1: live USB上で実行するインストールスクリプト
inventories/
  hosts.yml              # host definitions (IP, SSH settings)
  host_vars/
    mainpc.yml           # mainpc-specific variables
    nucbox.yml           # nucbox-specific variables
  archinstall/
    sandbox.json         # archinstall config per machine (credentials除く)
    mainpc.json
    nucbox.json
playbook/
  configure.yml          # main playbook (Phase 2)
roles/
  base/                  # core packages, security, services
  shell/                 # fish, CLI tools, dotfiles
  devices/               # GPU drivers, audio, Bluetooth, printer
  desktop/               # DE (Hyprland/GNOME), DM, fonts, fcitx5
  media/                 # media playback and editing apps
  office/                # LibreOffice, CAD tools
  development/           # VS Code, Git, Docker, dev tools
  virtualization/        # QEMU/KVM, VirtualBox
library/                 # ansible-aur custom module
old/                     # previous iteration (reference only)
```

## Inventory Design

- `inventories/hosts.yml` — host list with connection settings only
- `inventories/host_vars/<hostname>.yml` — all role variables for that host
- Each role's behavior is controlled by variables in `host_vars`; roles check these to decide what to install

Example pattern in `host_vars/nucbox.yml`:
```yaml
office:
  libreoffice: false
  cad: false
```

## Key Design Rules

- **Inline package style**: List packages directly with inline comments, not variable lists — intentional for readability
- **AUR module**: Use the `aur` module (from `library/ansible-aur`) instead of `pacman` for all roles except `base` (yay not yet available during base setup)
- **Inventory-driven**: All machine-specific config is in `host_vars/`; roles must not hard-code host differences
- **Wayland-first**: No X11 assumptions
- **Templates over inline content**: Config files go in `roles/{role}/templates/*.j2`
- **Minimal configuration**: Rely on package post-install scripts; only configure what's strictly necessary
- **Personal use**: No need for production-level hardening or enterprise patterns — keep it simple

## ansible.cfg Key Settings

```ini
library = library               # ansible-aur custom module
inventory = inventories/hosts.yml
interpreter_python = /usr/bin/python
host_key_checking = False
```

## btrfs Subvolume Layout (Phase 1 reference)

```
EFI (1GB, FAT32)  →  /boot
btrfs root:
  @             →  /
  @home         →  /home
  @.snapshots   →  /.snapshots
  @pkg          →  /var/cache/pacman/pkg
  @log          →  /var/log
```
All btrfs mounts use `compress=zstd:3,ssd,discard=async,space_cache=v2`.
