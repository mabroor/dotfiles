# Developer Guide

This guide is for developers who want to enhance, customize, or contribute to this dotfiles repository. Whether you're adding new tools, creating new development environments, or improving existing configurations, this guide will help you understand the architecture and development workflow.

## Architecture Overview

### Repository Structure

```
dotfiles/
├── flake.nix              # Main entry point - defines all configurations
├── flake.lock             # Locked dependency versions
├── home/                  # Home-manager configurations (user-level)
│   ├── home.nix          # Main home configuration
│   ├── git.nix           # Git configuration and aliases
│   ├── wezterm.nix       # Terminal configuration
│   ├── neovim.nix        # Editor configuration
│   └── *.nix             # Other tool configurations
├── darwin/               # macOS system configurations
│   └── darwin.nix        # System-level macOS settings
├── nixos/               # NixOS system configurations
│   └── configuration.nix # NixOS system configuration
├── hosts/               # Per-machine configurations
│   ├── AMAFCXNW09RYR/   # Apple Silicon Mac config
│   ├── Mabroors-MacBook-Pro/ # Intel Mac config
│   └── nixos/           # NixOS machine config
├── modules/             # Reusable development environment modules
│   └── dev/             # Development environment definitions
│       ├── javascript.nix # Node.js/JS development environment
│       ├── rust.nix      # Rust development environment
│       ├── python.nix    # Python development environment
│       └── go.nix        # Go development environment
├── lib/                 # Helper functions and utilities
│   └── mkSystem.nix     # System builder functions
├── templates/           # Project template definitions
│   ├── rust/            # Rust project template
│   ├── javascript/      # JavaScript project template
│   └── python/          # Python project template
├── config/              # Raw configuration files
│   ├── git/             # Git dotfiles
│   └── wezterm/         # WezTerm configuration
└── scripts/             # Utility scripts
    ├── rebuild.sh       # Quick rebuild script
    └── update.sh        # Update script
```

### Design Principles

1. **Modularity** - Each tool/language has its own module
2. **Cross-platform** - Same configuration works on macOS and NixOS
3. **Layered Configuration** - System → User → Host-specific overrides
4. **Declarative** - Everything is defined in Nix expressions
5. **Reproducible** - Locked dependencies ensure consistent builds

## Development Workflow

### Setting Up Development Environment

1. **Clone and enter the repository:**
   ```bash
   cd ~/src/github.com/mabroor/dotfiles
   ```

2. **Make changes to configuration files**

3. **Test changes:**
   ```bash
   # Check configuration syntax
   nix flake check
   
   # Preview what would change (dry-run)
   darwin-rebuild switch --flake . --dry-run  # macOS
   sudo nixos-rebuild switch --flake . --dry-run  # NixOS
   ```

4. **Apply changes:**
   ```bash
   darwin-rebuild switch --flake .  # macOS
   sudo nixos-rebuild switch --flake .  # NixOS
   ```

5. **Commit changes:**
   ```bash
   git add .
   git commit -m "feat: description of changes"
   git push
   ```

### Making Changes

#### Adding New Packages

1. **User-level packages** - Edit `home/home.nix`:
   ```nix
   home.packages = with pkgs; [
     # existing packages...
     new-package
   ];
   ```

2. **System-level packages** - Edit `darwin/darwin.nix` or `nixos/configuration.nix`:
   ```nix
   environment.systemPackages = [
     pkgs.new-system-package
   ];
   ```

#### Creating New Development Environments

1. **Create new module** in `modules/dev/`:
   ```nix
   # modules/dev/mylang.nix
   { config, pkgs, ... }:
   {
     home.packages = with pkgs; [
       mylang-compiler
       mylang-lsp
       mylang-formatter
     ];
     
     programs.fish.shellAliases = {
       "ml" = "mylang";
       "mlb" = "mylang build";
       "mlr" = "mylang run";
     };
     
     home.sessionVariables = {
       MYLANG_HOME = "${config.home.homeDirectory}/.mylang";
     };
   }
   ```

2. **Import in home.nix:**
   ```nix
   imports = [
     # existing imports...
     ../modules/dev/mylang.nix
   ];
   ```

#### Adding Shell Aliases

Add to the appropriate module's `programs.fish.shellAliases` section:

```nix
programs.fish.shellAliases = {
  "myalias" = "my-command --with-options";
  "shortcut" = "long-command-name";
};
```

#### Configuring Tools

Most tools can be configured through home-manager:

```nix
programs.toolname = {
  enable = true;
  settings = {
    option1 = "value1";
    option2 = true;
  };
};
```

### Creating Project Templates

1. **Create template directory** in `templates/`:
   ```bash
   mkdir templates/mylang
   cd templates/mylang
   ```

2. **Add template files:**
   ```nix
   # templates/mylang/flake.nix
   {
     description = "MyLang development environment";
     
     inputs = {
       nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
       flake-utils.url = "github:numtide/flake-utils";
     };
     
     outputs = { self, nixpkgs, flake-utils }:
       flake-utils.lib.eachDefaultSystem (system:
         let
           pkgs = nixpkgs.legacyPackages.${system};
         in
         {
           devShells.default = pkgs.mkShell {
             buildInputs = with pkgs; [
               mylang-compiler
               mylang-lsp
             ];
           };
         }
       );
   }
   ```

3. **Register template** in main `flake.nix`:
   ```nix
   templates = {
     # existing templates...
     mylang = {
       path = ./templates/mylang;
       description = "MyLang project with development environment";
     };
   };
   ```

### Advanced Configuration

#### Adding System Defaults (macOS)

Edit `darwin/darwin.nix` to add macOS system preferences:

```nix
system.defaults = {
  NSGlobalDomain = {
    MyNewSetting = true;
  };
  
  # App-specific settings
  CustomUserPreferences = {
    "com.example.app" = {
      MySetting = "value";
    };
  };
};
```

#### Adding Homebrew Packages (macOS)

For GUI applications not available in nixpkgs:

```nix
homebrew = {
  casks = [
    "existing-app"
    "new-gui-app"
  ];
  
  masApps = {
    "App Store App" = 123456789;
  };
};
```

#### Cross-Platform Considerations

Use conditional logic for platform-specific configurations:

```nix
{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    # Cross-platform packages
    universal-tool
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    # macOS-only packages
    darwin-specific-tool
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # Linux-only packages
    linux-specific-tool
  ];
}
```

## Best Practices

### Code Organization

1. **One concern per file** - Keep configurations focused
2. **Use descriptive names** - File and variable names should be clear
3. **Group related settings** - Keep similar configurations together
4. **Comment complex logic** - Explain non-obvious configurations

### Package Management

1. **Prefer nixpkgs** - Use official packages when available
2. **Pin versions for stability** - Use specific versions for critical tools
3. **Document external sources** - Explain why external packages are needed

### Configuration Management

1. **Test before committing** - Always test changes locally first
2. **Use semantic commits** - Follow conventional commit format
3. **Document breaking changes** - Update relevant documentation
4. **Keep backups** - Git history is your safety net

### Performance

1. **Lazy loading** - Only load what's needed
2. **Cache builds** - Use Nix build caches when possible
3. **Minimize rebuilds** - Structure changes to minimize impact

## Contributing

### Contribution Guidelines

1. **Fork the repository**
2. **Create feature branch** - Use descriptive branch names
3. **Make focused changes** - One feature/fix per PR
4. **Test thoroughly** - Test on relevant platforms
5. **Document changes** - Update relevant documentation
6. **Follow code style** - Match existing patterns

### Coding Standards

1. **Nix formatting** - Use `nixpkgs-fmt` for consistent formatting
2. **Variable naming** - Use camelCase for Nix variables
3. **Indentation** - Use 2 spaces for indentation
4. **Comments** - Document complex logic and decisions

### Testing Changes

1. **Syntax check:**
   ```bash
   nix flake check
   ```

2. **Build test:**
   ```bash
   nix build .#darwinConfigurations.HOSTNAME.system
   ```

3. **Integration test:**
   ```bash
   darwin-rebuild switch --flake . --dry-run
   ```

### Documentation

When adding features:

1. **Update user guide** - Document user-facing changes
2. **Update tool reference** - Add new tools to reference
3. **Update README** - Reflect major architectural changes
4. **Add code comments** - Explain complex configurations

## Common Tasks

### Adding a New Language Environment

1. Create `modules/dev/newlang.nix`
2. Define packages, aliases, and environment variables
3. Import in `home/home.nix`
4. Create project template in `templates/newlang/`
5. Register template in main `flake.nix`
6. Update documentation

### Adding a New Host Configuration

1. Create directory `hosts/NEW-HOSTNAME/`
2. Create `hosts/NEW-HOSTNAME/default.nix`
3. Add configuration to `flake.nix` outputs
4. Test and document

### Updating Dependencies

1. Update flake inputs:
   ```bash
   nix flake update
   ```

2. Test changes:
   ```bash
   nix flake check
   darwin-rebuild switch --flake .
   ```

3. Commit lock file changes

## Troubleshooting Development

### Common Issues

1. **Build failures** - Check syntax and dependency availability
2. **Missing packages** - Verify package names in nixpkgs
3. **Permission issues** - Check file permissions and ownership
4. **Platform conflicts** - Use conditional logic for platform differences

### Debugging Tools

```bash
nix flake check --show-trace    # Detailed error information
nix-instantiate --eval --strict # Evaluate Nix expressions
nix repl '<nixpkgs>'           # Interactive Nix REPL
```

### Recovery

If configuration breaks:

1. **Rollback system:**
   ```bash
   darwin-rebuild --rollback  # macOS
   sudo nixos-rebuild --rollback  # NixOS
   ```

2. **Fix configuration and reapply**

3. **Use git history to identify issues**

## Resources

### Nix Documentation
- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [nix-darwin Manual](https://github.com/LnL7/nix-darwin)

### Learning Resources
- [Nix Pills](https://nixos.org/guides/nix-pills/) - Deep dive into Nix
- [NixOS Wiki](https://nixos.wiki/) - Community knowledge base
- [Home Manager Options](https://mipmip.github.io/home-manager-option-search/) - Searchable options

### Community
- [NixOS Discourse](https://discourse.nixos.org/)
- [r/NixOS](https://www.reddit.com/r/NixOS/)
- [NixOS Matrix Channels](https://nixos.org/community.html#chat)

Happy hacking! 🚀