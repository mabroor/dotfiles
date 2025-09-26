# Mabroor's Nix Dotfiles

A comprehensive, modular Nix-based dotfiles repository supporting macOS (Intel and Apple Silicon) and NixOS systems. This configuration provides a modern development environment with consistent tooling, theming, and application configurations.

## ✨ Features

### 🏗️ Architecture

- **Modular Design**: Clean separation of concerns with organized modules
- **Multi-Platform**: Support for macOS (Intel/Apple Silicon) and NixOS
- **Declarative Configuration**: Everything is version-controlled and reproducible
- **Helper Functions**: Simplified system building with reusable components

### 🛠️ Development Environment

- **Modern CLI Tools**: bat, eza, fd, sd, delta, btop, dust, procs, lazygit, httpie, jless
- **Terminal Setup**: Zellij multiplexer with Fish shell and Tide prompt
- **Editor**: Neovim with LazyVim-style configuration and LSP support
- **Language Support**: Rust, Go, Python, JavaScript/Node.js with comprehensive tooling

### 🎨 Theming & UI

- **Consistent Theme**: Catppuccin Macchiato across all applications
- **Font Management**: JetBrains Mono, Monaspace, Nerd Fonts, and system fonts
- **Terminal Colors**: Coordinated color schemes for all terminal applications

### 🔒 Security & Configuration

- **Modern Git Setup**: Sensible defaults with `main` as default branch
- **SSH Configuration**: Comprehensive SSH client setup with security best practices
- **Secret Management**: agenix for encrypted secrets with age keys
- **System Hardening**: Optimized security settings and firewall configuration

### 🚀 Project Templates

- **Rust**: Complete development environment with Cargo tools and CI
- **JavaScript/Node.js**: Modern setup with multiple package managers
- **Python**: Poetry integration with comprehensive tooling

## 🎯 Recent Updates

### Git Configuration Modernization
- Default branch set to `main` for new repositories
- Comprehensive aliases with conflict resolution (e.g., `rba` for rebase abort)
- Pull strategy: rebase by default with fast-forward only
- Push: current branch, auto-setup remote, follow tags
- Automatic pruning of deleted remote branches and tags
- Rerere enabled for reusing conflict resolutions
- Better diff algorithms optimized for code

### Zellij & Fish Shell Improvements
- **Fixed SSH/su session issues**: Proper PATH and environment setup
- **Robust session management**: Works across SSH, RDP, and local terminals
- **Permission fixes**: Handles XDG_RUNTIME_DIR correctly in all scenarios
- **Safe wrapper script**: `zellij-safe` handles all edge cases automatically

### Development Environment
- Fish shell as primary shell with comprehensive configuration
- Zellij terminal multiplexer with custom keybindings
- Modern CLI tools preconfigured and aliased
- Tide prompt with beautiful, informative display

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

##### For macOS (Darwin)

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

##### For NixOS

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

##### For Linux (non-NixOS) with Home Manager only

This section covers setting up this repository on fresh Linux VMs or systems that aren't running NixOS (e.g., Ubuntu, Debian, Fedora, CentOS, etc.).

###### Prerequisites

1. **Ensure your system is up to date:**

   ```bash
   # Debian/Ubuntu
   sudo apt update && sudo apt upgrade -y

   # Fedora
   sudo dnf update -y

   # RHEL/CentOS/AlmaLinux
   sudo yum update -y
   ```

2. **Install required dependencies:**

   ```bash
   # Debian/Ubuntu
   sudo apt install -y curl git xz-utils

   # Fedora
   sudo dnf install -y curl git xz

   # RHEL/CentOS/AlmaLinux
   sudo yum install -y curl git xz
   ```

3. **Create a user (if using root or need a new user):**

   ```bash
   # Create a new user with home directory
   sudo useradd -m -s /bin/bash USERNAME
   sudo passwd USERNAME

   # Add to sudo group (optional)
   # Debian/Ubuntu
   sudo usermod -aG sudo USERNAME

   # Fedora/RHEL/CentOS
   sudo usermod -aG wheel USERNAME

   # Switch to the new user
   su - USERNAME
   ```

###### Step 1: Install Nix for Linux

After installing Nix (see Step 1 above), you need to ensure it's properly configured for your Linux distribution:

1. **Enable systemd service (if using systemd):**

   ```bash
   # The Determinate Systems installer should do this automatically
   # But you can verify with:
   systemctl --user status nix-daemon
   ```

2. **SELinux considerations (RHEL/Fedora/CentOS):**

   If SELinux is enabled, you may need to adjust policies:

   ```bash
   # Check SELinux status
   sestatus

   # If needed, set Nix store to permissive (temporary)
   sudo semanage fcontext -a -t bin_t '/nix/store(/.*)?'
   sudo restorecon -Rv /nix
   ```

###### Step 2: Configure Home Manager Standalone

1. **Create necessary directories:**

   ```bash
   mkdir -p ~/.config/nix
   mkdir -p ~/.config/home-manager
   ```

2. **Bootstrap Home Manager with this configuration:**

   ```bash
   # First, add Home Manager channel
   nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
   nix-channel --update

   # Install Home Manager
   nix-shell '<home-manager>' -A install
   ```

3. **Apply this dotfiles configuration:**

   ```bash
   # Clone the repository first
   git clone https://github.com/mabroor/dotfiles.git ~/src/github.com/mabroor/dotfiles

   # Create a custom home configuration for your Linux user
   cd ~/src/github.com/mabroor/dotfiles

   # Switch to the configuration
   home-manager switch --flake .#mabroor
   ```

   Note: Use the `mabroor` configuration or create your own custom configuration.

###### Step 3: Create a Custom Linux Configuration (Optional)

If you want a personalized configuration for your Linux VM:

1. **Create a new host configuration:**

   ```bash
   # In your cloned dotfiles repo
   mkdir -p hosts/my-linux-vm
   ```

2. **Create `hosts/my-linux-vm/default.nix`:**

   ```nix
   { config, pkgs, ... }:
   {
     # Your custom Linux-specific configuration
     home.username = "YOUR_USERNAME";
     home.homeDirectory = "/home/YOUR_USERNAME";
   }
   ```

3. **Update `flake.nix` to include your configuration:**

   Add to the `homeConfigurations` section:

   ```nix
   homeConfigurations = {
     "YOUR_USERNAME@my-linux-vm" = home-manager.lib.homeManagerConfiguration {
       pkgs = nixpkgs.legacyPackages.x86_64-linux;
       modules = [
         ./home/home.nix
         ./hosts/my-linux-vm
       ];
     };
   };
   ```

4. **Apply your custom configuration:**

   ```bash
   home-manager switch --flake .#YOUR_USERNAME@my-linux-vm
   ```

###### Linux-Specific Considerations

1. **GUI Applications:**
   - Most GUI applications from this config won't work in SSH sessions
   - For GUI support, ensure X11 forwarding is enabled: `ssh -X user@host`

2. **Font Installation:**
   - Fonts are managed by Home Manager but may need font cache refresh:

     ```bash
     fc-cache -fv
     ```

3. **Shell Integration:**
   - Fish shell is the default, with automatic Zellij multiplexer startup
   - The configuration handles SSH sessions properly with environment fixes

4. **Container/VM Considerations:**
   - Ensure adequate disk space (at least 10GB for Nix store)
   - If in Docker/Podman, use `--init` flag for proper signal handling
   - For WSL2, ensure systemd is enabled in `/etc/wsl.conf`

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

#### macOS

```bash
darwin-rebuild switch --flake ~/src/github.com/mabroor/dotfiles
```

#### NixOS

```bash
sudo nixos-rebuild switch --flake ~/src/github.com/mabroor/dotfiles
```

#### Home Manager (standalone)

```bash
home-manager switch --flake ~/src/github.com/mabroor/dotfiles#mabroor
```

### Troubleshooting Fresh Installs

#### Common Issues

1. **"command not found: darwin-rebuild"**
   - Ensure you've restarted your terminal after the initial bootstrap
   - Run `exec $SHELL` to reload your shell

2. **"experimental feature 'flakes' is disabled"**
   - The Determinate Systems installer should enable this automatically
   - If not, add to `~/.config/nix/nix.conf`:

     ```text
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

#### Linux-Specific Troubleshooting

1. **"error: cannot connect to daemon"**
   - Ensure the Nix daemon is running: `sudo systemctl status nix-daemon`
   - Start it if needed: `sudo systemctl start nix-daemon`
   - For non-systemd systems, check if daemon is running: `ps aux | grep nix-daemon`

2. **"error: getting status of '/nix/var/nix/db': Permission denied"**
   - This usually means Nix wasn't installed correctly
   - Re-run the installer with proper permissions
   - Ensure your user is in the `nixbld` group: `groups $USER`

3. **Home Manager command not found**
   - Source the Nix profile: `. ~/.nix-profile/etc/profile.d/nix.sh`
   - Update channels: `nix-channel --update`
   - Re-install Home Manager: `nix-shell '<home-manager>' -A install`

4. **SELinux blocking Nix operations (RHEL/Fedora)**
   - Check SELinux denials: `sudo ausearch -m avc -ts recent`
   - Temporarily set to permissive: `sudo setenforce 0`
   - Create permanent policy if needed (consult SELinux documentation)

5. **Locale issues (LC_ALL/LANG errors)**
   - Install locale packages: `sudo apt install locales` (Debian/Ubuntu)
   - Generate locales: `sudo locale-gen en_US.UTF-8`
   - Set in shell: `export LANG=en_US.UTF-8`

6. **Out of disk space in /nix/store**
   - Check disk usage: `df -h /nix`
   - Clean old generations: `nix-collect-garbage -d`
   - Remove old Home Manager generations: `home-manager generations | head -5`
   - Then remove: `home-manager remove-generations [IDs]`

7. **Fish shell not starting automatically**
   - Ensure fish is in allowed shells: `grep fish /etc/shells`
   - If not, add it: `echo "$(which fish)" | sudo tee -a /etc/shells`
   - Change default shell: `chsh -s $(which fish)`

8. **Zellij/Fish SSH Issues**
   - Run the diagnostic script: `./scripts/test-ssh-zellij.sh`
   - Apply fixes: `./scripts/fix-zellij-permissions.sh`
   - The configuration includes automatic fixes for SSH session environments

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
│   ├── git.nix            # Git configuration (modernized)
│   ├── neovim.nix         # Neovim setup
│   ├── ssh.nix            # SSH configuration
│   ├── fonts.nix          # Font management
│   ├── theme.nix          # Theming configuration
│   ├── wezterm.nix        # WezTerm terminal
│   └── zellij.nix         # Zellij multiplexer (with SSH fixes)
├── modules/dev/           # Development environments
│   ├── rust.nix           # Rust development
│   ├── go.nix             # Go development
│   ├── python.nix         # Python development
│   └── javascript.nix     # JavaScript/Node.js
├── templates/             # Project templates
│   ├── rust/              # Rust project template
│   ├── python/            # Python project template
│   └── javascript/        # JavaScript project template
├── scripts/               # Utility scripts
│   ├── test-ssh-zellij.sh # SSH session testing
│   ├── fix-zellij-permissions.sh # Permission fixes
│   └── fix-fish-ssh.sh    # Fish environment verification
├── secrets/               # Encrypted secrets (agenix)
│   ├── secrets.nix        # Secret definitions
│   └── README.md          # Secret management guide
└── config/                # Application dotfiles
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

### Home Manager Standalone (x86_64-linux)

- **Configuration**: `mabroor`
- **User**: `mabroor`

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
darwin-rebuild switch --flake ~/src/github.com/mabroor/dotfiles

# Rebuild system (NixOS)
sudo nixos-rebuild switch --flake ~/src/github.com/mabroor/dotfiles

# Apply home configuration
home-manager switch --flake ~/src/github.com/mabroor/dotfiles#mabroor
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

### Git Aliases (New!)

```bash
# Common operations
git st          # Short status with branch info
git aa          # Add all files
git ci          # Commit with verbose mode
git cob         # Checkout new branch
git pushf       # Push with force-with-lease (safer)
git rba         # Rebase abort (was 'ra', now 'rba')
git ff          # Fast-forward merge only
git cleanup     # Remove merged branches

# Logging
git l           # Pretty log graph
git la          # Log all branches
git r           # Recent commits (20)
git ra          # Recent all branches (20)

# Maintenance
git undo        # Undo last commit (soft reset)
git unstage     # Unstage files
git recent      # Show branches by last commit
```

### Utility Scripts

```bash
# SSH/Zellij troubleshooting
./scripts/test-ssh-zellij.sh       # Test SSH session environment
./scripts/fix-zellij-permissions.sh # Fix permission issues
./scripts/fix-fish-ssh.sh          # Verify Fish environment

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

- Terminal applications (WezTerm, Zellij, Fish)
- CLI tools (bat, fzf, delta, eza)
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
2. Run diagnostic scripts in `scripts/` directory
3. Run `nix flake check` to validate your configuration
4. Review the documentation in this repository
5. Create a new issue with the provided template

---