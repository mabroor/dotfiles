# Frequently Asked Questions

This FAQ addresses common questions, issues, and troubleshooting scenarios for the dotfiles configuration.

## General Questions

### Q: What is Nix and why is it used for dotfiles?

**A:** Nix is a declarative package manager and configuration system. It's used for dotfiles because it provides:

- **Reproducibility**: Same configuration works identically across machines
- **Atomic updates**: Changes either fully succeed or fully fail
- **Rollbacks**: Easy to revert to previous configurations
- **Isolation**: No conflicts between package versions
- **Cross-platform**: Same config works on macOS and Linux

### Q: Do I need to learn Nix to use this configuration?

**A:** Not necessarily for basic usage:

- **Day-to-day use**: The configured tools work like any other system
- **Minor changes**: Follow patterns in existing configuration files
- **Major changes**: Some Nix knowledge is helpful but not required
- **Learning resources**: The [Developer Guide](developer-guide.md) provides guidance

### Q: Can I use this alongside my existing dotfiles?

**A:** Yes, but with some considerations:

- **Nix-managed tools**: Will override system versions
- **Configuration files**: May conflict with existing dotfiles
- **Migration approach**: Start with a fresh user or parallel installation
- **Selective adoption**: You can choose which parts to use

### Q: How do I know what tools are installed?

**A:** Several ways to check:

```bash
# List all packages installed via home-manager
home-manager packages

# Check specific tools
which ripgrep
which bat
which eza

# Show configuration
nix flake show
```

See the [Tool Reference](tool-reference.md) for complete list.

## Installation and Setup

### Q: How do I install this configuration on a new machine?

**A:** Follow these steps:

1. **Install Nix** (if not already installed):

   ```bash
   curl -L https://nixos.org/nix/install | sh
   ```

2. **Enable Nix Flakes**:

   ```bash
   mkdir -p ~/.config/nix
   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
   ```

3. **Bootstrap configuration**:

   ```bash
   # macOS
   nix run nix-darwin -- switch --flake github:mabroor/dotfiles
   
   # NixOS
   sudo nixos-rebuild switch --flake github:mabroor/dotfiles#nixos
   ```

### Q: The installation failed. How do I troubleshoot?

**A:** Common troubleshooting steps:

1. **Check Nix installation**:

   ```bash
   nix --version
   nix-env --version
   ```

2. **Verify flakes are enabled**:

   ```bash
   cat ~/.config/nix/nix.conf
   ```

3. **Check for conflicts**:

   ```bash
   # Look for existing configurations
   ls -la ~/.config/
   ls -la ~/.gitconfig ~/.zshrc ~/.bashrc
   ```

4. **View detailed error messages**:

   ```bash
   nix flake check --show-trace
   ```

### Q: How do I add my personal information (name, email, etc.)?

**A:** Edit the relevant configuration files:

1. **Git configuration** (`home/git.nix`):

   ```nix
   programs.git = {
     userName = "Your Name";
     userEmail = "your.email@example.com";
   };
   ```

2. **NPM configuration** (`modules/dev/javascript.nix`):

   ```nix
   home.sessionVariables = {
     NPM_CONFIG_INIT_AUTHOR_NAME = "Your Name";
     NPM_CONFIG_INIT_AUTHOR_EMAIL = "your.email@example.com";
   };
   ```

3. **Apply changes**:

   ```bash
   darwin-rebuild switch --flake ~/src/github.com/mabroor/dotfiles
   ```

## Usage Questions

### Q: Why don't traditional commands like `ls` show colors?

**A:** They do! The configuration includes aliases:

```bash
# These are aliased to modern tools:
ls    # → eza --icons (with colors and icons)
ll    # → eza -l --icons --git
cat   # → bat --paging=never (with syntax highlighting)
grep  # → rg (ripgrep)
```

If you want the original commands:

```bash
command ls    # Use original ls
\ls           # Bypass alias
/bin/ls       # Full path to original
```

### Q: How do I see what an alias does?

**A:** Several methods:

```bash
# Show alias definition
alias ls
type ls

# Show all aliases
alias

# Show command location
which ls
```

### Q: The `cd` command doesn't seem to work normally. Why?

**A:** The `cd` command is aliased to `zoxide` (z) for smart directory jumping:

```bash
cd projects     # Jumps to any directory containing "projects"
cd dev proj     # Jumps to directory matching both "dev" and "proj"
```

For traditional cd behavior:

```bash
command cd /full/path    # Use original cd
builtin cd path          # Use shell builtin
```

### Q: How do I customize shell aliases?

**A:** Edit the appropriate configuration file:

1. **General aliases** (`home/home.nix`):

   ```nix
   programs.fish.shellAliases = {
     myalias = "my-command --with-options";
   };
   ```

2. **Language-specific aliases** (e.g., `modules/dev/rust.nix`):

   ```nix
   programs.fish.shellAliases = {
     cr = "cargo run";
   };
   ```

3. **Apply changes**:

   ```bash
   darwin-rebuild switch --flake .
   ```

## Package Management

### Q: How do I install a new package?

**A:** Add it to the appropriate configuration:

1. **User packages** (`home/home.nix`):

   ```nix
   home.packages = with pkgs; [
     existing-package
     new-package
   ];
   ```

2. **System packages** (`darwin/darwin.nix` or `nixos/configuration.nix`):

   ```nix
   environment.systemPackages = [
     pkgs.new-package
   ];
   ```

3. **Apply changes**:

   ```bash
   darwin-rebuild switch --flake .
   ```

### Q: How do I find the name of a package in nixpkgs?

**A:** Several search methods:

```bash
# Search nixpkgs
nix search nixpkgs package-name

# Online search
# Visit: https://search.nixos.org/packages

# Interactive search
nix repl
> :l <nixpkgs>
> pkgs.tab-completion-here
```

### Q: A package I want isn't in nixpkgs. What do I do?

**A:** Options in order of preference:

1. **Check if it exists** under a different name
2. **Use alternative tools** that are available
3. **Install via language package manager** (npm, cargo, pip, etc.)
4. **Create a custom derivation** (advanced)
5. **Use AppImage or similar** for GUI apps

### Q: How do I update packages?

**A:** Update the flake inputs:

```bash
# Update all inputs
nix flake update

# Update specific input
nix flake update nixpkgs

# Apply updates
darwin-rebuild switch --flake .
```

## Development Environments

### Q: How do I add a new programming language environment?

**A:** Create a new module:

1. **Create module file** (`modules/dev/mylang.nix`):

   ```nix
   { config, pkgs, ... }:
   {
     home.packages = with pkgs; [
       mylang-compiler
       mylang-lsp
     ];
     
     programs.fish.shellAliases = {
       ml = "mylang";
     };
   }
   ```

2. **Import in home.nix**:

   ```nix
   imports = [
     # existing imports...
     ../modules/dev/mylang.nix
   ];
   ```

### Q: Project creation scripts aren't working. Why?

**A:** Check several things:

1. **Verify scripts are executable**:

   ```bash
   ls -la ~/.local/bin/
   ```

2. **Check PATH includes script directory**:

   ```bash
   echo $PATH | grep .local/bin
   ```

3. **Test script directly**:

   ```bash
   ~/.local/bin/rust-project-init test-project
   ```

4. **Check dependencies are installed**:

   ```bash
   which cargo  # For rust scripts
   which node   # For JS scripts
   ```

### Q: LSP isn't working in my editor. How do I fix it?

**A:** Verify LSP servers are installed:

```bash
# Check for language servers
which rust-analyzer    # Rust
which typescript-language-server  # TypeScript
which pyright          # Python

# Test LSP server
rust-analyzer --version
```

If missing, they should be in your development modules. Check the configuration and rebuild.

## System Issues

### Q: My shell prompt looks different than expected. Why?

**A:** The configuration uses the Tide prompt for Fish. If it's not working:

1. **Verify Fish is default shell**:

   ```bash
   echo $SHELL
   # Should show path to fish
   ```

2. **Check if Tide is configured**:

   ```fish
   tide configure
   ```

3. **Reconfigure if needed**:

   ```fish
   tide configure --auto --style=Lean
   ```

### Q: Commands are slow to start. How do I speed them up?

**A:** Several optimization strategies:

1. **Check shell startup time**:

   ```bash
   time fish -c exit
   ```

2. **Profile shell startup**:

   ```fish
   fish --profile /tmp/fish.profile -c exit
   cat /tmp/fish.profile
   ```

3. **Common causes**:
   - Slow network connections (affects some tools)
   - Large history files
   - Complex prompt configurations
   - Too many shell aliases

### Q: I can't find configuration files in expected locations. Where are they?

**A:** Nix manages configurations differently:

```bash
# Actual config files are in Nix store
ls -la ~/.config/git/
ls -la ~/.config/fish/

# Source configurations are in the dotfiles repo
ls -la ~/src/github.com/mabroor/dotfiles/home/
```

To modify configurations, edit the Nix files and rebuild, don't edit the generated configs directly.

### Q: How do I rollback if something breaks?

**A:** Nix provides built-in rollback capabilities:

```bash
# System rollback
darwin-rebuild --rollback           # macOS
sudo nixos-rebuild --rollback       # NixOS

# List available generations
darwin-rebuild --list-generations
sudo nixos-rebuild --list-generations

# Switch to specific generation
darwin-rebuild switch --switch-generation 42
```

## Platform-Specific Questions

### Q: Why are some GUI apps installed via Homebrew instead of Nix?

**A:** On macOS, some applications work better via Homebrew:

- **App Store integration**: Homebrew can install from Mac App Store
- **Native integration**: Better system integration for some apps
- **Package availability**: Some apps only available in Homebrew
- **Updates**: Some apps self-update better when installed via Homebrew

### Q: Can I disable Homebrew and use only Nix?

**A:** Mostly yes, but with trade-offs:

1. **Comment out Homebrew section** in `darwin/darwin.nix`
2. **Find Nix alternatives** for GUI applications
3. **Accept limitations** for some Mac-specific apps
4. **Manual installation** for apps not available in nixpkgs

### Q: How does this work differently on NixOS vs macOS?

**A:** Key differences:

| Aspect | macOS | NixOS |
|--------|-------|-------|
| System config | nix-darwin | Native NixOS |
| GUI apps | Homebrew + nixpkgs | nixpkgs |
| System services | launchd | systemd |
| Package manager | Homebrew + Nix | Nix only |
| Updates | `darwin-rebuild` | `nixos-rebuild` |

## Advanced Usage

### Q: How do I create a custom project template?

**A:** Follow these steps:

1. **Create template directory**:

   ```bash
   mkdir templates/mylang
   ```

2. **Add template files** (flake.nix, project files, etc.)

3. **Register in main flake.nix**:

   ```nix
   templates = {
     mylang = {
       path = ./templates/mylang;
       description = "MyLang project template";
     };
   };
   ```

4. **Use template**:

   ```bash
   nix flake init --template github:mabroor/dotfiles#mylang
   ```

### Q: How do I add secrets (API keys, passwords) to the configuration?

**A:** Use the agenix integration:

1. **Create secret file**:

   ```bash
   agenix -e mysecret.age
   ```

2. **Add to secrets configuration** (`secrets/secrets.nix`)

3. **Reference in configuration**:

   ```nix
   age.secrets.mysecret.file = ../secrets/mysecret.age;
   ```

See agenix documentation for detailed setup.

### Q: Can I use this configuration as a base for my own dotfiles?

**A:** Absolutely! Recommended approach:

1. **Fork the repository**
2. **Customize for your needs**:
   - Update personal information
   - Add/remove tools
   - Modify aliases and configurations
3. **Maintain your fork**:
   - Keep useful changes
   - Merge upstream updates as desired

## Getting Help

### Q: Where can I get more help?

**A:** Several resources available:

1. **Documentation**:
   - [User Guide](user-guide.md) for usage
   - [Developer Guide](developer-guide.md) for customization
   - [Tool Reference](tool-reference.md) for specific tools

2. **Community resources**:
   - [NixOS Discourse](https://discourse.nixos.org/)
   - [r/NixOS](https://www.reddit.com/r/NixOS/)
   - [Nix community on Matrix](https://matrix.to/#/#community:nixos.org)

3. **Official documentation**:
   - [Nix manual](https://nixos.org/manual/nix/stable/)
   - [NixOS manual](https://nixos.org/manual/nixos/stable/)
   - [Home Manager manual](https://nix-community.github.io/home-manager/)

4. **Tool-specific help**:

   ```bash
   tool-name --help
   man tool-name
   tldr tool-name
   ```

### Q: How do I report issues or contribute improvements?

**A:** Use the repository's issue tracker and contribution guidelines:

1. **Check existing issues** first
2. **Provide detailed information**:
   - System information (OS, architecture)
   - Steps to reproduce
   - Expected vs actual behavior
   - Relevant configuration
3. **Follow contribution guidelines** for pull requests
