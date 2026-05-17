#!/usr/bin/env bash
set -e

# Re-execute with bash if run from fish shell
if [ -n "$FISH_VERSION" ]; then
    exec bash "$0" "$@"
fi

# Interactive Ansible playbook runner with fzf

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
    echo -e "${CYAN}===== Arch Linux System Configuration Runner =====${NC}"
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help           Show this help message"
    echo "  -i, --inventory FILE Specify inventory file directly"
    echo "  -t, --tags TAGS      Specify execution tags directly"
    echo "  -c, --check          Dry run (do not make changes)"
    echo "  -v, --verbose        Verbose output"
    echo ""
    echo "Interactive mode (no arguments):"
    echo "  1. Select inventory file"
    echo "  2. Select execution mode:"
    echo "     • All roles (recommended default) - all roles except init"
    echo "     • Custom role selection - select individual roles"
    echo "     • Single role execution - single role only"
    echo "     • System installation only - init role only"
    echo "  3. Execute Ansible playbook"
    echo ""
    echo "Examples:"
    echo "  $0                              # Interactive mode"
    echo "  $0 -i inventories/sandbox.yml   # Run all roles on sandbox environment"
    echo "  $0 -t base,shell -c             # Dry run for base and shell roles"
    echo "  $0 -t init                      # System installation only"
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
        --preview="bash -c 'echo \"File: inventories/{}.yml\"; echo \"\"; cat inventories/{}.yml | head -20'" \
        --preview-window=right:60%:wrap
    )
    
    if [[ -z "$selected" ]]; then
        echo -e "${YELLOW}⚠️  Selection cancelled${NC}" >&2
        exit 0  
    fi
    
    echo "inventories/${selected}.yml"
}

# Get list of available roles
get_available_roles() {
    if [[ ! -d "roles" ]]; then
        echo -e "${RED}❌ roles directory not found${NC}"
        exit 1
    fi
    
    find roles -maxdepth 1 -type d -not -path roles | sed 's|^roles/||' | sort
}

# Select execution mode
select_execution_mode() {
    echo -e "${BLUE}🚀 Please select execution mode...${NC}" >&2
    
    local modes=(
        "all-roles (All roles execution - recommended default)"
        "custom-roles (Custom role selection)"
        "single-role (Single role execution)"
        "init-only (System installation only)"
    )
    
    local selected_mode
    selected_mode=$(printf '%s\n' "${modes[@]}" | fzf \
        --height=8 \
        --prompt="Mode> " \
        --header="Select execution mode (ENTER: default execution, ESC: exit)" \
        --preview-window=down:4:wrap
    )
    
    if [[ -z "$selected_mode" ]]; then
        echo -e "${YELLOW}⚠️  Execution mode selection cancelled${NC}" >&2
        exit 0
    fi
    
    # Set tags based on selected mode
    case "$selected_mode" in
        *all-roles*)
            echo "all-roles"
            ;;
        *custom-roles*)
            echo "custom-roles"
            ;;
        *single-role*)
            echo "single-role"
            ;;
        *init-only*)
            echo "init"
            ;;
    esac
}

# Select custom roles
select_custom_roles() {
    echo -e "${BLUE}🎯 Please select roles to execute...${NC}" >&2
    
    local roles
    mapfile -t roles < <(get_available_roles)
    
    if [[ ${#roles[@]} -eq 0 ]]; then
        echo -e "${RED}❌ No available roles found${NC}"
        exit 1
    fi
    
    local selected_roles
    selected_roles=$(printf '%s\n' "${roles[@]}" | fzf \
        --multi \
        --height=15 \
        --prompt="Roles> " \
        --header="Select roles to execute (TAB: multi-select, ESC: back)" \
        --preview="bash -c 'find roles/{} -name \"*.yml\" 2>/dev/null | head -5 | while read file; do echo \"  - \$file\"; done'" \
        --preview-window=right:40%:wrap
    )
    
    if [[ -z "$selected_roles" ]]; then
        echo -e "${YELLOW}⚠️  Role selection cancelled${NC}" >&2
        echo "CANCELLED"
        return 0
    fi
    
    echo "$selected_roles" | tr '\n' ','  | sed 's/,$//'
}

# Select single role
select_single_role() {
    echo -e "${BLUE}🎯 Please select single role to execute...${NC}" >&2
    
    local roles
    mapfile -t roles < <(get_available_roles)
    
    if [[ ${#roles[@]} -eq 0 ]]; then
        echo -e "${RED}❌ No available roles found${NC}"
        exit 1
    fi
    
    local selected_role
    selected_role=$(printf '%s\n' "${roles[@]}" | fzf \
        --height=15 \
        --prompt="Role> " \
        --header="Select role to execute (ESC: back)" \
        --preview="bash -c 'find roles/{} -name \"*.yml\" 2>/dev/null | head -5 | while read file; do echo \"  - \$file\"; done'" \
        --preview-window=right:40%:wrap
    )
    
    if [[ -z "$selected_role" ]]; then
        echo -e "${YELLOW}⚠️  Role selection cancelled${NC}" >&2
        echo "CANCELLED"
        return 0
    fi
    
    echo "$selected_role"
}


# Main execution function
run_ansible() {
    local inventory="$1"
    local tags="$2"
    local options="$3"
    
    echo -e "\n${CYAN}===== Execution Configuration Confirmation =====${NC}"
    echo -e "${GREEN}📋 Inventory:${NC} $inventory"
    
    if [[ -z "$tags" ]]; then
        echo -e "${GREEN}🎯 Execution target:${NC} All roles (except init tag)"
    else
        echo -e "${GREEN}🎯 Execution tags:${NC} $tags"
    fi
    
    [[ -n "$options" ]] && echo -e "${GREEN}⚙️  Options:${NC} $options"
    echo ""
    
    # Confirmation prompt
    echo -e "${YELLOW}Execute with this configuration? (y/N)${NC}"
    read -r confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}⚠️  Execution cancelled${NC}"
        exit 0
    fi
    
    # Build Ansible options
    local ansible_opts=()
    
    # Set tags
    if [[ -n "$tags" ]]; then
        ansible_opts+=(--tags "$tags")
    fi
    
    # Set execution options
    if [[ "$options" == *"check"* ]]; then
        ansible_opts+=(--check)
        echo -e "${PURPLE}🧪 Dry run mode (no changes will be made)${NC}"
    fi
    if [[ "$options" == *"verbose"* ]]; then
        ansible_opts+=(-v)
    fi
    if [[ "$options" == *"extra-verbose"* ]]; then
        ansible_opts+=(-vv)
    fi
    
    # Check community.general collection
    echo -e "${BLUE}📦 Checking Ansible collection...${NC}"
    if ! ansible-galaxy collection list 2>/dev/null | grep -q "community.general"; then
        echo -e "${BLUE}📦 Installing community.general...${NC}"
        ansible-galaxy collection install community.general
    fi
    
    # Connection test
    echo -e "${BLUE}🔗 接続テスト...${NC}"
    if ! ansible all -i "$inventory" -m ping --extra-vars "@vars/secret.yml" 2>/dev/null; then
        echo -e "${RED}❌ Connection failed. Please check inventory settings and SSH connection.${NC}"
        exit 1
    fi
    
    # Execute playbook  
    echo -e "${GREEN}🚀 Executing Ansible playbook...${NC}"
    ansible-playbook -i "$inventory" playbook/configure.yml "${ansible_opts[@]}" --extra-vars "@vars/secret.yml" --extra-vars "ansible_become_password={{ default_user_password }}"
    
    echo -e "${GREEN}✅ Completed${NC}"
}

# Main process
main() {
    check_dependencies
    
    # Show help
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        show_help
        exit 0
    fi
    
    echo -e "${CYAN}===== Arch Linux System Configuration Runner =====${NC}"
    
    local inventory=""
    local tags=""
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
            -t|--tags)
                tags="$2"
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
    
    if [[ -z "$tags" ]]; then
        local execution_mode
        execution_mode=$(select_execution_mode)
        
        case "$execution_mode" in
            "all-roles")
                # Execute all roles except init (default behavior)
                tags=""  # No tag specification = execute all except init tag
                ;;
            "custom-roles")
                tags=$(select_custom_roles)
                if [[ "$tags" == "CANCELLED" ]]; then
                    exit 0
                fi
                ;;
            "single-role")
                tags=$(select_single_role)
                if [[ "$tags" == "CANCELLED" ]]; then
                    exit 0
                fi
                ;;
            "init")
                tags="init"
                ;;
            *)
                echo -e "${RED}❌ Unknown execution mode: $execution_mode${NC}"
                exit 1
                ;;
        esac
    fi
    
    # Option settings (command line arguments only)
    [[ "$check_mode" == true ]] && options+="check "
    [[ "$verbose_mode" == true ]] && options+="verbose "
    options=${options% }  # Remove trailing space
    
    # Execute
    run_ansible "$inventory" "$tags" "$options"
}

# Execute script
main "$@"