# Code Style and Conventions

## Language and Comments
- **Use English for all code comments, variable names, and messages**
- Avoid Japanese text in code except for user-facing messages where appropriate
- Write clear, concise comments that explain purpose and logic
- Use consistent naming conventions throughout the codebase

## Role Design Philosophy
- **Simplicity over complexity**: Favor package manager defaults over manual configuration
- **Home use focused**: Designed for personal systems, not enterprise environments
- **Minimal configuration**: Rely on Arch Linux package management for appropriate defaults
- **Inventory-driven**: Machine-specific settings controlled via inventory variables

## Configuration Approach
- **Package installation**: Primary focus on installing correct packages
- **Inline package style**: Use direct package listing with comments instead of variable-based approach
- **AUR module preference**: Use `aur` module instead of `pacman` module for consistency (except init/base roles)
- **Automatic configuration**: Let pacman and package post-install scripts handle configuration
- **Template management**: Use Ansible templates (`.j2` files) in `templates/` directory for configuration files

## Variable Naming
- Role-scoped naming: `rolename.variable`
- Clear, descriptive names that indicate purpose
- Boolean flags for feature toggles (install, enable_service, etc.)

## Task Organization
- Function-based role grouping rather than interface type (CLI/GUI)
- Clear responsibility separation between roles
- Minimal cross-dependencies except clear hierarchical ones
- Use `become: true` for privileged operations
- Add appropriate `notify` statements for handlers requiring service restarts