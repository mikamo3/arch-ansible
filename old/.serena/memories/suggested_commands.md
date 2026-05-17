# Suggested Commands

## System Installation Commands
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

## System Configuration Commands
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

## Installation Media Setup
```bash
# On Arch Linux installation disk
./init.sh

# Or download from host machine
curl -O http://HOST_IP:8000/init.sh && chmod +x init.sh && ./init.sh
```

## Development Commands
```bash
# Install required collection
ansible-galaxy collection install community.general

# Test connectivity
ansible sandbox -i inventories/sandbox.yml -m ping

# Generate secrets
./generate_secret.sh

# Start local HTTP server for init.sh distribution
python -m http.server 8000
```

## Testing Commands
```bash
# Test changes in sandbox first
./run_playbook.sh -c

# Check partition layout after installation
lsblk

# Verify mount points
findmnt
```