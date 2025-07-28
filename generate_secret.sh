#!/usr/bin/env bash
set -e

# Re-execute with bash if run from fish shell
if [ -n "$FISH_VERSION" ]; then
    exec bash "$0" "$@"
fi

# Generate vars/secret.yml script

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Variables
SECRET_FILE="vars/secret.yml"

# Show usage information
show_help() {
    echo -e "${CYAN}===== Generate vars/secret.yml =====${NC}"
    echo "Generate password configuration file for Ansible automation."
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  -f, --force          Overwrite existing secret.yml file"
    echo ""
    echo "This script will:"
    echo "  1. Prompt for default user password"
    echo "  2. Generate password hash using openssl passwd -6"
    echo "  3. Create vars/secret.yml with both plain and hashed passwords"
    echo ""
    echo -e "${YELLOW}⚠️  Note: vars/secret.yml should be excluded from git repository${NC}"
}

# Check if openssl is available
check_dependencies() {
    if ! command -v openssl &> /dev/null; then
        echo -e "${RED}❌ openssl not found. Please install openssl.${NC}"
        echo "Arch Linux: sudo pacman -S openssl"
        exit 1
    fi
}

# Create vars directory if it doesn't exist
ensure_vars_directory() {
    if [ ! -d "vars" ]; then
        echo -e "${BLUE}📁 Creating vars directory...${NC}"
        mkdir -p vars
    fi
}

# Check if secret.yml already exists
check_existing_file() {
    if [ -f "$SECRET_FILE" ] && [ "$FORCE" != "true" ]; then
        echo -e "${YELLOW}⚠️  $SECRET_FILE already exists.${NC}"
        echo "Use --force to overwrite, or remove the file manually."
        exit 1
    fi
}

# Prompt for password with confirmation
prompt_password() {
    echo -e "${CYAN}🔐 Enter default user password:${NC}"
    
    while true; do
        echo -n "Password: "
        read -s password1
        echo
        
        if [ -z "$password1" ]; then
            echo -e "${RED}❌ Password cannot be empty. Please try again.${NC}"
            continue
        fi
        
        echo -n "Confirm password: "
        read -s password2
        echo
        
        if [ "$password1" = "$password2" ]; then
            USER_PASSWORD="$password1"
            break
        else
            echo -e "${RED}❌ Passwords do not match. Please try again.${NC}"
        fi
    done
}

# Generate password hash
generate_password_hash() {
    echo -e "${BLUE}🔨 Generating password hash...${NC}"
    PASSWORD_HASH=$(openssl passwd -6 "$USER_PASSWORD")
    
    if [ $? -ne 0 ] || [ -z "$PASSWORD_HASH" ]; then
        echo -e "${RED}❌ Failed to generate password hash${NC}"
        exit 1
    fi
}

# Create secret.yml file
create_secret_file() {
    echo -e "${BLUE}📝 Creating $SECRET_FILE...${NC}"
    
    cat > "$SECRET_FILE" << EOF
---
# Generated secret configuration file
# This file contains sensitive information and should NOT be committed to git

# Default user password (plain text for automation scripts)
default_user_password: "$USER_PASSWORD"

# Default user password (hashed for /etc/shadow)
default_user_password_hash: "$PASSWORD_HASH"

# Ansible connection passwords
ansible_sudo_pass: "$USER_PASSWORD"
ansible_ssh_pass: "$USER_PASSWORD"
EOF

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Successfully created $SECRET_FILE${NC}"
        echo -e "${YELLOW}📄 File contents:${NC}"
        echo "---"
        echo "default_user_password: \"[HIDDEN]\""
        echo "default_user_password_hash: \"$PASSWORD_HASH\""
        echo "ansible_sudo_pass: \"[HIDDEN]\""
        echo "ansible_ssh_pass: \"[HIDDEN]\""
        echo ""
        echo -e "${YELLOW}⚠️  Important: Add 'vars/secret.yml' to .gitignore to avoid committing passwords${NC}"
    else
        echo -e "${RED}❌ Failed to create $SECRET_FILE${NC}"
        exit 1
    fi
}

# Main execution
main() {
    # Parse command line arguments
    FORCE="false"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -f|--force)
                FORCE="true"
                shift
                ;;
            *)
                echo -e "${RED}❌ Unknown option: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
    
    echo -e "${CYAN}===== Generate vars/secret.yml =====${NC}"
    echo ""
    
    check_dependencies
    ensure_vars_directory
    check_existing_file
    prompt_password
    generate_password_hash
    create_secret_file
    
    echo -e "${GREEN}🎉 Secret file generation completed!${NC}"
}

# Execute main function
main "$@"