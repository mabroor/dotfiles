# Project Templates

This directory contains Nix flake templates for quick project initialization with comprehensive development environments.

## Available Templates

### Rust Template

```bash
nix flake init -t github:mabroor/dotfiles#rust
# or
nix flake new my-rust-project -t github:mabroor/dotfiles#rust
```

Features:

- Rust stable toolchain with rust-analyzer, clippy, and rust-src
- Development tools: bacon, cargo-watch, cargo-edit, cargo-expand
- Testing tools: cargo-nextest
- Profiling: cargo-flamegraph
- Cross-platform dependencies (macOS and Linux support)

### JavaScript/Node.js Template

```bash
nix flake init -t github:mabroor/dotfiles#javascript
# or
nix flake new my-js-project -t github:mabroor/dotfiles#javascript
```

Features:

- Node.js 20 with multiple package managers (npm, yarn, pnpm, bun)
- TypeScript and language server support
- Development tools: Prettier, ESLint, Vite, Webpack
- Testing framework: Jest
- Utilities: nodemon, npm-check-updates

### Python Template

```bash
nix flake init -t github:mabroor/dotfiles#python
# or  
nix flake new my-python-project -t github:mabroor/dotfiles#python
```

Features:

- Python 3.11 with Poetry support
- Code quality tools: Black, isort, Ruff, MyPy
- Testing: pytest with coverage
- Language server: Pyright
- System dependencies for common Python packages

## Usage

1. **Create a new project from template:**
   ```bash
   mkdir my-project
   cd my-project
   nix flake init -t github:mabroor/dotfiles#rust
   ```

2. **Enter the development environment:**
   ```bash
   nix develop
   ```

3. **Start developing:**
   The shell hook will show you available commands and workflows.

## Template Structure

Each template includes:
- `flake.nix` - Nix flake with development shell and package definitions
- Development dependencies and tools
- Environment variables and shell hooks
- Package configurations for building and distribution
- Cross-platform support (macOS and Linux)

## Customization

After initializing a template:
1. Update the package name and metadata in `flake.nix`
2. Adjust dependencies based on your project needs  
3. Modify shell hooks and environment variables
4. Update package build configurations
5. Add or remove development tools as needed

## Local Development

When developing these templates locally:

```bash
# Test a template locally
nix flake init -t .#rust

# Enter development shell
nix develop

# Build the package
nix build
```
