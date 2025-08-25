# Tool Reference

This reference guide provides comprehensive information about all the tools installed and configured in your dotfiles. Use this as a quick reference for commands, options, and usage patterns.

## Core Development Tools

### Package Managers & Environments

#### Nix
Your primary package manager and configuration system.

```bash
# Package management
nix-env -qa | grep package    # Search for packages
nix-shell -p package          # Temporary shell with package
nix-collect-garbage           # Clean up old packages

# Flake operations  
nix flake show                # Show flake outputs
nix flake check               # Validate flake configuration
nix flake update              # Update all inputs
nix develop                   # Enter development shell
```

#### Direnv
Automatic environment loading per directory.

```bash
# Setup (automatic with configuration)
echo "use flake" > .envrc     # Use flake.nix in directory
direnv allow                  # Allow .envrc execution
direnv reload                 # Reload environment
```

### Shell and Terminal

#### Fish Shell
Your default shell with modern features.

```bash
# Configuration
fish_config                   # Open web-based configuration
fish_update_completions      # Update command completions

# History
history                       # Show command history
history search term           # Search history
history delete --prefix cmd   # Delete commands starting with 'cmd'
```

#### WezTerm
Your terminal emulator (configured via `home/wezterm.nix`).

```bash
# Key bindings (default config)
Ctrl+Shift+N                 # New window
Ctrl+Shift+T                 # New tab
Ctrl+Shift+W                 # Close tab
Ctrl+PageUp/PageDown         # Switch tabs
```

### Modern CLI Tools

#### eza (Better ls)
Enhanced file listing with colors, icons, and git integration.

```bash
eza                          # Basic listing with icons
eza -l                       # Long format
eza -la                      # Long format with hidden files
eza -T                       # Tree view
eza --tree --level=2         # Tree view, 2 levels deep
eza -l --git                 # Show git status
eza --group-directories-first # Group directories first
eza --sort=modified          # Sort by modification time
eza --reverse                # Reverse sort order

# Useful aliases (pre-configured)
ls                           # → eza --icons
ll                           # → eza -l --icons --git  
la                           # → eza -la --icons --git
tree                         # → eza --tree --icons
```

#### bat (Better cat)
Syntax-highlighted file viewer with line numbers.

```bash
bat file.txt                 # View file with syntax highlighting
bat -n file.txt              # Show line numbers
bat -A file.txt              # Show all characters (whitespace, etc.)
bat --style=plain file.txt   # Plain output (no decorations)
bat --theme=ansi file.txt    # Use specific theme
bat -p file.txt              # Plain style (like cat)
bat --list-themes            # Show available themes

# Configuration options
export BAT_THEME="TwoDark"   # Set theme
export BAT_STYLE="numbers,changes,header" # Set style
```

#### ripgrep (Better grep)
Fast text search tool with smart defaults.

```bash
rg "pattern"                 # Basic search
rg -i "pattern"              # Case-insensitive search
rg -w "word"                 # Match whole words only
rg -v "pattern"              # Invert match (show non-matching lines)
rg --type rust "pattern"     # Search only in Rust files
rg --type-not log "pattern"  # Exclude log files
rg -C 3 "pattern"            # Show 3 lines of context
rg -A 2 -B 2 "pattern"       # Show 2 lines after and before
rg -n "pattern"              # Show line numbers
rg --no-heading "pattern"    # Don't group by file
rg -e "pattern1" -e "pattern2" # Multiple patterns
rg "pattern" --replace "replacement" # Search and replace preview
```

#### fd (Better find)
User-friendly file finder with intuitive syntax.

```bash
fd pattern                   # Find files/directories matching pattern
fd -e txt                    # Find files with .txt extension
fd -t f pattern              # Find only files (not directories)
fd -t d pattern              # Find only directories
fd -H pattern                # Include hidden files
fd -I pattern                # Don't respect .gitignore
fd -x command                # Execute command on each result
fd -X command                # Execute command with all results as arguments
fd --max-depth 2 pattern     # Limit search depth
fd --exclude "*.log" pattern # Exclude files matching pattern
```

#### zoxide (Better cd)
Smart directory jumping that learns your patterns.

```bash
z pattern                    # Jump to directory matching pattern
z foo bar                    # Jump to directory matching both "foo" and "bar"
zi                          # Interactive directory selection
zoxide query pattern        # Query without jumping
zoxide add /path             # Manually add directory
zoxide remove /path          # Remove directory from database

# The 'cd' alias is configured to use zoxide
cd pattern                   # Same as 'z pattern'
```

#### fzf (Fuzzy Finder)
Interactive fuzzy finder for files, command history, and more.

```bash
# Key bindings (automatic)
Ctrl+R                       # Search command history
Ctrl+T                       # Find and insert file paths
Alt+C                        # Find and cd to directory

# Manual usage
fzf                          # Interactive file selection
ls | fzf                     # Fuzzy select from ls output
history | fzf                # Fuzzy select from history
git branch | fzf             # Fuzzy select git branch

# With preview (configured)
fzf --preview 'bat {}'       # Preview files with bat
```

### System Monitoring

#### btop (Better top)
Beautiful and feature-rich system monitor.

```bash
btop                         # Launch system monitor

# Key bindings (in btop)
q                           # Quit
Esc                         # Go to main menu
f                           # Filter processes
/                           # Search processes
+/-                         # Change update speed
m                           # Show/hide memory graph
n                           # Show/hide network graph
```

#### dust (Better du)
Visual disk usage analyzer.

```bash
dust                         # Show disk usage of current directory
dust /path                   # Show disk usage of specific path
dust -d 3                    # Limit depth to 3 levels
dust -r                      # Reverse order (largest last)
dust -n 10                   # Show only top 10 items
dust -s                      # Summarize, don't show tree
```

#### procs (Better ps)
Modern process viewer with colors and additional information.

```bash
procs                        # Show all processes
procs firefox                # Show processes matching "firefox"
procs --tree                 # Show process tree
procs --watch                # Watch mode (live updates)
procs --sort cpu             # Sort by CPU usage
procs --sort memory          # Sort by memory usage
```

### Network and System Tools

#### httpie
User-friendly HTTP client for APIs.

```bash
http GET api.example.com/users              # GET request
http POST api.example.com/users name=John   # POST with data
http PUT api.example.com/users/1 name=Jane  # PUT request
http DELETE api.example.com/users/1         # DELETE request
http --auth user:pass GET api.example.com   # Authentication
http --json POST api.example.com data:='{}' # JSON data
http --form POST api.example.com file@path  # File upload
```

#### jq & jless
JSON processing and viewing tools.

```bash
# jq - JSON processor
echo '{"name": "John", "age": 30}' | jq .name
cat data.json | jq '.users[] | .name'
curl api.example.com | jq '.data[0]'

# jless - JSON viewer
jless data.json              # Interactive JSON viewer
curl api.example.com | jless # View API response
```

#### bandwhich
Network bandwidth monitor by process.

```bash
sudo bandwhich               # Monitor network usage by process
bandwhich --interface eth0   # Monitor specific interface
bandwhich --raw             # Raw output mode
```

## Development Environments

### JavaScript/Node.js

#### Runtime and Package Managers
```bash
# Node.js
node --version               # Check Node.js version
npm --version               # Check npm version

# Package managers
npm install                  # Install dependencies
yarn install                # Yarn alternative
pnpm install                # Fast pnpm alternative
bun install                 # Ultra-fast bun alternative

# Pre-configured aliases
ni                          # → npm install
nr                          # → npm run
nt                          # → npm test
yi                          # → yarn install
pi                          # → pnpm install
```

#### Development Tools
```bash
# TypeScript
tsc file.ts                  # Compile TypeScript
tsc --watch                  # Watch mode

# Linting and formatting
eslint file.js               # Lint JavaScript
prettier --write file.js     # Format code
stylelint styles.css         # Lint CSS
```

#### Project Creation
```bash
js-project-init my-app react     # Create React project
js-project-init my-api node      # Create Node.js project
js-project-init my-app vue       # Create Vue project
package-json-gen                 # Generate package.json with scripts
```

### Rust

#### Cargo Commands
```bash
# Basic operations
cargo new my-project         # Create new project
cargo build                  # Build project
cargo run                   # Build and run
cargo test                  # Run tests
cargo check                 # Check compilation without building
cargo clean                 # Clean build artifacts

# Pre-configured aliases
c                           # → cargo
cb                          # → cargo build
cr                          # → cargo run
ct                          # → cargo test
ccl                         # → cargo clippy
```

#### Development Tools
```bash
# Code quality
cargo clippy                 # Lint code
cargo fmt                   # Format code
cargo audit                 # Security audit
cargo outdated              # Check for outdated dependencies

# Development workflow
cargo watch -x test         # Watch and run tests
cargo watch -x run          # Watch and run
bacon                       # Background code checker
```

#### Project Creation
```bash
rust-project-init my-project bin        # Create binary project
rust-project-init my-lib lib           # Create library project
rust-project-init my-workspace workspace # Create workspace
```

### Python

#### Python Tools
```bash
python --version             # Check Python version
pip install package          # Install package
poetry install              # Poetry package manager
black file.py               # Format code
ruff file.py                # Fast linter
```

### Go

#### Go Commands
```bash
go version                   # Check Go version
go build                    # Build project
go run main.go              # Build and run
go test                     # Run tests
go mod init module-name     # Initialize module
go mod tidy                 # Clean up dependencies
```

## Git Integration

### Git Aliases (Configured)
```bash
# Basic operations
git s                       # → git status
git a                       # → git add
git c                       # → git commit
git p                       # → git push
git l                       # → git pull

# Branch operations
git co                      # → git checkout
git br                      # → git branch
git sw                      # → git switch

# Useful shortcuts
git unstage                 # → git reset HEAD --
git last                    # → git log -1 HEAD
git visual                  # → gitk
```

### Git Tools
```bash
# lazygit - Terminal UI
lg                          # Launch lazygit
lazygit                     # Full command

# delta - Better diff
git diff                    # Uses delta for enhanced diff display
```

## Editor and Development

### Neovim
Pre-configured with LSP support for multiple languages.

```bash
nvim file.txt               # Edit file
nvim +PlugInstall           # Install plugins
nvim +checkhealth           # Check configuration health
```

## Utility Commands

### File Management
```bash
# Archiving
tar -czf archive.tar.gz folder    # Create tar.gz archive
tar -xzf archive.tar.gz          # Extract tar.gz archive

# File operations
cp -r source/ dest/              # Copy directory recursively
rsync -av source/ dest/          # Sync directories
```

### Text Processing
```bash
# sed alternative (sd)
sd 'old text' 'new text' file.txt    # Replace text in file
echo 'hello world' | sd 'world' 'universe'  # Replace in pipe

# yq - YAML processor
yq '.key.subkey' file.yaml       # Extract YAML value
yq -i '.key.subkey = "value"' file.yaml  # Modify YAML file
```

### Documentation
```bash
# tldr - Simplified man pages
tldr command                     # Quick examples for command
tldr --update                   # Update tldr database

# Traditional documentation
man command                     # Full manual page
info command                    # GNU info documentation
command --help                  # Command help (most tools)
```

## Configuration Locations

### Tool Configurations
- **Fish Shell**: `~/.config/fish/` (managed by home-manager)
- **Git**: `~/.gitconfig` (linked from `config/git/.gitconfig`)
- **WezTerm**: `~/.wezterm.lua` (linked from `config/wezterm/.wezterm.lua`)
- **Neovim**: `~/.config/nvim/` (managed by home-manager)

### Nix Configurations
- **Home Manager**: `home/home.nix` and related files
- **System Config**: `darwin/darwin.nix` (macOS) or `nixos/configuration.nix` (NixOS)
- **Development Modules**: `modules/dev/*.nix`

## Environment Variables

### Important Variables Set
```bash
# Development
CARGO_HOME="${HOME}/.cargo"      # Rust/Cargo home
NODE_OPTIONS="--max-old-space-size=4096"  # Node.js memory
RUST_BACKTRACE=1                # Rust error traces

# Tool configuration  
BAT_THEME="TwoDark"             # bat theme
RUST_LOG="info"                 # Rust logging level
```

### Path Additions
```bash
# Additional paths added to $PATH
${HOME}/.cargo/bin              # Rust binaries
${HOME}/.local/share/pnpm       # pnpm binaries
${HOME}/.local/bin              # User scripts
```

This reference covers the most commonly used tools and commands. For more detailed information about specific tools, use their `--help` flags or check their respective documentation.