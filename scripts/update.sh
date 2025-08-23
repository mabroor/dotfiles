#!/usr/bin/env bash
# Dotfiles update script
# Updates flake inputs and provides rebuild options

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
UPDATE="🔄"

# Script directory and dotfiles root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${CYAN}${ROCKET} Dotfiles Update Script${NC}"
echo -e "${CYAN}========================${NC}"
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

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    print_status "$ERROR" "$RED" "Not in a git repository. Please run from dotfiles directory."
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    print_status "$WARNING" "$YELLOW" "You have uncommitted changes:"
    git status --porcelain
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting update."
        exit 0
    fi
fi

echo ""
print_status "$INFO" "$BLUE" "Current flake inputs:"
nix flake metadata --json | jq -r '.locks.nodes | to_entries[] | select(.key != "root") | "\(.key): \(.value.locked.rev // .value.locked.ref // "N/A")"' | head -10

echo ""
print_status "$UPDATE" "$PURPLE" "Updating flake inputs..."

# Update flake lock file
if run_command "nix flake update" "Flake update"; then
    echo ""
    print_status "$INFO" "$BLUE" "Updated flake inputs:"
    nix flake metadata --json | jq -r '.locks.nodes | to_entries[] | select(.key != "root") | "\(.key): \(.value.locked.rev // .value.locked.ref // "N/A")"' | head -10
    
    echo ""
    print_status "$INFO" "$CYAN" "Changes made to flake.lock:"
    if git diff --name-only | grep -q "flake.lock"; then
        git diff --stat flake.lock
    else
        print_status "$INFO" "$YELLOW" "No changes to flake.lock"
    fi
else
    print_status "$ERROR" "$RED" "Failed to update flake inputs"
    exit 1
fi

# Check flake configuration
echo ""
if run_command "nix flake check" "Configuration validation"; then
    print_status "$SUCCESS" "$GREEN" "Configuration is valid"
else
    print_status "$ERROR" "$RED" "Configuration validation failed"
    echo ""
    print_status "$WARNING" "$YELLOW" "You may need to fix configuration issues before rebuilding"
    exit 1
fi

# Detect system type
SYSTEM_TYPE=""
if [[ "$OSTYPE" == "darwin"* ]]; then
    SYSTEM_TYPE="darwin"
    # Detect hostname for Darwin configurations
    HOSTNAME=$(hostname -s)
elif [[ -f "/etc/NIXOS" ]]; then
    SYSTEM_TYPE="nixos"  
    HOSTNAME="nixos"
else
    SYSTEM_TYPE="linux"
    HOSTNAME="linux"
fi

echo ""
print_status "$INFO" "$BLUE" "Detected system: $SYSTEM_TYPE ($HOSTNAME)"

# Offer to rebuild system
echo ""
echo "Rebuild options:"
echo "1. Skip rebuild (manual rebuild later)"
echo "2. Rebuild system configuration"
echo "3. Rebuild home-manager only" 
echo "4. Rebuild both system and home-manager"

read -p "Select option (1-4): " -n 1 -r REBUILD_OPTION
echo ""

case $REBUILD_OPTION in
    1)
        print_status "$INFO" "$YELLOW" "Skipping rebuild. Run rebuild script manually later."
        ;;
    2)
        echo ""
        print_status "$UPDATE" "$PURPLE" "Rebuilding system configuration..."
        if [[ "$SYSTEM_TYPE" == "darwin" ]]; then
            run_command "darwin-rebuild switch --flake ." "Darwin system rebuild"
        elif [[ "$SYSTEM_TYPE" == "nixos" ]]; then
            run_command "sudo nixos-rebuild switch --flake ." "NixOS system rebuild"
        fi
        ;;
    3)
        echo ""
        print_status "$UPDATE" "$PURPLE" "Rebuilding home-manager configuration..."
        run_command "home-manager switch --flake ." "Home Manager rebuild"
        ;;
    4)
        echo ""
        print_status "$UPDATE" "$PURPLE" "Rebuilding system and home-manager..."
        if [[ "$SYSTEM_TYPE" == "darwin" ]]; then
            run_command "darwin-rebuild switch --flake ." "Darwin system rebuild"
        elif [[ "$SYSTEM_TYPE" == "nixos" ]]; then
            run_command "sudo nixos-rebuild switch --flake ." "NixOS system rebuild"  
        fi
        run_command "home-manager switch --flake ." "Home Manager rebuild"
        ;;
    *)
        print_status "$WARNING" "$YELLOW" "Invalid option. Skipping rebuild."
        ;;
esac

# Offer to commit changes
if git diff-index --quiet HEAD --; then
    print_status "$INFO" "$BLUE" "No changes to commit."
else
    echo ""
    print_status "$INFO" "$BLUE" "Changes detected:"
    git status --porcelain
    echo ""
    read -p "Commit flake.lock updates? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        COMMIT_MSG="chore: update flake inputs

$(git diff --stat flake.lock)

🤖 Generated with update script"
        
        git add flake.lock
        git commit -m "$COMMIT_MSG"
        print_status "$SUCCESS" "$GREEN" "Changes committed"
        
        read -p "Push changes to remote? (y/N): " -n 1 -r  
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git push
            print_status "$SUCCESS" "$GREEN" "Changes pushed to remote"
        fi
    fi
fi

echo ""
print_status "$SUCCESS" "$GREEN" "Update completed successfully!"
echo ""
print_status "$INFO" "$CYAN" "Next steps:"
echo "  • Test your system to ensure everything works correctly"
echo "  • Check applications for any breaking changes"
echo "  • Review updated package versions if needed"
echo "  • Consider running garbage collection: nix-collect-garbage -d"

echo ""
print_status "$ROCKET" "$PURPLE" "Happy hacking!"