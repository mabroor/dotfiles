# Font Installation Guide

This document explains how fonts are managed and installed across different platforms in this dotfiles configuration.

## Platform-Specific Font Installation

### macOS (Darwin)

- **Location**: `darwin/darwin.nix`
- **Installation Method**: System-wide via nix-darwin
- **Scope**: All users on the system
- **Key Setting**: `fonts.fontDir.enable = true`

Fonts on macOS MUST be installed at the system level because:

1. Home-manager cannot properly register fonts with macOS's font system
2. macOS requires fonts to be registered in specific system directories
3. System-wide installation ensures all users and applications can access the fonts

### NixOS (Linux)

- **Location**: `nixos/fonts.nix`
- **Installation Method**: System-wide via NixOS configuration
- **Scope**: All users on the system
- **Key Settings**:
  - `fonts.fontDir.enable = true`
  - `fonts.fontconfig.enable = true`
  - Includes fontconfig for proper font rendering

Benefits for NixOS users:

1. All users automatically get the same fonts
2. Consistent font rendering across the system
3. Proper fontconfig setup with antialiasing and hinting
4. No need for per-user font installation

### Non-NixOS Linux (Standalone Home-Manager)

- **Location**: `home/fonts.nix`
- **Installation Method**: Per-user via home-manager
- **Scope**: Current user only
- **Detection**: Automatically detects when NOT on NixOS or macOS

For users running home-manager standalone on distributions like Ubuntu, Arch, etc.:

1. Fonts are installed in user's home directory
2. Each user needs their own home-manager configuration
3. Works with any Linux distribution

## Font Categories

### Programming Fonts (Nerd Fonts)

- JetBrains Mono (recommended default)
- Fira Code
- Hack
- Source Code Pro
- Ubuntu Mono
- MesloLG
- Inconsolata
- DejaVu Sans Mono
- Droid Sans Mono
- Space Mono

### Programming Fonts (Regular)

- Monaspace (GitHub's innovative font family)
- Cascadia Code
- Fantasque Sans Mono
- Victor Mono

### System and Design Fonts

- Inter (modern sans-serif)
- Roboto family
- Atkinson Hyperlegible (accessibility-focused)
- Liberation fonts (metric-compatible with MS fonts)
- Source Sans/Serif Pro

### Icon Fonts

- Font Awesome
- Material Design Icons
- Nerd Font symbols (included with Nerd Fonts)

## Automatic vs Manual Steps

### What's Automatic

**macOS (Darwin):**

- Font installation to `/Library/Fonts/Nix Fonts/`
- Font registration with macOS
- Immediate availability to all applications
- No manual font cache refresh needed

**NixOS:**

- System-wide font installation
- Automatic `fc-cache` update during system activation
- Font availability to all users
- Fontconfig configuration applied automatically

**Non-NixOS Linux (Home-Manager):**

- Font installation to `~/.nix-profile/share/fonts/`
- Automatic `fc-cache -f` refresh via activation script
- Fontconfig user configuration
- Verification of Nerd Font installation

### What's Manual

**All Systems:**

- Configuring terminal emulator to use the new fonts
- Selecting "JetBrainsMono Nerd Font" or similar in terminal preferences
- Restarting applications that were open during font installation

**Terminal Configuration:**

1. Open your terminal preferences/settings
2. Look for Font or Text settings
3. Select a Nerd Font variant (e.g., "JetBrainsMono Nerd Font")
4. The font name must include "Nerd Font" for powerline symbols to work

## Troubleshooting

### Fonts not showing on macOS

1. Ensure you're using darwin-rebuild, not home-manager switch
2. Run: `darwin-rebuild switch --flake ~/src/github.com/mabroor/dotfiles`
3. Log out and log back in (or restart) for full effect
4. Check fonts are installed: `ls /nix/store/*/share/fonts/`

### Fonts not showing on NixOS

1. Ensure the fonts.nix module is imported in your host configuration
2. Run: `sudo nixos-rebuild switch --flake ~/src/github.com/mabroor/dotfiles`
3. Check fontconfig: `fc-list | grep -i "font-name"`
4. Rebuild font cache if needed: `fc-cache -fv`

### Fonts not showing for new Linux users

- **On NixOS**: Fonts are installed system-wide, should work automatically
- **On other Linux**: Each user needs their own home-manager configuration
- Check if fonts are in the right location:
  - System: `/usr/share/fonts/` or `/usr/local/share/fonts/`
  - User: `~/.local/share/fonts/` or `~/.fonts/`

### Terminal not showing powerline symbols

1. Ensure you're using a Nerd Font variant (e.g., "JetBrainsMono Nerd Font")
2. Configure your terminal to use the Nerd Font:
   - WezTerm: Check `~/.config/wezterm/wezterm.lua`
   - Alacritty: Check `~/.config/alacritty/alacritty.yml`
   - VS Code: Set `"terminal.integrated.fontFamily": "JetBrains Mono"`
3. Restart your terminal after font changes

## Adding New Fonts

### For macOS

Add to `darwin/darwin.nix` in the `fonts.fonts` list:

```nix
fonts = {
  fontDir.enable = true;
  fonts = with pkgs; [
    # Add your font here
    your-new-font
  ];
};
```

### For NixOS

Add to `nixos/fonts.nix` in the `fonts.packages` list:

```nix
fonts = {
  packages = with pkgs; [
    # Add your font here
    your-new-font
  ];
};
```

### For Standalone Home-Manager

Add to `home/fonts.nix` in the `home.packages` list (will only work on non-NixOS Linux):

```nix
home.packages = with pkgs; lib.optionals isStandaloneLinux [
  # Add your font here
  your-new-font
];
```

## Font Preview Tools

Use the included font preview script:

```bash
# List all fonts
font-install list

# List programming fonts only
font-install programming

# List Nerd Fonts
font-install nerdfonts

# Reload font cache
font-install reload
```

## Recommended Terminal Settings

### JetBrains Mono (Default)

- Size: 14px
- Line height: 1.2
- Ligatures: Enabled
- Weight: Regular (400)

### Font Fallback Chain

1. JetBrains Mono
2. Monaspace Neon
3. SF Mono (macOS)
4. Liberation Mono
5. System monospace

## Notes

- Font files are stored in the Nix store and symlinked to appropriate locations
- Changes require a system rebuild (darwin-rebuild or nixos-rebuild)
- Home-manager font installation doesn't work on macOS due to system restrictions
- On NixOS, system-wide installation is preferred for consistency across users
