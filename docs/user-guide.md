# User Guide

This guide will help you understand and effectively use your dotfiles configuration. Whether you're new to Nix or just getting familiar with this setup, this guide covers everything you need to know.

## Getting Started

### Understanding Your Setup

Your system is configured using **Nix**, a declarative package manager that ensures reproducible environments. This means:

- All your tools and configurations are defined in code
- Changes are atomic - they either fully succeed or fully fail
- You can always roll back to previous configurations
- The same configuration works across different machines

### Key Files to Know

- `flake.nix` - Main configuration entry point
- `home/home.nix` - Your personal environment configuration
- `darwin/darwin.nix` - macOS system settings (if on Mac)
- `CLAUDE.md` - Repository documentation and commands

## Your Shell Environment

### Fish Shell

Your default shell is **Fish** with modern enhancements:

```bash
# Fish provides:
- Auto-suggestions based on history
- Syntax highlighting
- Tab completions for most commands
- Modern prompt with git integration (Tide)
```

### Essential Aliases

Your configuration includes many helpful aliases. Here are the most important ones:

#### File Operations

```bash
ls          # → eza --icons (better ls with colors and icons)
ll          # → eza -l --icons --git (detailed list with git status)
la          # → eza -la --icons --git (show hidden files)
tree        # → eza --tree --icons (directory tree view)
cat         # → bat --paging=never (syntax highlighted cat)
```

#### Navigation

```bash
cd          # → z (smart directory jumping with zoxide)
find        # → fd (faster, user-friendly find)
```

#### Text and Search

```bash
grep        # → rg (ripgrep - faster grep with better defaults)
```

#### System Monitoring

```bash
top         # → btop (beautiful system monitor)
du          # → dust (disk usage analyzer)
ps          # → procs (modern process viewer)
```

### Modern CLI Tools

Your system includes modern replacements for traditional Unix tools:

| Traditional | Modern Alternative | Purpose |
|-------------|-------------------|---------|
| `ls` | `eza` | File listing with colors, icons, and git status |
| `cat` | `bat` | Syntax highlighting and line numbers |
| `grep` | `ripgrep` (rg) | Faster searching with better defaults |
| `find` | `fd` | Simpler syntax and faster performance |
| `sed` | `sd` | Simpler find-and-replace |
| `cd` | `zoxide` (z) | Smart directory jumping |
| `top`/`htop` | `btop` | Beautiful system resource monitor |
| `du` | `dust` | Visual disk usage analyzer |
| `ps` | `procs` | Colorized process viewer |

### Git Integration

Your git configuration includes powerful aliases and modern tools:

#### Essential Git Aliases

```bash
g           # → git
lg          # → lazygit (terminal UI for git)

# From your git configuration:
git s       # → git status
git a       # → git add
git c       # → git commit
git p       # → git push
git l       # → git pull
git co      # → git checkout
git br      # → git branch
git unstage # → git reset HEAD --
git last    # → git log -1 HEAD
```

#### Git Tools

- **lazygit** - Interactive terminal UI for git operations
- **delta** - Better git diff with syntax highlighting
- Automatic HTTPS → SSH conversion for GitHub

## Development Environments

Your configuration includes pre-configured development environments for multiple languages:

### JavaScript/Node.js

**Available Tools:**

- Node.js 20 LTS, npm, yarn, pnpm, bun
- TypeScript, Prettier, ESLint
- Development servers and build tools

**Useful Aliases:**

```bash
# npm shortcuts
ni          # → npm install
nr          # → npm run
ns          # → npm start
nt          # → npm test
nb          # → npm run build

# yarn shortcuts  
yi          # → yarn install
yr          # → yarn run
ys          # → yarn start

# pnpm shortcuts
pi          # → pnpm install
pr          # → pnpm run
pd          # → pnpm dev
```

**Project Creation:**

```bash
js-project-init my-app react    # Create React project
js-project-init my-api node     # Create Node.js project
package-json-gen               # Generate package.json with common scripts
```

### Rust

**Available Tools:**

- Complete Rust toolchain (rustc, cargo, clippy, rustfmt)
- cargo-watch, cargo-edit, cargo-audit
- WebAssembly tools (wasm-pack)
- Debugging and profiling tools

**Useful Aliases:**

```bash
c           # → cargo
cb          # → cargo build  
cbr         # → cargo build --release
cr          # → cargo run
ct          # → cargo test
cf          # → cargo fmt
ccl         # → cargo clippy
cdoc        # → cargo doc
cwatch      # → cargo watch
```

**Project Creation:**

```bash
rust-project-init my-project bin        # Create binary project
rust-project-init my-lib lib           # Create library project  
rust-project-init my-workspace workspace # Create workspace
```

### Python

**Available Tools:**

- Python 3.11, pip, poetry, black, ruff
- Development and data science libraries
- Virtual environment management

### Go

**Available Tools:**

- Go compiler and tools
- Popular Go development utilities

## Productivity Features

### Fuzzy Finding (fzf)

Your fzf configuration includes:

- **Ctrl+R** - Search command history
- **Ctrl+T** - Find files in current directory
- **Alt+C** - Change to subdirectory

Preview integration with bat for file previews.

### Directory Navigation (zoxide)

Zoxide learns your navigation patterns:

```bash
z docs          # Jump to any directory containing "docs"
z dev proj      # Jump to directories matching both "dev" and "proj"
zi             # Interactive directory selection
```

### File Management

#### File Viewing

```bash
bat file.txt    # View file with syntax highlighting
bat -n file.txt # View with line numbers
bat -A file.txt # Show all characters including whitespace
```

#### Directory Listing

```bash
eza            # Basic listing with icons
eza -l         # Detailed listing
eza -la        # Include hidden files
eza --tree     # Tree view
eza -l --git   # Show git status
```

#### Search and Find

```bash
fd pattern     # Find files/directories matching pattern
fd -e rs       # Find files with .rs extension
rg "search"    # Search for text in files
rg -i "search" # Case-insensitive search
rg --type rust "pattern" # Search only in Rust files
```

## System Management

### Updating Your Configuration

**macOS (Darwin):**

```bash
darwin-rebuild switch --flake ~/src/github.com/mabroor/dotfiles
```

**NixOS:**

```bash
sudo nixos-rebuild switch --flake ~/src/github.com/mabroor/dotfiles
```

### Updating Packages

```bash
nix flake update    # Update all package inputs
```

### Checking Configuration

```bash
nix flake check     # Validate configuration
nix flake show      # Show available configurations
```

## Customization

### Adding New Packages

1. Edit `home/home.nix` and add packages to the `home.packages` list
2. Rebuild your configuration
3. New tools will be available immediately

### Adding Shell Aliases

1. Edit the appropriate module (e.g., `home/home.nix` for general aliases)
2. Add to `programs.fish.shellAliases`
3. Rebuild configuration

### Customizing Tools

Each tool has its own configuration file in the `home/` directory:

- `git.nix` - Git configuration and aliases
- `wezterm.nix` - Terminal configuration  
- `neovim.nix` - Editor configuration

## Getting Help

### Built-in Help

```bash
tldr command    # Simplified man pages
command --help  # Most tools have help flags
```

### Documentation

```bash
man command     # Traditional manual pages
info command    # GNU info documents (where available)
```

### Exploration

```bash
which command   # Find where a command is installed
type command    # Show what a command alias resolves to
```

## Troubleshooting

### Common Issues

1. **Command not found** - The package might not be installed or in PATH
2. **Permission denied** - Check file permissions or use appropriate sudo
3. **Configuration changes not taking effect** - Rebuild your configuration

### Checking System Status

```bash
echo $SHELL     # Verify you're using fish
echo $PATH      # Check your PATH
nix-env --query # List installed packages (user level)
```

### Recovery

If something breaks:

1. Check the last working configuration in git history
2. Roll back using `darwin-rebuild --rollback` or similar
3. Edit configuration files to fix issues

## Next Steps

- Explore the [Tool Reference](tool-reference.md) for detailed tool documentation
- Check the [Developer Guide](developer-guide.md) if you want to customize further
- Visit [FAQ](faq.md) for common questions and solutions

Remember: This configuration is designed to be both powerful and discoverable. Don't hesitate to explore and experiment!
