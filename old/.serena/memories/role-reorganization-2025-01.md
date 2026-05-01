# Role Reorganization and Cleanup Session (2025-01)

## Major Changes Completed

### Inventory Structure Reorganization
- **Fixed group naming**: Changed all inventory files from generic "sandbox:" to machine-specific names:
  - `mainpc.yml`: mainpc group (main physical machine)
  - `ai.yml`: kamo3ai group (AI workstation with NVIDIA GPU)  
  - `nucbox.yml`: nucbox group (Intel NUC testing machine)
  - `sandbox.yml`: sandbox group (VM testing environment)
- **Template adoption**: Moved NetworkManager static network configuration from inline content to proper template (`roles/init/templates/static-network.nmconnection.j2`)

### Role Consolidation and Simplification
- **Home role elimination**: Migrated kawazu dotfiles manager functionality from home role to shell role as `tasks/dotfiles.yml`
- **CLI tools reorganization**: Moved domain-specific tools from shell role to appropriate roles:
  - Development tools (jq, yq, difftastic, ghq, github-cli) → development role
  - Container tools (lazydocker, ctop) → container role  
  - Cloud sync (rclone) → confirmed already in storage role
- **Configuration flag simplification**: Removed self-evident configuration options:
  - Container role: removed `enable_service`, `add_user_to_group`, `tools` flags
  - Virtualization role: removed `gui.install_virt_manager`, `user.add_to_libvirt_group`, `services` flags
  - Development role: consolidated all individual flags into single `install` flag

### Desktop Environment Enhancements
- **Input method expansion**: Added fcitx5-mozc-ut support with exclusive installation logic (either fcitx5-mozc OR fcitx5-mozc-ut)
- **Display manager configuration**: Created comprehensive LY display manager template (`roles/desktop/templates/ly.config.ini.j2`)
- **VLC relocation**: Moved VLC packages from desktop to media role's playback section for better organization
- **Condition optimization**: Removed duplicate when conditions between main.yml and imported task files

### Systematic Role Analysis Pattern
Established and applied consistent analysis methodology across all roles:
1. **Directory structure verification**: Check for unused directories and files
2. **Handler usage analysis**: Identify and remove unused handlers
3. **Default variable validation**: Verify all defaults are actually used
4. **File inclusion confirmation**: Ensure all task files are properly imported
5. **Variable dependency check**: Find variables used without defaults

### Major Cleanup Operations
- **Empty handler removal**: Deleted unused handler files and directories from:
  - shell, development, storage, cad, media, office roles
- **Empty directory cleanup**: Removed unused template and files directories:
  - shell/templates, shell/files, devices/templates, devices/files
- **Mise tool migration**: Moved mise (development environment manager) from shell to development role

## Current Role Structure

### Core Roles (Installation Phase)
- **init**: System installation, disk partitioning, chroot setup
- **base**: Essential packages, security, fundamental services

### Function-Based Roles (Configuration Phase)  
- **shell**: CLI environment (fish, modern CLI tools, dotfiles with kawazu)
- **desktop**: Desktop environments (GNOME/Hyprland), display managers, input methods
- **storage**: Cloud sync (rclone), encryption (veracrypt), FUSE configuration
- **office**: Document productivity (LibreOffice, PDF viewers)
- **media**: Media tools (CLI tools, playback including VLC, editing)
- **cad**: CAD and engineering design tools
- **container**: Docker runtime and management tools (lazydocker, ctop)
- **development**: Programming environment (VS Code, git tools, mise, CLI dev tools)
- **devices**: Hardware-specific drivers (GPU, audio, Bluetooth, printer)
- **virtualization**: VM infrastructure (QEMU, libvirt, virt-manager)

## Key Principles Established

### Configuration Philosophy
- **Simplicity over complexity**: Favor package defaults over manual configuration
- **Inventory-driven**: Machine-specific settings via inventory variables  
- **Single responsibility**: Each role has clear, distinct purpose
- **Template usage**: Use `.j2` templates instead of inline content for configuration files

### Variable Management
- **Role-scoped naming**: All variables use `rolename.variable` pattern
- **Boolean simplification**: Single install flags instead of granular options
- **Self-evident removal**: Eliminate obvious configuration options

### Code Quality
- **Systematic analysis**: Apply consistent cleanup methodology
- **Unused component removal**: Delete empty handlers, directories, placeholder files
- **Logical organization**: Group related functionality appropriately

## Impact and Benefits
- **Improved maintainability**: Clear role boundaries and responsibilities
- **Reduced complexity**: Fewer configuration options to manage
- **Better organization**: Tools placed in contextually appropriate roles  
- **Cleaner codebase**: Removal of unused components and directories
- **Consistent patterns**: Standardized variable naming and role structure