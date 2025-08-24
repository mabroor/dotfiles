# Mabroor's Nix Dotfiles

A comprehensive, modular Nix-based dotfiles repository supporting macOS (Intel and Apple Silicon) and NixOS systems. This configuration provides a modern development environment with consistent tooling, theming, and application configurations.

## ✨ Features

### 🏗️ Architecture

- **Modular Design**: Clean separation of concerns with organized modules
- **Multi-Platform**: Support for macOS (Intel/Apple Silicon) and NixOS
- **Declarative Configuration**: Everything is version-controlled and reproducible
- **Helper Functions**: Simplified system building with reusable components

### 🛠️ Development Environment

- **Modern CLI Tools**: bat, eza, fd, sd, delta, btop, dust, procs, lazygit, httpie
- **Terminal Setup**: Zellij multiplexer with Starship prompt
- **Editor**: Neovim with LazyVim-style configuration and LSP support
- **Language Support**: Rust, Go, Python, JavaScript/Node.js with comprehensive tooling

### 🎨 Theming & UI

- **Consistent Theme**: Catppuccin Macchiato across all applications
- **Font Management**: JetBrains Mono, Monaspace, Nerd Fonts, and system fonts
- **Terminal Colors**: Coordinated color schemes for all terminal applications

### 🔒 Security & Secrets

- **Secret Management**: agenix for encrypted secrets with age keys
- **SSH Configuration**: Comprehensive SSH client setup with security best practices
- **System Hardening**: Optimized security settings and firewall configuration

### 🚀 Project Templates

- **Rust**: Complete development environment with Cargo tools and CI
- **JavaScript/Node.js**: Modern setup with multiple package managers
- **Python**: Poetry integration with comprehensive tooling

## 🚀 Quick Start

### Fresh Install / New VM Setup

Starting from a completely fresh system or new VM? Follow these steps:

#### Step 1: Install Nix

Install Nix using the [Determinate Systems Installer](https://github.com/DeterminateSystems/nix-installer) (recommended for flakes support):

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

**Note:** This installer automatically enables flakes and nix-command experimental features.

#### Step 2: Initial System Bootstrap

##### For macOS (Darwin):

1. **Run the bootstrap command directly from GitHub:**

   ```bash
   nix run nix-darwin -- switch --flake github:mabroor/dotfiles#HOSTNAME
   ```

   Replace `HOSTNAME` with:
   - `AMAFCXNW09RYR` for Apple Silicon Mac with user `mabroor.ahmed`
   - `Mabroors-MacBook-Pro` for Intel Mac with user `mabroor`

2. **Restart your terminal** or source your shell configuration:

   ```bash
   exec $SHELL
   ```

3. **Verify the installation:**

   ```bash
   darwin-rebuild --version
   ```

##### For NixOS:

1. **During NixOS installation**, add this to your `/etc/nixos/configuration.nix`:

   ```nix
   {
     nix.settings.experimental-features = [ "nix-command" "flakes" ];
   }
   ```

2. **After initial NixOS installation, run:**

   ```bash
   sudo nixos-rebuild switch --flake github:mabroor/dotfiles#nixos
   ```

3. **Restart your system** to ensure all changes take effect.

##### For Linux (non-NixOS) with Home Manager only:

1. **Install Home Manager standalone:**

   ```bash
   nix run home-manager/master -- init --switch --flake github:mabroor/dotfiles#USER
   ```

   Replace `USER` with your username.

#### Step 3: Clone for Local Development

After the initial bootstrap, clone the repository for local modifications:

```bash
# Create source directory structure
mkdir -p ~/src/github.com/mabroor

# Clone the repository
git clone https://github.com/mabroor/dotfiles.git ~/src/github.com/mabroor/dotfiles

# Navigate to the repository
cd ~/src/github.com/mabroor/dotfiles
```

#### Step 4: Verify Installation

Run these commands to ensure everything is working:

```bash
# Check Nix version and flakes
nix --version
nix flake show

# Test a development environment
nix develop -c echo "Development environment works!"

# Check available templates
nix flake show --json | jq '.templates'
```

### Updating Your Configuration

Once you have the repository cloned locally:

#### macOS:

```bash
darwin-rebuild switch --flake ~/src/github.com/mabroor/dotfiles
```

#### NixOS:

```bash
sudo nixos-rebuild switch --flake ~/src/github.com/mabroor/dotfiles
```

#### Home Manager (standalone):

```bash
home-manager switch --flake ~/src/github.com/mabroor/dotfiles
```

### Troubleshooting Fresh Installs

#### Common Issues:

1. **"command not found: darwin-rebuild"**
   - Ensure you've restarted your terminal after the initial bootstrap
   - Run `exec $SHELL` to reload your shell

2. **"experimental feature 'flakes' is disabled"**
   - The Determinate Systems installer should enable this automatically
   - If not, add to `~/.config/nix/nix.conf`:

     ```
     experimental-features = nix-command flakes
     ```

3. **Permission denied errors on macOS**
   - Ensure the Nix daemon is running: `sudo launchctl list | grep nix`
   - Restart the daemon if needed: `sudo launchctl stop org.nixos.nix-daemon && sudo launchctl start org.nixos.nix-daemon`

4. **"error: flake does not provide attribute"**
   - Check that you're using the correct hostname in the flake reference
   - List available configurations: `nix flake show github:mabroor/dotfiles`

5. **Homebrew packages not installing (macOS)**
   - The first run may need to install Homebrew itself
   - Run `darwin-rebuild switch` again after Homebrew installs
   - Check Homebrew installation: `brew --version`

## 📁 Repository Structure

```text
dotfiles/
├── flake.nix              # Main flake configuration
├── lib/                   # Helper functions
│   └── mkSystem.nix       # System building helpers
├── hosts/                 # Host-specific configurations
│   ├── AMAFCXNW09RYR/     # Apple Silicon Mac
│   ├── Mabroors-MacBook-Pro/ # Intel Mac
│   └── nixos/             # NixOS system
├── darwin/                # macOS system configuration
│   └── darwin.nix         # Darwin-specific settings
├── home/                  # Home Manager configurations
│   ├── home.nix           # Main home configuration
│   ├── git.nix            # Git configuration
│   ├── neovim.nix         # Neovim setup
│   ├── ssh.nix            # SSH configuration
│   ├── fonts.nix          # Font management
│   ├── theme.nix          # Theming configuration
│   ├── wezterm.nix        # WezTerm terminal
│   └── zellij.nix         # Zellij multiplexer
├── modules/dev/           # Development environments
│   ├── rust.nix           # Rust development
│   ├── go.nix             # Go development
│   ├── python.nix         # Python development
│   └── javascript.nix     # JavaScript/Node.js
├── templates/             # Project templates
│   ├── rust/              # Rust project template
│   ├── python/            # Python project template
│   └── javascript/        # JavaScript project template
├── secrets/               # Encrypted secrets (agenix)
│   ├── secrets.nix        # Secret definitions
│   └── README.md          # Secret management guide
└── config/                # Application dotfiles
    ├── git/               # Git configuration files
    └── wezterm/           # WezTerm configuration
```

## 🏠 Host Configuration

This setup supports multiple machine types:

### Apple Silicon Mac (aarch64-darwin)

- **Host**: `AMAFCXNW09RYR`
- **User**: `mabroor.ahmed`

### Intel Mac (x86_64-darwin)

- **Host**: `Mabroors-MacBook-Pro`
- **User**: `mabroor`

### NixOS Linux (x86_64-linux)

- **Host**: `nixos`
- **User**: `nixos`

## 📋 Available Commands

### System Management

```bash
# Update flake inputs
nix flake update

# Check configuration
nix flake check

# Show flake outputs
nix flake show

# Rebuild system (macOS)
darwin-rebuild switch --flake ~/dotfiles

# Rebuild system (NixOS)
sudo nixos-rebuild switch --flake ~/dotfiles

# Apply home configuration
home-manager switch --flake ~/dotfiles
```

### Development Tools

```bash
# Create new projects from templates
nix flake init -t github:mabroor/dotfiles#rust
nix flake init -t github:mabroor/dotfiles#python
nix flake init -t github:mabroor/dotfiles#javascript

# Enter development environments
nix develop

# Language-specific project initialization
rust-project-init my-project bin
go-project-init my-project web
py-project-init my-project web
js-project-init my-project react
```

### Utility Scripts

```bash
# SSH key management
ssh-key-setup

# Font management
font-preview
font-install list

# Theme switching
theme-switch macchiato
wallpaper random  # macOS only
```

## 🛠️ Development Environments

### Rust

- Comprehensive Rust toolchain with rust-analyzer
- Cargo extensions: watch, edit, expand, audit, nextest
- Cross-compilation and WebAssembly support
- Project templates with CI/CD setup

### Go

- Go 1.21 with gopls language server
- Development tools: air, delve, golangci-lint
- Database tools: migrate, sqlc
- Project scaffolding with different architectures

### Python

- Python 3.11/3.12 with Poetry integration
- Code quality: Black, Ruff, MyPy, pytest
- Data science and web frameworks included
- Virtual environment management

### JavaScript/Node.js

- Node.js 20 with multiple package managers (npm, yarn, pnpm, bun)
- TypeScript and modern build tools (Vite, Webpack)
- Testing frameworks and development utilities
- Framework-specific templates (React, Vue, Angular)

## 🔐 Secret Management

This configuration uses [agenix](https://github.com/ryantm/agenix) for secret management:

1. **Generate age keys:**

   ```bash
   age-keygen -o ~/.config/age/keys.txt
   ```

2. **Update secrets.nix** with your public keys

3. **Create encrypted secrets:**

   ```bash
   agenix -e secret-name.age
   ```

See [secrets/README.md](secrets/README.md) for detailed instructions.

## 🎨 Customization

### Fonts

The configuration includes a comprehensive font setup:

- **Programming**: JetBrains Mono, Monaspace, Fira Code, Hack
- **System**: SF Pro, Inter, Roboto
- **Icons**: Nerd Fonts, Font Awesome

### Theming

Consistent Catppuccin Macchiato theme across:

- Terminal applications (Alacritty, Kitty, WezTerm)
- CLI tools (bat, fzf, delta)
- Neovim and development tools

### macOS System Preferences

Extensive system defaults configuration:

- Dock behavior and hot corners
- Finder enhancements
- Keyboard and trackpad optimization
- Security hardening

## 🧪 Testing

The repository includes comprehensive CI/CD:

```bash
# Run checks locally
nix flake check

# Test templates
cd /tmp && nix flake init -t ~/dotfiles#rust && nix develop

# Validate on different systems
nix build .#darwinConfigurations.AMAFCXNW09RYR.system
nix build .#nixosConfigurations.nixos.config.system.build.toplevel
```

## 📚 Documentation

- **[CLAUDE.md](CLAUDE.md)**: Instructions for Claude Code AI assistant
- **[secrets/README.md](secrets/README.md)**: Secret management guide
- **[templates/README.md](templates/README.md)**: Project template usage

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Ensure all checks pass: `nix flake check`
5. Submit a pull request

Please use the provided issue and PR templates for consistency.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [nix-community](https://github.com/nix-community) for excellent Nix packages and tools
- [Catppuccin](https://github.com/catppuccin) for the beautiful color scheme
- [Nerd Fonts](https://github.com/ryanoasis/nerd-fonts) for programming fonts
- The Nix and NixOS communities for inspiration and best practices

## 📞 Support

If you encounter issues:

1. Check existing [issues](https://github.com/mabroor/dotfiles/issues)
2. Run `nix flake check` to validate your configuration
3. Review the documentation in this repository
4. Create a new issue with the provided template

---
