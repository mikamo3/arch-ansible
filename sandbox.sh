#!/bin/bash
# Sandbox deployment and testing script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="$SCRIPT_DIR"

echo "===== Arch Linux Ansible Sandbox Deployment ====="
echo

# Help function
show_help() {
    echo "Usage: $0 [OPTIONS] [COMMANDS]"
    echo
    echo "OPTIONS:"
    echo "  -h, --help          Show this help"
    echo "  -v, --verbose       Verbose output"
    echo "  -c, --check         Check mode (dry run)"
    echo "  -t, --tags TAGS     Run specific tags only"
    echo "  -s, --skip TAGS     Skip specific tags"
    echo
    echo "COMMANDS:"
    echo "  deploy              Full sandbox deployment"
    echo "  test                Run role testing only"
    echo "  network             Test network role only"
    echo "  development         Test development role only"
    echo "  base                Test base role only"
    echo "  clean               Clean up sandbox environment"
    echo
    echo "EXAMPLES:"
    echo "  $0 deploy                    # Full deployment"
    echo "  $0 deploy -t base,cui        # Deploy base and cui roles only"
    echo "  $0 test                      # Run tests on deployed environment"
    echo "  $0 network -c                # Test network role (dry run)"
    echo
}

# Default values
VERBOSE=""
CHECK_MODE=""
TAGS=""
SKIP_TAGS=""
INVENTORY="inventories/sandbox.yml"
PLAYBOOK="playbook/site.yml"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--verbose)
            VERBOSE="-v"
            shift
            ;;
        -c|--check)
            CHECK_MODE="--check"
            shift
            ;;
        -t|--tags)
            TAGS="--tags $2"
            shift 2
            ;;
        -s|--skip)
            SKIP_TAGS="--skip-tags $2"
            shift 2
            ;;
        deploy)
            COMMAND="deploy"
            shift
            ;;
        test)
            COMMAND="test"
            shift
            ;;
        network)
            COMMAND="network"
            TAGS="--tags network"
            shift
            ;;
        development)
            COMMAND="development"
            TAGS="--tags development"
            shift
            ;;
        base)
            COMMAND="base"
            TAGS="--tags base"
            shift
            ;;
        clean)
            COMMAND="clean"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Default command
if [ -z "$COMMAND" ]; then
    COMMAND="deploy"
fi

cd "$ANSIBLE_DIR"

case "$COMMAND" in
    deploy)
        echo "🚀 Deploying sandbox environment..."
        echo "Target: $(ansible-inventory -i $INVENTORY --list | jq -r '.sandbox.hosts[]')"
        echo
        
        ansible-playbook -i "$INVENTORY" "$PLAYBOOK" \
            -e "machine_profile=sandbox" \
            $VERBOSE $CHECK_MODE $TAGS $SKIP_TAGS
        
        echo
        echo "✅ Sandbox deployment complete!"
        echo "📋 Next steps:"
        echo "   1. Reboot VMs to apply network settings"
        echo "   2. Connect via new IPs"
        echo "   3. Run: $0 test"
        ;;
        
    test)
        echo "🧪 Running sandbox tests..."
        ansible all -i "$INVENTORY" -m shell \
            -a "/home/sandbox/sandbox_tests.sh" \
            $VERBOSE
        ;;
        
    network|development|base)
        echo "🔧 Testing $COMMAND role..."
        ansible-playbook -i "$INVENTORY" "$PLAYBOOK" \
            -e "machine_profile=sandbox" \
            $VERBOSE $CHECK_MODE $TAGS $SKIP_TAGS
        ;;
        
    clean)
        echo "🧹 Cleaning sandbox environment..."
        echo "This will reset sandbox VMs to base state."
        read -p "Continue? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Add cleanup commands here
            echo "Manual cleanup required:"
            echo "1. Revert VM snapshots"
            echo "2. Or reinstall base OS"
        fi
        ;;
esac
