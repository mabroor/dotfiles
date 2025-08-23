# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Comprehensive Nix-based dotfiles repository with modular architecture
- Multi-platform support for macOS (Intel/Apple Silicon) and NixOS
- Modern CLI tools suite (bat, eza, fd, sd, delta, btop, dust, procs, lazygit, httpie, jless)
- Zellij terminal multiplexer with intuitive keybindings
- Enhanced Starship prompt with programming language detection
- Neovim with LazyVim-style configuration and comprehensive LSP support
- Secret management with agenix for encrypted secrets
- SSH configuration with security best practices
- Language-specific development modules:
  - Rust: Complete toolchain with cargo extensions and WebAssembly support
  - Go: Modern Go development with air, delve, and comprehensive tooling
  - Python: Poetry integration with code quality tools (Black, Ruff, MyPy)
  - JavaScript/Node.js: Multi-package manager support with modern build tools
- Project templates for Rust, Python, and JavaScript projects
- Comprehensive font management with programming and system fonts
- Consistent Catppuccin Macchiato theming across all applications
- Extensive macOS system preferences with security hardening
- GitHub Actions CI/CD with multi-platform testing
- Helper functions for simplified system building
- Comprehensive documentation with usage guides

### Changed

- Updated nixpkgs from release-23.11 to nixos-unstable for latest packages
- Migrated to modular host structure with host-specific configurations
- Enhanced existing configurations with modern alternatives and best practices

### Technical Details

- **Architecture**: Modular design with lib/mkSystem.nix helper functions
- **Security**: agenix integration with age-based encryption for secrets
- **CI/CD**: Comprehensive GitHub Actions workflow with template testing
- **Theming**: Consistent color schemes across terminal and GUI applications
- **Development**: Language-specific modules with project scaffolding tools

### Repository Structure

```text
dotfiles/
├── flake.nix              # Main flake configuration
├── lib/                   # Helper functions
├── hosts/                 # Host-specific configurations  
├── darwin/                # macOS system configuration
├── home/                  # Home Manager configurations
├── modules/dev/           # Development environments
├── templates/             # Project templates
├── secrets/               # Encrypted secrets (agenix)
└── .github/               # CI/CD and repository templates
```

## [Previous Versions]

This represents a complete rewrite and modernization of the previous dotfiles setup. Previous versions included basic macOS and NixOS configurations with minimal tooling.

### Migration Notes
- Users upgrading from previous versions should backup their current configurations
- The new modular structure requires updating host-specific configurations
- Secret management now uses agenix instead of plain text files
- Home Manager configurations are now organized into separate modules