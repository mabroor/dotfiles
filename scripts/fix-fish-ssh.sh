#!/usr/bin/env bash

# Script to ensure Fish works properly in SSH/su sessions
# This should be run after applying the home-manager configuration

set -euo pipefail

echo "=== Fixing Fish SSH/su environment issues ==="
echo

# Check current shell
echo "Current default shell: $(getent passwd $USER | cut -d: -f7)"

# Ensure bash is the login shell (it will exec to fish)
if [[ "$(getent passwd $USER | cut -d: -f7)" != *"bash"* ]]; then
    echo "WARNING: Your default shell is not bash."
    echo "For the fix to work properly, your login shell should be bash,"
    echo "which will then automatically start Fish with the proper environment."
    echo
    echo "To fix this, run:"
    echo "  chsh -s $(which bash)"
    echo
fi

# Check if home-manager is activated
if [ ! -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
    echo "WARNING: Home-manager doesn't seem to be activated."
    echo "Run: home-manager switch --flake ~/src/github.com/mabroor/dotfiles"
    exit 1
fi

# Test if packages are accessible
echo "Testing package availability..."
for cmd in fzf zellij fish; do
    if command -v $cmd >/dev/null 2>&1; then
        echo "✓ $cmd found at: $(which $cmd)"
    else
        echo "✗ $cmd NOT FOUND in current environment"
        echo "  Checking if it exists in nix profile..."
        if [ -e "$HOME/.nix-profile/bin/$cmd" ]; then
            echo "  Found in nix profile but not in PATH!"
        else
            echo "  Not installed. Add it to home.packages in home.nix"
        fi
    fi
done

echo
echo "=== Testing Fish startup ==="
echo "Running: fish -c 'echo \$PATH' | tr ' ' '\n' | head -5"
fish -c 'echo $PATH' | tr ' ' '\n' | head -5

echo
echo "=== Next steps ==="
echo "1. Ensure your login shell is bash: chsh -s \$(which bash)"
echo "2. Apply the configuration: home-manager switch --flake ~/src/github.com/mabroor/dotfiles"
echo "3. Log out and SSH back in to test the fix"
echo "4. Or test with: su - $USER"