# Task Completion Guidelines

## When a Task is Completed

### Testing Requirements
1. **Test system configuration in sandbox environment first**: `./run_playbook.sh -c`
2. **For installation testing**: `./install_system.sh -c` (dry run)
3. **Verify partition layout** with `lsblk` after successful installation run
4. **Check mounted subvolumes** in `/mnt` directory structure

### Code Quality Checks
- Follow existing patterns for btrfs and mount operations
- Register cleanup handlers for filesystem operations
- Follow existing patterns and conventions in the codebase
- Use meaningful function and variable names that describe their purpose
- Keep functions focused on single responsibility

### Security Considerations
- **NEVER read, display, or log files containing credentials** (password.yml, .vault_pass, vars/secret.yml)
- **NEVER output passwords, API keys, or sensitive configuration** to console or logs
- **AVOID reading files with sensitive names** containing: password, pass, secret, key, token, credential
- Ensure sensitive files remain encrypted and never displayed in plain text

### Documentation Requirements
- **NEVER proactively create documentation files** (*.md) or README files
- Only create documentation files if explicitly requested by the User
- Update inline comments when making significant changes
- Follow English-only rule for all code comments and variable names

### Final Verification
- Run dry-run tests before applying changes
- Verify all conditional logic works correctly with inventory variables
- Ensure handlers are properly triggered where needed
- Check that role dependencies are correctly maintained