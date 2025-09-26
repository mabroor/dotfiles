#!/usr/bin/env bash

# Fix Zellij permission issues
set -euo pipefail

echo "=== Fixing Zellij Permission Issues ==="
echo

UID=$(id -u)
USER=$(whoami)

echo "User: $USER (UID: $UID)"
echo

# Clean up old/wrong Zellij directories
echo "Cleaning up incorrect Zellij directories..."

# Remove /tmp/zellij-* directories that might conflict
if [ -d "/tmp/zellij-$UID" ]; then
    echo "Removing /tmp/zellij-$UID..."
    rm -rf "/tmp/zellij-$UID"
fi

# Ensure XDG_RUNTIME_DIR is set correctly
if [ -z "${XDG_RUNTIME_DIR:-}" ]; then
    if [ -d "/run/user/$UID" ]; then
        export XDG_RUNTIME_DIR="/run/user/$UID"
        echo "Set XDG_RUNTIME_DIR to $XDG_RUNTIME_DIR"
    else
        export XDG_RUNTIME_DIR="/tmp/runtime-$UID"
        mkdir -m 700 -p "$XDG_RUNTIME_DIR"
        echo "Created XDG_RUNTIME_DIR at $XDG_RUNTIME_DIR"
    fi
else
    echo "XDG_RUNTIME_DIR already set to: $XDG_RUNTIME_DIR"
fi

# Check Zellij runtime directory
ZELLIJ_RUNTIME="$XDG_RUNTIME_DIR/zellij"
echo
echo "Checking Zellij runtime directory: $ZELLIJ_RUNTIME"

if [ -d "$ZELLIJ_RUNTIME" ]; then
    echo "Zellij runtime directory exists"
    echo "Contents:"
    ls -la "$ZELLIJ_RUNTIME" 2>/dev/null || true

    # Fix permissions if needed
    chmod 755 "$ZELLIJ_RUNTIME" 2>/dev/null || true

    # Check for version subdirectories
    for dir in "$ZELLIJ_RUNTIME"/*; do
        if [ -d "$dir" ]; then
            chmod 700 "$dir" 2>/dev/null || true
            echo "Fixed permissions for: $dir"
        fi
    done
else
    echo "Zellij runtime directory doesn't exist (will be created on first use)"
fi

# Test Zellij
echo
echo "=== Testing Zellij ==="

# Set environment for test
export XDG_RUNTIME_DIR

# Try to list sessions
echo "Attempting to list sessions..."
if zellij list-sessions 2>&1; then
    echo "✓ Zellij can list sessions successfully"
else
    echo "✗ Failed to list sessions"
    echo
    echo "Trying to clean up and retry..."

    # Kill any stuck Zellij processes
    pkill -u "$USER" zellij 2>/dev/null || true
    sleep 1

    # Try again
    if zellij list-sessions 2>&1; then
        echo "✓ Zellij works after cleanup"
    else
        echo "✗ Still failing. Manual intervention may be needed."
    fi
fi

echo
echo "=== Recommendations ==="
echo "1. Always ensure XDG_RUNTIME_DIR is set to /run/user/$UID"
echo "2. Add this to your shell initialization:"
echo "   export XDG_RUNTIME_DIR=\"/run/user/\$(id -u)\""
echo "3. If issues persist, try:"
echo "   - Log out completely and log back in"
echo "   - Run: systemctl --user restart"
echo "4. Apply the home-manager configuration:"
echo "   home-manager switch --flake ~/src/github.com/mabroor/dotfiles"