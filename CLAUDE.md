# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Ansible automation project for Arch Linux installation and configuration. The project automates the complete setup from Arch Linux installation media to a fully configured system with UEFI + btrfs + subvolumes architecture.

## Key Architecture Components

### Two-Phase Setup Process
1. **Installation Media Phase**: Run `init.sh` on Arch Linux installation disk to prepare Ansible environment
2. **Ansible Automation Phase**: Execute playbooks from external machine to perform partitioning and system installation

### Core Roles Structure
- **init role**: Primary role handling disk partitioning, btrfs subvolumes, and chroot system setup
  - `btrfs_partition.yml`: Creates GPT partitions and btrfs subvolumes (@, @home, @.snapshots, @pkg, @log)  
  - `chroot_setup.yml`: Installs base system via arch-chroot
  - `ansible_setup.yml`: Configures Ansible user in new system
  - `cleanup.yml`: Unmounts filesystems after installation

### Storage Architecture
- EFI System Partition (1GB, FAT32) → `/boot`
- btrfs root partition with subvolumes:
  - `@` → `/` (root filesystem)
  - `@home` → `/home`
  - `@.snapshots` → `/.snapshots`
  - `@pkg` → `/var/cache/pacman/pkg`
  - `@log` → `/var/log`

## Common Commands

### Sandbox Environment
```bash
# Run sandbox playbook with connection test
./run_sandbox.sh

# Dry run
./run_sandbox.sh --check

# Verbose output  
./run_sandbox.sh --verbose

# Manual execution
ansible-playbook -i inventories/sandbox.yml playbook/sandbox.yml --vault-password-file .vault_pass
```

### Installation Media Setup
```bash
# On Arch Linux installation disk
./init.sh

# Or download from host machine
curl -O http://HOST_IP:8000/init.sh && chmod +x init.sh && ./init.sh
```

### Ansible Operations
```bash
# Install required collection
ansible-galaxy collection install community.general

# Test connectivity
ansible sandbox -i inventories/sandbox.yml -m ping

# Run with vault password
ansible-playbook -i inventories/sandbox.yml playbook/sandbox.yml --vault-password-file .vault_pass
```

## Configuration Files

### Inventory Structure
- `inventories/sandbox.yml`: VM testing environment configuration
- Set `target_disk` variable to specify installation target (e.g., `/dev/vda`)
- Configure `ansible_host`, `ansible_port`, `ansible_user` for SSH access

### Vault Configuration  
- `vars/secret.yml`: Ansible Vault encrypted secrets
- `.vault_pass`: Vault password file (example in `.vault_pass.example`)
- Password file must contain vault password for automated playbook execution

### Ansible Configuration
- Custom library path: `./library` (includes ansible-aur for AUR package management)
- YAML stdout callback for readable output
- Host key checking disabled for automation
- Python interpreter: `/usr/bin/python`

## Development Workflow

### Testing Changes
1. Test in sandbox environment first: `./run_sandbox.sh --check`
2. Verify partition layout with `lsblk` after successful run
3. Check mounted subvolumes in `/mnt` directory structure

### Adding New Tasks
- Add tasks to appropriate files in `roles/init/tasks/`
- Use `become: true` for privileged operations
- Register cleanup handlers for filesystem operations
- Follow existing patterns for btrfs and mount operations

## Important Notes

### Security Considerations
- Target disk specified in inventory will be **completely wiped**
- Ansible user gets passwordless sudo access during installation
- SSH is configured to allow root login during installation phase

### Filesystem Handling
- All btrfs operations use `compress=zstd:3,ssd,discard=async,space_cache=v2`
- Cleanup handlers automatically unmount `/mnt` filesystems after installation
- `genfstab -U` generates UUID-based fstab entries

### Legacy Structure
- `old/` directory contains previous iteration with extensive role collection
- Current structure focuses on core installation functionality
- Legacy roles available for reference: GUI (GNOME, Hyprland, i3), development tools, containers, etc.