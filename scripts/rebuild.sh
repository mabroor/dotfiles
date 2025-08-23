#!/usr/bin/env bash
# Dotfiles rebuild script  
# Rebuilds system and home-manager configurations

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Emojis
SUCCESS="✅"
ERROR="❌"
WARNING="⚠️ "
INFO="ℹ️ "
ROCKET="🚀"
HAMMER="🔨"

# Script directory and dotfiles root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${CYAN}${HAMMER} Dotfiles Rebuild Script${NC}"
echo -e "${CYAN}===========================${NC}"
echo ""

# Function to print colored output
print_status() {
    local emoji="$1"
    local color="$2"
    local message="$3"
    echo -e "${color}${emoji} ${message}${NC}"
}

# Function to run command with status
run_command() {
    local command="$1"
    local description="$2"
    
    echo -e "${BLUE}Running: ${description}${NC}"
    if eval "$command"; then
        print_status "$SUCCESS" "$GREEN" "$description completed"
        return 0
    else
        print_status "$ERROR" "$RED" "$description failed"
        return 1  
    fi
}

# Change to dotfiles directory
cd "$DOTFILES_ROOT"

# Check if we're in the right directory
if [ ! -f "flake.nix" ]; then
    print_status "$ERROR" "$RED" "flake.nix not found. Please run from dotfiles directory."
    exit 1
fi

# Detect system type and hostname
SYSTEM_TYPE=""
HOSTNAME=""

if [[ "$OSTYPE" == "darwin"* ]]; then
    SYSTEM_TYPE="darwin"
    HOSTNAME=$(hostname -s)
    
    # Validate Darwin configuration exists
    if [[ ! -d "hosts/$HOSTNAME" ]]; then
        print_status "$WARNING" "$YELLOW" "Host configuration not found for $HOSTNAME"
        echo "Available Darwin configurations:"
        find hosts -name "default.nix" -path "*/darwin*" -o -path "*/*darwin*" 2>/dev/null | sed 's|hosts/||g' | sed 's|/default.nix||g' || echo "  None found"
        echo ""
        read -p "Enter hostname to use: " HOSTNAME
    fi
elif [[ -f "/etc/NIXOS" ]]; then
    SYSTEM_TYPE="nixos"
    HOSTNAME="nixos"
else
    print_status "$ERROR" "$RED" "Unsupported system type"
    exit 1
fi

echo ""
print_status "$INFO" "$BLUE" "System: $SYSTEM_TYPE"
print_status "$INFO" "$BLUE" "Hostname: $HOSTNAME"

# Parse command line arguments
REBUILD_SYSTEM=true
REBUILD_HOME=true
DRY_RUN=false
SHOW_TRACE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --system-only)
            REBUILD_HOME=false
            shift
            ;;
        --home-only)
            REBUILD_SYSTEM=false  
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --show-trace)
            SHOW_TRACE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --system-only    Rebuild only system configuration"
            echo "  --home-only      Rebuild only home-manager configuration"  
            echo "  --dry-run        Show what would be built without building"
            echo "  --show-trace     Show detailed trace output"
            echo "  --help, -h       Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                    # Rebuild both system and home"
            echo "  $0 --system-only     # Rebuild only system" 
            echo "  $0 --dry-run         # Preview changes"
            exit 0
            ;;
        *)
            print_status "$WARNING" "$YELLOW" "Unknown argument: $1"
            shift
            ;;
    esac
done

# Prepare command flags
COMMON_FLAGS="--flake ."
if [[ "$DRY_RUN" == "true" ]]; then
    COMMON_FLAGS="$COMMON_FLAGS --dry-run"
fi
if [[ "$SHOW_TRACE" == "true" ]]; then
    COMMON_FLAGS="$COMMON_FLAGS --show-trace"
fi

echo ""
if [[ "$DRY_RUN" == "true" ]]; then
    print_status "$INFO" "$YELLOW" "DRY RUN MODE - No changes will be made"
    echo ""
fi

# Validate configuration before rebuilding
echo ""
print_status "$INFO" "$PURPLE" "Validating configuration..."
if run_command "nix flake check --no-build" "Configuration validation"; then
    print_status "$SUCCESS" "$GREEN" "Configuration is valid"
else
    print_status "$ERROR" "$RED" "Configuration validation failed"
    echo ""
    print_status "$WARNING" "$YELLOW" "Fix configuration errors before rebuilding"
    exit 1
fi

# System rebuild
if [[ "$REBUILD_SYSTEM" == "true" ]]; then
    echo ""
    print_status "$HAMMER" "$PURPLE" "Rebuilding system configuration..."
    
    if [[ "$SYSTEM_TYPE" == "darwin" ]]; then
        DARWIN_CMD="darwin-rebuild switch $COMMON_FLAGS"
        if ! run_command "$DARWIN_CMD" "Darwin system rebuild"; then
            print_status "$ERROR" "$RED" "System rebuild failed"
            exit 1
        fi
    elif [[ "$SYSTEM_TYPE" == "nixos" ]]; then
        NIXOS_CMD="sudo nixos-rebuild switch $COMMON_FLAGS"
        if ! run_command "$NIXOS_CMD" "NixOS system rebuild"; then
            print_status "$ERROR" "$RED" "System rebuild failed"
            exit 1
        fi
    fi
    
    print_status "$SUCCESS" "$GREEN" "System rebuild completed"
fi

# Home Manager rebuild
if [[ "$REBUILD_HOME" == "true" ]]; then
    echo ""
    print_status "$HAMMER" "$PURPLE" "Rebuilding home-manager configuration..."
    
    HOME_CMD="home-manager switch $COMMON_FLAGS"
    if ! run_command "$HOME_CMD" "Home Manager rebuild"; then
        print_status "$ERROR" "$RED" "Home Manager rebuild failed"
        exit 1
    fi
    
    print_status "$SUCCESS" "$GREEN" "Home Manager rebuild completed"
fi

# Show generation information
echo ""
print_status "$INFO" "$BLUE" "System generations:"
if [[ "$SYSTEM_TYPE" == "darwin" ]]; then
    darwin-rebuild --list-generations | tail -5 || echo "Could not list generations"
elif [[ "$SYSTEM_TYPE" == "nixos" ]]; then
    sudo nixos-rebuild list-generations | tail -5 || echo "Could not list generations"
fi

if command -v home-manager >/dev/null 2>&1; then
    echo ""
    print_status "$INFO" "$BLUE" "Home Manager generations:" 
    home-manager generations | tail -5 || echo "Could not list Home Manager generations"
fi

# Cleanup suggestions
echo ""
print_status "$INFO" "$CYAN" "Post-rebuild suggestions:"
echo "  • Test applications to ensure everything works"
echo "  • Check for any configuration warnings or deprecations"  
echo "  • Consider running garbage collection to free space:"
echo "    - nix-collect-garbage -d (delete old generations)"
echo "    - nix store gc (garbage collect store)"
if [[ "$SYSTEM_TYPE" == "darwin" ]]; then
    echo "    - darwin-rebuild --rollback (if issues occur)"
elif [[ "$SYSTEM_TYPE" == "nixos" ]]; then
    echo "    - sudo nixos-rebuild --rollback (if issues occur)"
fi

echo ""
if [[ "$DRY_RUN" == "true" ]]; then
    print_status "$INFO" "$YELLOW" "Dry run completed. No changes were made."
else
    print_status "$SUCCESS" "$GREEN" "Rebuild completed successfully!"
fi

echo ""
print_status "$ROCKET" "$PURPLE" "Happy hacking!"