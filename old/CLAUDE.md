# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Ansible automation project for Arch Linux installation and configuration. The project automates the complete setup from Arch Linux installation media to a fully configured system with UEFI + btrfs + subvolumes architecture.

## Key Architecture Components

### Three-Phase Setup Process
1. **Installation Media Phase**: Run `init.sh` on Arch Linux installation disk to prepare Ansible environment
2. **System Installation Phase**: Execute `install.yml` playbook (init role) from external machine to perform disk partitioning and base system installation
3. **System Configuration Phase**: Execute `configure.yml` playbook (all other roles) to configure the installed system

### Core Roles Structure

- **init role**: Primary role handling disk partitioning, btrfs subvolumes, and chroot system setup
  - `btrfs_partition.yml`: Creates GPT partitions and btrfs subvolumes (@, @home, @.snapshots, @pkg, @log)  
  - `chroot_setup.yml`: Installs base system via arch-chroot
  - `ansible_setup.yml`: Configures Ansible user in new system
  - `cleanup.yml`: Unmounts filesystems after installation

- **base role**: Essential system configuration and package installation
  - Purpose: Core system packages, security, and fundamental services
  - Components: Development tools, network utilities, firewall, system monitoring

- **shell role**: Shell environment and CLI utilities
  - Purpose: Modern shell environment and command-line tools
  - Components: Shell configuration (fish), modern CLI alternatives (bat, exa, fd, ripgrep), terminal utilities
  - Design: Focus on shell environment and CLI workflow enhancement

- **desktop role**: Desktop environment foundation
  - Purpose: Desktop environment installation and base GUI components
  - Components: Desktop environments (GNOME/Hyprland), display managers, fonts, input methods, common GUI utilities
  - Design: Wayland-first, modular component installation with inventory-driven environment selection

- **storage role**: Storage, backup, and encryption tools
  - Purpose: File storage, synchronization, and encryption management
  - Components: Cloud sync (rclone), disk encryption (veracrypt), FUSE configuration
  - Design: Unified storage solution management regardless of interface type

- **office role**: Office and document productivity tools
  - Purpose: Document creation, editing, and office productivity
  - Components: Office suites (LibreOffice), PDF viewers, document utilities
  - Design: Professional document workflow support

- **media role**: Media editing and playback applications
  - Purpose: Media creation, editing, and consumption
  - Components: Image editors (GIMP), vector graphics (Inkscape), media players (VLC), streaming (Spotify)
  - Design: Complete media workflow from creation to consumption

- **development role**: Software development environment
  - Purpose: Programming and development tools
  - Components: IDEs (Visual Studio Code), version control (Git), containers (Docker), development utilities
  - Design: Complete development environment setup

- **cad role**: Computer-aided design and engineering tools
  - Purpose: CAD software and engineering design tools
  - Components: 3D CAD (FreeCAD), 2D CAD (LibreCAD), electronic design (KiCad)
  - Design: Professional design and engineering workflow support

- **container role**: Container runtime and development tools
  - Purpose: Container runtime for application deployment and development
  - Components: Docker, Docker Compose, Buildah, container management tools
  - Design: Independent container infrastructure, separate from development environment

- **development role**: Software development environment
  - Purpose: Programming and development tools (excluding containers)
  - Components: IDEs (Visual Studio Code), version control (Git), development utilities
  - Design: Pure development environment setup, containers handled separately

- **devices role**: Hardware-specific driver and device management
  - Purpose: Install and configure hardware-dependent packages based on inventory specification
  - Components: GPU drivers, audio systems, Bluetooth, printer support
  - Design: Inventory-driven configuration for machine-specific hardware support

- **virtualization role**: Virtual machine infrastructure
  - Purpose: VM management and virtualization tools
  - Components: QEMU, libvirt, virt-manager, VM network configuration
  - Design: Complete virtualization environment setup

- **home role**: User home directory structure and dotfiles
  - Purpose: User environment and dotfiles management
  - Components: Home directory organization, XDG directories, dotfiles deployment
  - Design: Personal user environment customization

## Role Design Philosophy

### General Principles
- **Simplicity over complexity**: Favor package manager defaults over manual configuration
- **Home use focused**: Designed for personal systems, not enterprise environments
- **Minimal configuration**: Rely on Arch Linux package management for appropriate defaults
- **Inventory-driven**: Machine-specific settings controlled via inventory variables

### Configuration Approach
- **Package installation**: Primary focus on installing correct packages
- **Inline package style**: Use direct package listing with comments instead of variable-based approach for better readability and maintenance
- **AUR module preference**: Use `aur` module instead of `pacman` module for consistency (except for init/base roles before yay installation)
- **Automatic configuration**: Let pacman and package post-install scripts handle configuration
- **Manual settings**: Only when absolutely necessary for functionality
- **Avoid micro-management**: Skip detailed configuration files unless required
- **Template management**: Use Ansible templates (`.j2` files) in `templates/` directory for all configuration files instead of inline content

### Hardware Support Strategy
- **Detection-based**: Use hardware detection to determine required packages
- **VM awareness**: Different package sets for virtual vs physical machines
- **Conditional installation**: Install only what's needed based on detected hardware

### GUI Environment Strategy
- **Wayland-first**: Wayland-only approach, no X11 protocol separation needed
- **Modular components**: Separate common utilities, fonts, input methods, desktop environments
- **Shared base**: fcitx5 mandatory, common utilities for all environments
- **Font management**: minimal/full options based on use case
- **Environment-specific**: GNOME with GDM, Hyprland with ly display manager

### Storage Architecture
- EFI System Partition (1GB, FAT32) → `/boot`
- btrfs root partition with subvolumes:
  - `@` → `/` (root filesystem)
  - `@home` → `/home`
  - `@.snapshots` → `/.snapshots`
  - `@pkg` → `/var/cache/pacman/pkg`
  - `@log` → `/var/log`

## Common Commands

### System Installation (from Arch Linux installation media)
```bash
# Interactive installation (recommended)
./install_system.sh

# Direct inventory specification
./install_system.sh -i inventories/sandbox.yml

# Dry run to check configuration
./install_system.sh -c

# Manual execution
ansible-playbook -i inventories/sandbox.yml playbook/install.yml --vault-password-file .vault_pass --extra-vars "@password.yml"
```

### System Configuration (after installation)
```bash
# Interactive configuration (all roles)
./run_playbook.sh

# Direct inventory specification
./run_playbook.sh -i inventories/sandbox.yml

# Dry run
./run_playbook.sh -c

# Specific roles only
./run_playbook.sh -t base,shell

# Manual execution
ansible-playbook -i inventories/sandbox.yml playbook/configure.yml --vault-password-file .vault_pass --extra-vars "@password.yml"
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

# Run system configuration
ansible-playbook -i inventories/sandbox.yml playbook/configure.yml --vault-password-file .vault_pass
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

### Playbook Structure
- `playbook/install.yml`: System installation (init role only) - **WARNING: Destructive operation**
- `playbook/configure.yml`: System configuration (all roles except init) - Safe to run multiple times
- `playbook/main.yml`: Legacy playbook (deprecated) - Kept for backward compatibility

**Execution Scripts:**
- `install_system.sh`: Interactive script for system installation with safety confirmations
- `run_playbook.sh`: Interactive script for system configuration with role selection

## Development Workflow

### Current Development Status
- **Phase**: Infrastructure refactoring completed, ready for feature development
- **Completed Tasks**:
  - Function-based role architecture implementation
  - Variable restructuring to role-scoped naming (`rolename.variable`)
  - Playbook separation into installation and configuration phases
  - Interactive execution scripts with fzf integration
  - Package management standardization (inline style with comments)
  - Handler configuration cleanup and proper notify usage
- **Current Structure**: shell, desktop, storage, office, media, cad, container, development, devices, virtualization, home

### Testing Changes
1. Test system configuration in sandbox environment first: `./run_playbook.sh -c`
2. For installation testing: `./install_system.sh -c` (dry run)
3. Verify partition layout with `lsblk` after successful installation run
4. Check mounted subvolumes in `/mnt` directory structure

### Adding New Tasks
- Add tasks to appropriate files in respective role directories (`roles/{role_name}/tasks/`)
- Use `become: true` for privileged operations
- Follow inline package style with categorized comments instead of variable-based approach
- Add appropriate `notify` statements for handlers that require service restarts or reloads
- Register cleanup handlers for filesystem operations
- Follow existing patterns for btrfs and mount operations
- For `devices` role: Use inventory variables to control hardware-specific installations

### Role Organization Guidelines
- **Function-based grouping**: Roles organized by primary function rather than interface type (CLI/GUI)
- **Clear responsibility separation**: Each role has distinct purpose and scope
- **Minimal cross-dependencies**: Roles should be largely independent except for clear hierarchical dependencies
- **Consistent naming**: Role names reflect primary function (shell, desktop, storage, office, media, cad, container, development, devices, virtualization, home)
- **Variable-controlled execution**: Default role settings are `false` - enable per-machine via inventory variables
- **Single playbook approach**: `playbook/main.yml` serves all machines, controlled by inventory-specific variables

## Important Notes

### Security Considerations
- Target disk specified in inventory will be **completely wiped**
- Ansible user has restricted sudo access (specific commands only) after base role completion
- During installation: temporary full sudo access and root SSH login enabled for automation
- After installation: sudo access limited to essential system management commands only

### Credential and Sensitive Data Handling
- **NEVER read, display, or log files containing credentials** (password.yml, .vault_pass, vars/secret.yml)
- **NEVER output passwords, API keys, or sensitive configuration** to console or logs
- **AVOID reading files with sensitive names** containing: password, pass, secret, key, token, credential
- Use Ansible Vault for all sensitive data storage
- Sensitive files should remain encrypted and never be displayed in plain text

### Filesystem Handling
- All btrfs operations use `compress=zstd:3,ssd,discard=async,space_cache=v2`
- `genfstab -U` generates UUID-based fstab entries

### Legacy Structure
- `old/` directory contains previous iteration with extensive role collection
- Current structure focuses on core installation functionality
- Legacy roles available for reference: GUI (GNOME, Hyprland, i3), development tools, containers, etc.

## Code Style Guidelines

### Language and Comments
- **Use English for all code comments, variable names, and messages**
- Avoid Japanese text in code except for user-facing messages where appropriate
- Write clear, concise comments that explain the purpose and logic
- Use consistent naming conventions throughout the codebase

### Code Organization
- Follow existing patterns and conventions in the codebase
- Use meaningful function and variable names that describe their purpose
- Keep functions focused on a single responsibility
- Group related functionality together