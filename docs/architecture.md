# Architecture

This document explains the architecture and design decisions behind this Nix-based dotfiles configuration. Understanding the architecture will help you navigate, customize, and contribute to the system effectively.

## System Architecture Overview

### High-Level Design

```text
┌─────────────────────────────────────────────────────────────┐
│                    Flake Entry Point                        │
│                     (flake.nix)                            │
└─────────────────────┬───────────────────────────────────────┘
                      │
              ┌───────┴───────┐
              │               │
    ┌─────────▼─────────┐    ┌▼──────────────┐
    │   Darwin Configs  │    │ NixOS Configs │
    │   (macOS hosts)   │    │ (Linux hosts) │
    └─────────┬─────────┘    └┬──────────────┘
              │               │
              └───────┬───────┘
                      │
           ┌──────────▼──────────┐
           │   Home Manager      │
           │  (User-level conf)  │
           └─────────┬───────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
   ┌────▼─────┐              ┌────▼─────┐
   │ Dev Env  │              │ Tool     │
   │ Modules  │              │ Configs  │
   └──────────┘              └──────────┘
```

### Configuration Layers

1. **Flake Layer** (`flake.nix`) - Entry point and system definitions
2. **System Layer** (`darwin/`, `nixos/`) - OS-level configurations  
3. **Host Layer** (`hosts/`) - Machine-specific overrides
4. **User Layer** (`home/`) - User environment via home-manager
5. **Module Layer** (`modules/`) - Reusable development environments
6. **Template Layer** (`templates/`) - Project scaffolding

## Design Principles

### 1. Declarative Configuration

All system state is described declaratively in Nix expressions:

```nix
# Instead of imperative commands like:
# $ brew install firefox
# $ defaults write com.apple.dock autohide true

# We have declarative configuration:
homebrew.casks = [ "firefox" ];
system.defaults.dock.autohide = true;
```

**Benefits:**

- Reproducible across machines
- Version-controlled configuration
- Atomic updates (all-or-nothing)
- Easy rollbacks

### 2. Modular Architecture

Each concern is separated into its own module:

```text
modules/dev/
├── javascript.nix    # Node.js/JS environment
├── rust.nix         # Rust development
├── python.nix       # Python development
└── go.nix           # Go development
```

**Benefits:**

- Easy to maintain individual components
- Selective inclusion of environments
- Clear separation of concerns
- Reusable across different configurations

### 3. Cross-Platform Consistency

Same configuration works on macOS and NixOS with conditional logic:

```nix
home.packages = with pkgs; [
  universal-tool
] ++ lib.optionals stdenv.isDarwin [
  darwin-only-tool
] ++ lib.optionals stdenv.isLinux [
  linux-only-tool
];
```

**Benefits:**

- Consistent development environment
- Single source of truth for configuration
- Reduced maintenance overhead

### 4. Layered Overrides

Configuration follows a hierarchy allowing selective customization:

```text
Base Configuration (flake.nix)
    ↓
System Configuration (darwin.nix/configuration.nix)  
    ↓
Host-Specific Overrides (hosts/HOSTNAME/)
    ↓
User Configuration (home.nix)
```

## Component Architecture

### Flake Structure (`flake.nix`)

The flake serves as the system's entry point and coordinator:

```nix
{
  # Define where packages come from
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    darwin.url = "github:LnL7/nix-darwin";
  };
  
  # Define system configurations
  outputs = { ... }: {
    # macOS configurations
    darwinConfigurations.HOSTNAME = mkDarwin { ... };
    
    # Linux configurations  
    nixosConfigurations.HOSTNAME = mkNixOS { ... };
    
    # Development templates
    templates.rust = { ... };
  };
}
```

**Key Responsibilities:**

- Dependency management (inputs)
- System configuration orchestration
- Template definitions
- Output standardization

### System Configuration Layer

#### Darwin Configuration (`darwin/darwin.nix`)

Handles macOS system-level settings:

```nix
{
  # GUI applications via Homebrew
  homebrew.casks = [ "firefox" "raycast" ];
  
  # System defaults (Dock, Finder, etc.)
  system.defaults.dock.autohide = true;
  
  # System fonts
  fonts.fonts = [ pkgs.jetbrains-mono ];
  
  # System services
  services.nix-daemon.enable = true;
}
```

#### NixOS Configuration (`nixos/configuration.nix`)

Handles Linux system-level settings:

```nix
{
  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  
  # Network configuration
  networking.hostName = "nixos";
  
  # System packages
  environment.systemPackages = [ pkgs.git ];
  
  # Services
  services.openssh.enable = true;
}
```

### User Configuration Layer (`home/`)

Home-manager handles user-level configuration:

#### Main Configuration (`home/home.nix`)

```nix
{
  imports = [
    # Tool-specific configurations
    ./git.nix
    ./wezterm.nix
    ./neovim.nix
    
    # Development environments
    ../modules/dev/javascript.nix
    ../modules/dev/rust.nix
  ];
  
  # User packages
  home.packages = with pkgs; [
    ripgrep
    bat
    eza
  ];
  
  # Shell configuration
  programs.fish.enable = true;
}
```

#### Tool Modules

Each tool gets its own configuration module:

```nix
# home/git.nix
{
  programs.git = {
    enable = true;
    userName = "User Name";
    userEmail = "user@example.com";
    aliases = {
      s = "status";
      c = "commit";
    };
  };
}
```

### Development Environment Modules (`modules/dev/`)

Self-contained development environments:

```nix
# modules/dev/rust.nix
{ config, pkgs, ... }:
{
  # Development tools
  home.packages = with pkgs; [
    rustc
    cargo
    rust-analyzer
    cargo-watch
  ];
  
  # Shell aliases
  programs.fish.shellAliases = {
    c = "cargo";
    cb = "cargo build";
    cr = "cargo run";
  };
  
  # Environment variables
  home.sessionVariables = {
    CARGO_HOME = "${config.home.homeDirectory}/.cargo";
  };
  
  # Development scripts
  home.file.".local/bin/rust-project-init" = {
    text = ''#!/bin/bash
      # Project initialization script
    '';
    executable = true;
  };
}
```

### Host-Specific Configuration (`hosts/`)

Machine-specific overrides and settings:

```nix
# hosts/AMAFCXNW09RYR/default.nix
{
  # Host-specific packages
  home-manager.users.${username}.home.packages = [
    pkgs.host-specific-tool
  ];
  
  # Host-specific settings
  home-manager.users.${username}.programs.git.userEmail = 
    "work@example.com";
}
```

## Key Design Decisions

### 1. Home Manager vs System Packages

**Philosophy:** User-level tools via home-manager, system services via system configuration.

```nix
# System level (affects all users)
environment.systemPackages = [ pkgs.git ];

# User level (per-user configuration)
home.packages = [ pkgs.ripgrep ];
```

**Rationale:**

- Users can customize their environment independently
- Cleaner separation of concerns
- Easier to maintain user-specific configurations

### 2. Fish Shell as Default

**Choice:** Fish over Bash/Zsh
**Rationale:**

- Better out-of-the-box experience
- Superior auto-completion
- Modern syntax highlighting
- Good Nix integration via plugins

### 3. Modern CLI Tool Replacements

**Philosophy:** Use modern alternatives to traditional Unix tools.

| Traditional | Modern | Reason |
|-------------|--------|--------|
| `ls` | `eza` | Better colors, icons, git integration |
| `cat` | `bat` | Syntax highlighting, line numbers |
| `grep` | `ripgrep` | Faster, better defaults |
| `find` | `fd` | Simpler syntax, faster |

**Rationale:**

- Improved user experience
- Better defaults
- Enhanced functionality
- Backward compatibility via aliases

### 4. Template-Based Project Creation

**Architecture:**

```text
templates/
├── rust/
│   ├── flake.nix
│   └── Cargo.toml
├── javascript/
│   ├── flake.nix
│   └── package.json
└── python/
    ├── flake.nix
    └── pyproject.toml
```

**Benefits:**

- Consistent project structure
- Pre-configured development environments
- Rapid project bootstrapping
- Best practices enforcement

### 5. Flake-Based Configuration

**Choice:** Nix Flakes over traditional Nix
**Benefits:**

- Reproducible builds via lock files
- Cleaner dependency management
- Better composability
- Standard project structure

### 6. Cross-Platform Strategy

**Approach:** Shared user configuration with platform-specific system layers.

```nix
# Shared user config
home/home.nix

# Platform-specific system config
darwin/darwin.nix    # macOS
nixos/configuration.nix  # Linux
```

**Benefits:**

- Maximum code reuse
- Consistent user experience
- Platform-specific optimizations where needed

## Configuration Flow

### 1. System Bootstrap

```text
flake.nix → System Config → Host Config → Home Manager
```

### 2. Package Resolution

```text
Flake Inputs → nixpkgs → Package Selection → System/User Packages
```

### 3. Configuration Application

```text
Nix Build → Symlink Generation → Service Activation → User Session
```

## Extension Points

### Adding New Tools

1. **User packages**: Add to `home.packages` in `home/home.nix`
2. **System packages**: Add to `environment.systemPackages` in system config
3. **Configured programs**: Create new module in `home/`

### Adding New Development Environments

1. Create module in `modules/dev/`
2. Define packages, aliases, environment variables
3. Import in `home/home.nix`
4. Optional: Create project template

### Adding New Hosts

1. Create directory in `hosts/`
2. Define host-specific overrides
3. Register in `flake.nix` outputs

## Performance Considerations

### Build Optimization

- **Binary caches**: Use official and community caches
- **Lazy evaluation**: Only evaluate what's needed
- **Modular structure**: Minimize rebuilds on changes

### Runtime Performance

- **Shell startup**: Minimize expensive operations in shell init
- **Tool selection**: Choose performant modern alternatives
- **Caching**: Leverage tool-specific caching (cargo, npm, etc.)

## Security Considerations

### Secret Management

- **agenix integration**: Encrypted secrets in Git
- **SSH key management**: Declarative SSH configuration
- **Environment variables**: Avoid secrets in config files

### System Security

- **Principle of least privilege**: Minimal system modifications
- **Isolation**: User-level configuration preferred
- **Updates**: Regular security updates via flake updates

## Migration and Compatibility

### Backwards Compatibility

- **Aliases**: Traditional commands work via aliases
- **PATH management**: Traditional tools available when needed
- **Gradual adoption**: Can coexist with existing dotfiles

### Migration Strategy

1. **Parallel installation**: Run alongside existing setup
2. **Incremental migration**: Move tools one at a time  
3. **Validation**: Verify functionality before removing old config
4. **Rollback capability**: Keep old configurations as backup

This architecture provides a solid foundation that's both powerful and maintainable, supporting everything from basic usage to advanced customization needs.
