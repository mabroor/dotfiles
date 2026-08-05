# Rust development environment.
#
# Packages live in the flake's `rust` devShell, not in the user profile:
#   nix develop github:mabroor/dotfiles#rust
# Only shell ergonomics are configured here, so these aliases cost nothing on
# machines that never touch Rust.
{ config, ... }:

{
  programs.fish.shellAliases = {
    # Cargo basics. Note there is deliberately no `cc` alias — that is the C
    # compiler, and shadowing it breaks configure scripts and hand-run builds.
    "c" = "cargo";
    "cb" = "cargo build";
    "cbr" = "cargo build --release";
    "cch" = "cargo check";
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
    "ctree" = "cargo tree";
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
    "crmdep" = "cargo rm";
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

    "ccross" = "cargo cross";

    # WebAssembly
    "wpack" = "wasm-pack";
    "wpack-build" = "wasm-pack build --target web";
  };

  home.sessionVariables = {
    CARGO_HOME = "${config.home.homeDirectory}/.cargo";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/.cargo/bin"
  ];

  # Machine-wide cargo defaults.
  #
  # Deliberately absent: [profile.*] tables. Cargo's config profiles take
  # precedence over each project's Cargo.toml, so setting panic/lto/debug here
  # silently overrode every crate on the machine — `panic = "abort"` in
  # particular disabled catch_unwind for all release builds.
  #
  # Also absent: CARGO_TARGET_DIR, CARGO_INCREMENTAL, RUST_LOG and
  # RUST_BACKTRACE as session variables. CARGO_TARGET_DIR resolves relative to
  # the cwd, so it broke workspace target sharing, and env vars outrank a
  # project's own .cargo/config.toml.
  home.file.".cargo/config.toml".text = ''
    [cargo-new]
    vcs = "git"

    [registry]
    default = "crates-io"

    [net]
    # Use the git CLI so private-repo credentials work.
    git-fetch-with-cli = true

    [alias]
    b = "build"
    ch = "check"
    t = "test"
    r = "run"

    lint = "clippy --all-targets --all-features -- -D warnings"
    fmt-all = "fmt --all"

    deps = "tree"
    why = "tree --invert"
  '';
}
