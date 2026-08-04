# Go development environment.
#
# Packages live in the flake's `go` devShell:
#   nix develop github:mabroor/dotfiles#go
{ config, ... }:

{
  programs.fish.shellAliases = {
    # Go command aliases
    "gob" = "go build";
    "goc" = "go clean";
    "god" = "go doc";
    "gof" = "go fmt";
    "gog" = "go get";
    "goi" = "go install";
    "gom" = "go mod";
    "gor" = "go run";
    "got" = "go test";
    "gotv" = "go test -v";
    "gotc" = "go test -cover";
    "gotb" = "go test -bench=.";
    "gov" = "go version";
    "gow" = "go work";

    # Go mod aliases
    "gomi" = "go mod init";
    "gomt" = "go mod tidy";
    "gomv" = "go mod verify";
    "gomd" = "go mod download";
    "goms" = "go mod sum";

    # Go install aliases
    "goit" = "go install -tags";
    "goil" = "go install -ldflags";

    # Testing aliases
    "gotr" = "go test -race";
    "gotall" = "go test ./...";
    "gotshort" = "go test -short";
    "gotjson" = "go test -json";

    # Build aliases
    "gobr" = "go build -race";
    "gobl" = "go build -ldflags";
    "gobt" = "go build -tags";

    # Formatting and linting.
    #
    # These deliberately do not reuse the tools' own names: aliasing `gofmt` to
    # `gofmt -s -w` turned a print-to-stdout command into an in-place rewrite,
    # so piping it or previewing a diff silently mutated the working tree.
    "gofmtw" = "gofmt -s -w";
    "goimp" = "goimports -w";
    "golint" = "golangci-lint run";
    "golintf" = "golangci-lint run --fix";
    "gofumptw" = "gofumpt -w";

    # Debugging. `dlv` itself is left alone so attach/exec/connect/dap still
    # work; previously `dlvt` expanded through the `dlv` alias and ran
    # `dlv debug test`.
    "dlvd" = "dlv debug";
    "dlvt" = "dlv test";

    # Utilities
    "golist" = "go list -m all";
    "gowork" = "go work sync";
    "govuln" = "govulncheck";

    # Air (live reload)
    "gowatch" = "air";
  };

  # Only path-ish settings are exported. GOPROXY/GOSUMDB/GOPRIVATE/GO111MODULE
  # are left unset so `go env -w` actually works — environment variables
  # outrank ~/.config/go/env, which made `go env -w GOPRIVATE=...` a silent
  # no-op. CGO_ENABLED is unset too, since forcing it on breaks
  # cross-compilation and static container builds.
  home.sessionVariables = {
    GOPATH = "${config.home.homeDirectory}/go";
    GOBIN = "${config.home.homeDirectory}/go/bin";
    GOLANGCI_LINT_CACHE = "${config.home.homeDirectory}/.cache/golangci-lint";
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/go/bin"
  ];
}
