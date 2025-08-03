# Project Overview

This is an Ansible automation project for Arch Linux installation and configuration. The project automates complete setup from Arch Linux installation media to a fully configured system with UEFI + btrfs + subvolumes architecture.

## Purpose
- Complete Arch Linux system automation from installation to configuration
- Three-phase setup: Installation Media → System Installation → System Configuration
- Support for multiple machine configurations (mainpc, portable, ai, sandbox)
- UEFI + btrfs + subvolumes architecture

## Tech Stack
- **Infrastructure**: Ansible automation framework
- **Target OS**: Arch Linux
- **Filesystem**: btrfs with subvolumes
- **Boot**: UEFI
- **Package Management**: pacman + AUR (via yay)
- **Language**: YAML (Ansible playbooks), Bash (shell scripts)

## Core Architecture
Three-phase setup process:
1. **Installation Media Phase**: `init.sh` on Arch Linux installation disk
2. **System Installation Phase**: `install.yml` playbook (init role) for disk partitioning and base system
3. **System Configuration Phase**: `configure.yml` playbook (all other roles) for system configuration

## Key Components
- **Roles**: Function-based organization (shell, desktop, storage, office, media, cad, container, development, devices, virtualization, home)
- **Inventories**: Machine-specific configurations
- **Playbooks**: Separated installation and configuration phases
- **Scripts**: Interactive execution with safety confirmations