#!/usr/bin/env bash
set -e

# Re-execute with bash if run from fish shell
if [ -n "$FISH_VERSION" ]; then
    exec bash "$0" "$@"
fi

# Arch Linux System Installation Runner

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check fzf availability
check_dependencies() {
    if ! command -v fzf &> /dev/null; then
        echo -e "${RED}❌ fzf not found. Please install fzf.${NC}"
        echo "Arch Linux: sudo pacman -S fzf"
        exit 1
    fi
}

# Show usage information
show_help() {
    echo -e "${CYAN}===== Arch Linux System Installation Runner =====${NC}"
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo -e "${YELLOW}⚠️  WARNING: This will completely wipe the target disk!${NC}"
    echo ""
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  -i, --inventory FILE Specify inventory file directly"
    echo "  -c, --check          Dry run (do not make changes)"
    echo "  -v, --verbose        Verbose output"
    echo ""
    echo "Interactive mode (no arguments):"
    echo "  1. Select inventory file"
    echo "  2. Confirm target disk will be wiped"
    echo "  3. Execute system installation"
    echo ""
    echo "Examples:"
    echo "  $0                              # Interactive mode"
    echo "  $0 -i inventories/sandbox.yml   # Install on sandbox environment"
    echo "  $0 -c                           # Dry run to check configuration"
    echo ""
    echo -e "${RED}NOTE: This script should only be run from Arch Linux installation media!${NC}"
    echo ""
}

# Select inventory file
select_inventory() {
    echo -e "${BLUE}📁 Please select inventory file...${NC}" >&2
    
    if [[ ! -d "inventories" ]]; then
        echo -e "${RED}❌ inventories directory not found${NC}"
        exit 1
    fi
    
    local inventory_files=(inventories/*.yml)
    if [[ ${#inventory_files[@]} -eq 0 || ! -f "${inventory_files[0]}" ]]; then
        echo -e "${RED}❌ No inventory files (.yml) found${NC}"
        exit 1
    fi
    
    local selected
    selected=$(printf '%s\n' "${inventory_files[@]}" | sed 's|^inventories/||; s|\.yml$||' | fzf \
        --height=10 \
        --prompt="Inventory> " \
        --header="Select inventory (ESC: exit)" \
        --preview="echo 'File: inventories/{}.yml'; echo ''; cat inventories/{}.yml | head -20" \
        --preview-window=right:60%:wrap
    )
    
    if [[ -z "$selected" ]]; then
        echo -e "${YELLOW}⚠️  Selection cancelled${NC}" >&2
        exit 0  
    fi
    
    echo "inventories/${selected}.yml"
}

# Confirm destructive operation
confirm_installation() {
    local inventory="$1"
    
    echo -e "\n${CYAN}===== Installation Configuration Confirmation =====${NC}"
    echo -e "${GREEN}📋 Inventory:${NC} $inventory"
    echo -e "${GREEN}🚀 Playbook:${NC} playbook/install.yml (system installation)"
    echo ""
    
    # Extract target disk from inventory
    local target_disk
    target_disk=$(grep "target_disk:" "$inventory" | head -1 | awk '{print $2}' || echo "NOT FOUND")
    
    echo -e "${RED}⚠️  WARNING: DESTRUCTIVE OPERATION ⚠️${NC}"
    echo -e "${RED}Target disk: ${target_disk}${NC}"
    echo -e "${RED}This will COMPLETELY WIPE the target disk and all its data!${NC}"
    echo ""
    
    # Confirmation prompt
    echo -e "${YELLOW}Type 'WIPE' to confirm disk destruction, or anything else to cancel:${NC}"
    read -r confirm
    if [[ "$confirm" != "WIPE" ]]; then
        echo -e "${YELLOW}⚠️  Installation cancelled for safety${NC}"
        exit 0
    fi
    
    echo -e "${PURPLE}🔥 Proceeding with disk wipe and system installation...${NC}"
}

# Main execution function
run_installation() {
    local inventory="$1"
    local options="$2"
    
    # Build Ansible options
    local ansible_opts=()
    
    # Set execution options
    if [[ "$options" == *"check"* ]]; then
        ansible_opts+=(--check)
        echo -e "${PURPLE}🧪 Dry run mode (no changes will be made)${NC}"
    fi
    if [[ "$options" == *"verbose"* ]]; then
        ansible_opts+=(-v)
    fi
    
    # Check community.general collection
    echo -e "${BLUE}📦 Checking Ansible collection...${NC}"
    if ! ansible-galaxy collection list 2>/dev/null | grep -q "community.general"; then
        echo -e "${BLUE}📦 Installing community.general...${NC}"
        ansible-galaxy collection install community.general
    fi
    
    # Connection test
    echo -e "${BLUE}🔗 Testing connection...${NC}"
    if ! ansible all -i "$inventory" -m ping --vault-password-file .vault_pass --extra-vars "@password.yml" 2>/dev/null; then
        echo -e "${RED}❌ Connection failed. Please check inventory settings and SSH connection.${NC}"
        exit 1
    fi
    
    # Execute playbook
    echo -e "${GREEN}🚀 Executing system installation...${NC}"
    ansible-playbook -i "$inventory" playbook/install.yml "${ansible_opts[@]}" --vault-password-file .vault_pass --extra-vars "@password.yml"
    
    echo -e "${GREEN}✅ System installation completed${NC}"
    echo -e "${CYAN}Next step: Use ./run_playbook.sh to configure the installed system${NC}"
}

# Main process
main() {
    check_dependencies
    
    # Show help
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        show_help
        exit 0
    fi
    
    echo -e "${CYAN}===== Arch Linux System Installation Runner =====${NC}"
    
    local inventory=""
    local options=""
    local check_mode=false
    local verbose_mode=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -i|--inventory)
                inventory="$2"
                shift 2
                ;;
            -c|--check)
                check_mode=true
                shift
                ;;
            -v|--verbose)
                verbose_mode=true
                shift
                ;;
            *)
                echo -e "${RED}❌ Unknown option: $1${NC}"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Interactive mode
    if [[ -z "$inventory" ]]; then
        inventory=$(select_inventory)
    fi
    
    # Option settings (command line arguments only)
    [[ "$check_mode" == true ]] && options+="check "
    [[ "$verbose_mode" == true ]] && options+="verbose "
    options=${options% }  # Remove trailing space
    
    # Confirm destructive operation (skip in check mode)
    if [[ "$check_mode" != true ]]; then
        confirm_installation "$inventory"
    fi
    
    # Execute
    run_installation "$inventory" "$options"
}

# Execute script
main "$@"