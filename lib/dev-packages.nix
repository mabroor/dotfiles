# Per-language development package sets.
#
# These back the flake's devShells. They deliberately do NOT go into the user
# profile: installing all four languages globally cost ~11 GiB and pulled in
# things like matplotlib, prisma and jupyter on machines that never used them.
# Enter a shell instead:  nix develop github:mabroor/dotfiles#rust
{ pkgs }:

let
  inherit (pkgs) lib stdenv;
  onLinux = lib.optionals stdenv.isLinux;
in
with pkgs;
{
  # Tooling for working on this repo itself.
  nix = [
    nixpkgs-fmt
    statix
    deadnix
    nil
  ];

  rust = [
    rustc
    cargo
    rustfmt
    rust-analyzer
    clippy

    cargo-watch
    cargo-edit
    cargo-expand
    cargo-outdated
    cargo-audit
    cargo-deny
    cargo-machete
    cargo-nextest
    cargo-criterion
    cargo-flamegraph
    cargo-bloat
    cargo-update
    cargo-generate
    bacon

    cargo-cross

    # WebAssembly
    trunk
    wasm-pack
    wasmtime

    lldb
    lld
    mdbook
  ]
  # gdb/valgrind/heaptrack are Linux-only; valgrind is marked broken on Darwin.
  ++ onLinux [
    gdb
    valgrind
    heaptrack
  ];

  go = [
    go
    gopls
    golangci-lint
    gofumpt
    gotools
    gomodifytags
    gotests
    golines

    delve
    go-tools

    protobuf
    protoc-gen-go
    protoc-gen-go-grpc

    go-migrate
    sqlc
    air

    goreleaser
    gotestsum
    gox
    govulncheck
  ]
  # buildah is Linux-only.
  ++ onLinux [ buildah ];

  # Interpreter plus tooling. Project libraries belong in the project's own
  # flake, not here — see pythonData below for the batteries-included variant.
  python = [
    python313
    pypy3

    python313Packages.pip
    pipx
    poetry
    python313Packages.virtualenv
    pipenv

    black
    isort
    python313Packages.flake8
    mypy
    pylint
    python313Packages.autopep8
    ruff

    pyright
    python313Packages.rope
    python313Packages.jedi

    python313Packages.pytest
    python313Packages.pytest-cov
    python313Packages.pytest-xdist
    python313Packages.tox
    python313Packages.coverage

    python313Packages.sphinx
    python313Packages.mkdocs

    python313Packages.ipdb
    # py-spy's test suite needs ptrace access that sandboxed builds do not have.
    (py-spy.overrideAttrs (_: { doCheck = false; }))
  ];

  # The data-science and web stack, kept separate because it is several GiB.
  pythonData = [
    python313Packages.requests
    python313Packages.fastapi
    python313Packages.flask
    python313Packages.django
    python313Packages.numpy
    python313Packages.pandas
    python313Packages.matplotlib
    python313Packages.jupyter
    python313Packages.ipython

    python313Packages.psycopg2
    python313Packages.pymongo
    python313Packages.redis
    python313Packages.sqlalchemy
    python313Packages.alembic

    python313Packages.click
    python313Packages.rich
    python313Packages.typer
    python313Packages.pydantic
    python313Packages.httpx
    python313Packages.aiohttp
  ];

  javascript = [
    nodejs_22
    yarn
    pnpm
    bun

    typescript
    typescript-language-server
    vscode-langservers-extracted
    prettier
    eslint
    stylelint

    webpack-cli

    nodemon
    concurrently
    npm-check-updates

    svelte-language-server
    prisma
    jsdoc
  ];
}
