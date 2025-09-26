#!/usr/bin/env bash

# Test script for SSH Zellij issues
set -euo pipefail

echo "=== SSH Zellij Test Script ==="
echo "This script tests Zellij functionality over SSH"
echo

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to test a command
test_command() {
    local cmd="$1"
    local desc="$2"

    echo -n "Testing: $desc... "
    if eval "$cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ SUCCESS${NC}"
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        return 1
    fi
}

# Function to run command via SSH
ssh_test() {
    local cmd="$1"
    local desc="$2"

    echo -n "SSH Test: $desc... "
    if ssh -o ConnectTimeout=5 localhost "$cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ SUCCESS${NC}"
        return 0
    else
        echo -e "${RED}✗ FAILED${NC}"
        return 1
    fi
}

echo "=== Local Tests ==="
echo

# Test local environment
test_command "which zellij" "Zellij in PATH"
test_command "test -n \"\$XDG_RUNTIME_DIR\"" "XDG_RUNTIME_DIR set"
test_command "test -w \"\$XDG_RUNTIME_DIR\"" "XDG_RUNTIME_DIR writable"
test_command "zellij list-sessions" "List sessions locally"

echo
echo "=== SSH Tests ==="
echo

# Test SSH environment
ssh_test "which zellij" "Zellij available via SSH"
ssh_test "echo \$XDG_RUNTIME_DIR | grep -q ." "XDG_RUNTIME_DIR set via SSH"
ssh_test "test -w \"\$XDG_RUNTIME_DIR\"" "XDG_RUNTIME_DIR writable via SSH"

echo
echo "=== Detailed SSH Session Test ==="
echo "Running: ssh localhost 'bash -c \"export XDG_RUNTIME_DIR=/run/user/\$(id -u); zellij list-sessions\"'"
echo

if ssh localhost 'bash -c "export XDG_RUNTIME_DIR=/run/user/$(id -u); zellij list-sessions"' 2>&1; then
    echo -e "${GREEN}✓ Manual XDG_RUNTIME_DIR export works${NC}"
else
    echo -e "${RED}✗ Even with manual export, Zellij fails${NC}"
    echo
    echo -e "${YELLOW}Debug information:${NC}"
    ssh localhost 'bash -c "
        echo \"User: $(whoami)\"
        echo \"UID: $(id -u)\"
        echo \"XDG_RUNTIME_DIR: $XDG_RUNTIME_DIR\"
        echo \"PATH: $PATH\" | head -c 100
        echo \"...\"
        echo \"Checking /run/user/$(id -u):\"
        ls -lad /run/user/$(id -u) 2>/dev/null || echo \"Does not exist\"
        echo \"Checking for zellij wrapper:\"
        ls -la $HOME/.local/bin/zellij-safe 2>/dev/null || echo \"Wrapper not found\"
    "'
fi

echo
echo "=== Testing with Wrapper ==="
echo

# Test if wrapper exists
if [ -f "$HOME/.local/bin/zellij-safe" ]; then
    echo -e "${GREEN}✓ Wrapper exists${NC}"

    echo "Testing wrapper locally..."
    if "$HOME/.local/bin/zellij-safe" list-sessions >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Wrapper works locally${NC}"
    else
        echo -e "${RED}✗ Wrapper fails locally${NC}"
    fi

    echo "Testing wrapper via SSH..."
    if ssh localhost '$HOME/.local/bin/zellij-safe list-sessions' >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Wrapper works via SSH${NC}"
    else
        echo -e "${RED}✗ Wrapper fails via SSH${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Wrapper not found. Run: home-manager switch --flake ~/src/github.com/mabroor/dotfiles${NC}"
fi

echo
echo "=== Recommendations ==="
echo

if [ ! -f "$HOME/.local/bin/zellij-safe" ]; then
    echo "1. Apply the home-manager configuration:"
    echo "   home-manager switch --flake ~/src/github.com/mabroor/dotfiles"
fi

echo "2. Ensure your login shell is bash:"
echo "   Current shell: $(getent passwd $USER | cut -d: -f7)"
if [[ "$(getent passwd $USER | cut -d: -f7)" != *"bash"* ]]; then
    echo "   ${YELLOW}Change to bash: chsh -s $(which bash)${NC}"
fi

echo "3. Test SSH after applying changes:"
echo "   ssh localhost"
echo "4. If issues persist, check systemd-logind:"
echo "   loginctl show-user $USER"