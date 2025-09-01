# Rust development environment (enhanced)
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Rust toolchain (already included in your current setup)
    rustc            # Rust compiler
    cargo            # Rust package manager
    rustfmt          # Rust formatter
    rust-analyzer    # Rust language server
    clippy           # Rust linter
    
    # Additional Rust tools
    cargo-watch      # Watch for changes and run cargo commands
    cargo-edit       # Edit Cargo.toml from command line
    cargo-expand     # Show macro expansions
    cargo-outdated   # Check for outdated dependencies
    cargo-audit      # Security vulnerability scanner
    cargo-deny       # Cargo plugin for linting dependencies
    cargo-machete    # Find unused dependencies
    cargo-nextest    # Next-generation test runner
    cargo-criterion  # Benchmarking tool
    cargo-flamegraph # Profiling tool
    cargo-bloat      # Find what takes most space in binary
    cargo-update     # Update installed executables
    cargo-generate   # Generate projects from templates
    bacon            # Background rust code checker
    
    # Cross-compilation and targets
    cargo-cross      # Cross-compilation tool
    
    # WebAssembly tools
    wasm-pack        # Build Rust for the web
    wasmtime         # WebAssembly runtime
    
    # Debugging and profiling
    gdb              # GNU debugger
    valgrind         # Memory error detector
    heaptrack        # Heap memory profiler
    
    # Documentation tools
    mdbook           # Create books from markdown
  ];

  # Shell aliases for Rust development
  programs.fish.shellAliases = {
    # Cargo aliases
    "c" = "cargo";
    "cb" = "cargo build";
    "cbr" = "cargo build --release";
    "cc" = "cargo check";
    "ccl" = "cargo clippy";
    "cclf" = "cargo clippy --fix";
    "cr" = "cargo run";
    "crr" = "cargo run --release";
    "ct" = "cargo test";
    "ctv" = "cargo test -- --nocapture";
    "ctre" = "cargo test --release";
    "cf" = "cargo fmt";
    "cfc" = "cargo fmt --check";
    "cdoc" = "cargo doc";
    "cdo" = "cargo doc --open";
    "cbn" = "cargo bench";
    "cex" = "cargo expand";
    "cup" = "cargo update";
    "cud" = "cargo outdated";
    "cau" = "cargo audit";
    "ctr" = "cargo tree";
    "cin" = "cargo install";
    "cun" = "cargo uninstall";
    "cpub" = "cargo publish";
    "csearch" = "cargo search";
    "cclean" = "cargo clean";
    "cfix" = "cargo fix";
    
    # Cargo with features
    "cbf" = "cargo build --features";
    "crf" = "cargo run --features";
    "ctf" = "cargo test --features";
    
    # Cargo workspaces
    "cball" = "cargo build --workspace";
    "ctall" = "cargo test --workspace";
    "cfall" = "cargo fmt --all";
    
    # Cargo edit (adding/removing dependencies)
    "cadd" = "cargo add";
    "crm" = "cargo rm";
    "cupgrade" = "cargo upgrade";
    
    # Development tools
    "cwatch" = "cargo watch";
    "cwt" = "cargo watch -x test";
    "cwc" = "cargo watch -x check";
    "cwr" = "cargo watch -x run";
    "cnx" = "cargo nextest run";
    "cnxw" = "cargo watch -x 'nextest run'";
    
    # Profiling and analysis
    "cbloat" = "cargo bloat";
    "cflame" = "cargo flamegraph";
    "cmachete" = "cargo machete";
    
    # Cross-compilation
    "ccross" = "cargo cross";
    
    # WebAssembly
    "wpack" = "wasm-pack";
    "wpack-build" = "wasm-pack build --target web";
    
    # Rust utilities
    "rustup-update" = "rustup update";
    "rustc-version" = "rustc --version";
    "cargo-version" = "cargo --version";
  };

  # Environment variables
  home.sessionVariables = {
    # Rust configuration
    CARGO_HOME = "${config.home.homeDirectory}/.cargo";
    RUSTUP_HOME = "${config.home.homeDirectory}/.rustup";
    
    # Cargo configuration
    CARGO_TARGET_DIR = "target"; # Can be overridden per project
    
    # Rust compilation flags for better debugging
    RUST_BACKTRACE = "1";
    RUST_LOG = "info";
    
    # Cargo build jobs (adjust based on your CPU cores)
    # CARGO_BUILD_JOBS = "8"; # Set to specific number, or omit to use default
    
    # Faster incremental compilation
    CARGO_INCREMENTAL = "1";
  };

  # Add cargo bin to PATH
  home.sessionPath = [
    "${config.home.homeDirectory}/.cargo/bin"
  ];

  # Rust project initialization script
  home.file.".local/bin/rust-project-init" = {
    text = ''
      #!/usr/bin/env bash
      # Rust project initialization script
      
      set -euo pipefail
      
      PROJECT_NAME="$1"
      PROJECT_TYPE="''${2:-bin}" # bin, lib, workspace
      
      if [ -z "$PROJECT_NAME" ]; then
          echo "Usage: $0 <project-name> [project-type]"
          echo "Project types: bin, lib, workspace"
          exit 1
      fi
      
      echo "🦀 Creating Rust project: $PROJECT_NAME ($PROJECT_TYPE)"
      
      case "$PROJECT_TYPE" in
          "lib")
              cargo new "$PROJECT_NAME" --lib
              ;;
          "workspace")
              mkdir "$PROJECT_NAME"
              cd "$PROJECT_NAME"
              cat > Cargo.toml << 'EOF'
      [workspace]
      members = [
          "crates/*",
      ]
      resolver = "2"
      
      [workspace.package]
      version = "0.1.0"
      edition = "2021"
      authors = ["Your Name <your.email@example.com>"]
      license = "MIT OR Apache-2.0"
      repository = "https://github.com/username/project"
      
      [workspace.dependencies]
      # Common dependencies across workspace
      serde = { version = "1.0", features = ["derive"] }
      tokio = { version = "1.0", features = ["full"] }
      anyhow = "1.0"
      thiserror = "1.0"
      EOF
              mkdir -p crates
              cd crates
              cargo new --lib core
              cargo new --bin cli
              cd ..
              ;;
          *)
              cargo new "$PROJECT_NAME"
              ;;
      esac
      
      if [ "$PROJECT_TYPE" != "workspace" ]; then
          cd "$PROJECT_NAME"
      fi
      
      # Add common development dependencies
      if [ "$PROJECT_TYPE" != "workspace" ]; then
          cargo add --dev criterion --features html_reports
          cargo add --dev proptest
          cargo add anyhow thiserror
          
          if [ "$PROJECT_TYPE" = "bin" ]; then
              cargo add clap --features derive
              cargo add env_logger
              cargo add log
          fi
      fi
      
      # Create additional configuration files
      cat > .gitignore << 'EOF'
      # Rust
      /target/
      Cargo.lock
      
      # IDE
      .vscode/
      .idea/
      
      # OS
      .DS_Store
      Thumbs.db
      
      # Flamegraph
      flamegraph.svg
      perf.data*
      
      # Criterion benchmarks
      criterion/
      EOF
      
      # Create Cargo configuration
      mkdir -p .cargo
      cat > .cargo/config.toml << 'EOF'
      [build]
      # Use a faster linker on macOS
      # rustflags = ["-C", "link-arg=-fuse-ld=lld"]
      
      [target.x86_64-unknown-linux-gnu]
      # Use lld linker for faster builds on Linux
      # rustflags = ["-C", "link-arg=-fuse-ld=lld"]
      
      [alias]
      # Useful cargo aliases
      b = "build"
      c = "check"
      t = "test"
      r = "run"
      br = "build --release"
      tr = "test --release"
      rr = "run --release"
      
      # Development aliases
      dev = "watch -x check"
      test-watch = "watch -x test"
      
      # Quality aliases
      lint = "clippy -- -D warnings"
      fmt-check = "fmt -- --check"
      
      # Documentation
      doc-open = "doc --open"
      
      # Dependencies
      deps = "tree"
      outdated = "outdated"
      audit = "audit"
      EOF
      
      # Create justfile for task running
      cat > justfile << 'EOF'
      # List available recipes
      default:
          @just --list
      
      # Run the project
      run *args:
          cargo run {{args}}
      
      # Build the project
      build:
          cargo build
      
      # Build for release
      build-release:
          cargo build --release
      
      # Run tests
      test:
          cargo test
      
      # Run tests with output
      test-verbose:
          cargo test -- --nocapture
      
      # Run benchmarks
      bench:
          cargo bench
      
      # Check the project
      check:
          cargo check
      
      # Format code
      fmt:
          cargo fmt
      
      # Lint code
      lint:
          cargo clippy -- -D warnings
      
      # Check formatting
      fmt-check:
          cargo fmt --check
      
      # Run all quality checks
      quality: fmt-check lint test
      
      # Clean build artifacts
      clean:
          cargo clean
      
      # Update dependencies
      update:
          cargo update
      
      # Audit dependencies for vulnerabilities
      audit:
          cargo audit
      
      # Show dependency tree
      tree:
          cargo tree
      
      # Watch for changes and run tests
      watch:
          cargo watch -x test
      
      # Watch for changes and check
      watch-check:
          cargo watch -x check
      
      # Generate documentation and open
      doc:
          cargo doc --open
      
      # Profile with flamegraph
      profile:
          cargo flamegraph --bin {{PROJECT_NAME}}
      EOF
      
      # Create GitHub Actions workflow if it's a git repo
      if [ -d ".git" ] || git rev-parse --git-dir > /dev/null 2>&1; then
          mkdir -p .github/workflows
          cat > .github/workflows/ci.yml << 'EOF'
      name: CI
      
      on:
        push:
          branches: [ main, develop ]
        pull_request:
          branches: [ main ]
      
      env:
        CARGO_TERM_COLOR: always
      
      jobs:
        test:
          name: Test
          runs-on: ubuntu-latest
          strategy:
            matrix:
              rust: [stable, beta, nightly]
          steps:
          - uses: actions/checkout@v4
          - uses: dtolnay/rust-toolchain@master
            with:
              toolchain: ''${{ matrix.rust }}
          - uses: Swatinem/rust-cache@v2
          - name: Run tests
            run: cargo test --verbose
      
        fmt:
          name: Rustfmt
          runs-on: ubuntu-latest
          steps:
          - uses: actions/checkout@v4
          - uses: dtolnay/rust-toolchain@stable
            with:
              components: rustfmt
          - name: Check formatting
            run: cargo fmt --check
      
        clippy:
          name: Clippy
          runs-on: ubuntu-latest
          steps:
          - uses: actions/checkout@v4
          - uses: dtolnay/rust-toolchain@stable
            with:
              components: clippy
          - uses: Swatinem/rust-cache@v2
          - name: Run clippy
            run: cargo clippy -- -D warnings
      
        security_audit:
          name: Security audit
          runs-on: ubuntu-latest
          steps:
          - uses: actions/checkout@v4
          - uses: rustsec/audit-check@v1.4.1
            with:
              token: ''${{ secrets.GITHUB_TOKEN }}
      EOF
      fi
      
      # Create README
      cat > README.md << EOF
      # $PROJECT_NAME
      
      A Rust $PROJECT_TYPE project.
      
      ## Development
      
      \`\`\`bash
      # Install Just task runner
      cargo install just
      
      # See available tasks
      just
      
      # Run the project
      just run
      
      # Run tests
      just test
      
      # Check code quality
      just quality
      
      # Watch for changes
      just watch
      \`\`\`
      
      ## Manual Commands
      
      \`\`\`bash
      # Build and run
      cargo run
      
      # Run tests
      cargo test
      
      # Build for release
      cargo build --release
      
      # Format code
      cargo fmt
      
      # Lint code
      cargo clippy
      
      # Generate documentation
      cargo doc --open
      \`\`\`
      EOF
      
      echo "✅ Rust project $PROJECT_NAME created successfully!"
      echo "📁 Navigate to the project: cd $PROJECT_NAME"
      echo "🦀 Start development: just watch"
      echo "🧪 Run tests: just test"
    '';
    executable = true;
  };

  # Cargo configuration for better defaults
  home.file.".cargo/config.toml" = {
    text = ''
      [build]
      # Enable faster builds with multiple cores
      # jobs = 8  # Set to a specific number, or omit to use default (number of CPUs)
      # Note: jobs = 0 is invalid in Cargo and will cause errors
      
      [cargo-new]
      # Default template for new projects
      vcs = "git"
      
      [registry]
      default = "crates-io"
      
      # Vendored sources configuration (disabled by default)
      # Only enable if you have a vendor directory with dependencies
      # [source.crates-io]
      # replace-with = "vendored-sources"
      # 
      # [source.vendored-sources]
      # directory = "/absolute/path/to/vendor"
      
      [net]
      # Use Git CLI for authentication (helps with private repos)
      git-fetch-with-cli = true
      
      [alias]
      # Useful aliases
      b = "build"
      c = "check"
      t = "test"
      r = "run"
      
      # Development workflow aliases
      dev = "watch -x 'check --color=always'"
      test-watch = "watch -x 'test --color=always'"
      
      # Quality assurance
      lint = "clippy --all-targets --all-features -- -D warnings"
      fmt-all = "fmt --all"
      
      # Information
      deps = "tree --format '{p} {f}'"
      why = "tree --invert"
      
      # Clean shortcuts
      cc = "clean"
      
      [target.x86_64-apple-darwin]
      # macOS-specific optimizations can go here
      
      [target.aarch64-apple-darwin]
      # Apple Silicon specific optimizations can go here
      
      [profile.dev]
      # Faster debug builds
      debug = 1
      
      [profile.release]
      # Optimize for size and speed
      lto = true
      codegen-units = 1
      panic = "abort"
    '';
  };
}
