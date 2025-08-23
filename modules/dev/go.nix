# Go development environment
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Go compiler and tools
    go_1_21          # Go 1.21 (latest stable)
    
    # Development tools
    gopls            # Go language server
    golangci-lint    # Fast Go linters runner
    gofumpt          # Stricter gofmt
    goimports        # Tool to fix Go imports
    gomodifytags     # Go tool to modify struct field tags
    gotests          # Generate tests for Go code
    golines          # Go formatter that shortens long lines
    
    # Debugging and profiling
    delve            # Go debugger
    go-tools         # Additional Go tools (staticcheck, etc.)
    
    # Code generation
    stringer         # Generate String method for enums
    protobuf         # Protocol Buffers compiler
    protoc-gen-go    # Go plugin for protobuf compiler
    protoc-gen-go-grpc # Go gRPC plugin for protobuf compiler
    
    # Database tools
    migrate          # Database migrations
    sqlc             # Generate Go from SQL
    
    # Web development
    air              # Live reload for Go apps
    
    # Build and deployment
    goreleaser       # Release Go projects
    buildah          # Container builder
    
    # Testing and benchmarking
    gotestsum        # Pretty test output
    
    # Utilities
    gox              # Cross-compile Go projects
    govulncheck      # Security vulnerability scanner
  ];

  # Shell aliases for Go development
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
    
    # Formatting and linting
    "gofmt" = "gofmt -s -w";
    "goimp" = "goimports -w";
    "golint" = "golangci-lint run";
    "golintf" = "golangci-lint run --fix";
    "gofumpt" = "gofumpt -w";
    
    # Debugging
    "dlv" = "dlv debug";
    "dlvt" = "dlv test";
    
    # Utilities
    "golist" = "go list -m all";
    "gowork" = "go work sync";
    "govuln" = "govulncheck";
    
    # Air (live reload)
    "gowatch" = "air";
  };

  # Environment variables
  home.sessionVariables = {
    # Go configuration
    GOPATH = "${config.home.homeDirectory}/go";
    GOBIN = "${config.home.homeDirectory}/go/bin";
    GO111MODULE = "on";
    GOPROXY = "https://proxy.golang.org,direct";
    GOSUMDB = "sum.golang.org";
    GOPRIVATE = ""; # Set this to your private module prefixes if needed
    
    # Go build flags
    CGO_ENABLED = "1";
    
    # Go tools configuration
    GOLANGCI_LINT_CACHE = "${config.home.homeDirectory}/.cache/golangci-lint";
  };

  # Add Go bin to PATH
  home.sessionPath = [
    "${config.home.homeDirectory}/go/bin"
  ];

  # Go project initialization script
  home.file.".local/bin/go-project-init" = {
    text = ''
      #!/usr/bin/env bash
      # Go project initialization script
      
      set -euo pipefail
      
      PROJECT_NAME="$1"
      PROJECT_TYPE="''${2:-basic}" # basic, web, cli, library
      MODULE_PATH="''${3:-github.com/username/$PROJECT_NAME}"
      
      if [ -z "$PROJECT_NAME" ]; then
          echo "Usage: $0 <project-name> [project-type] [module-path]"
          echo "Project types: basic, web, cli, library"
          exit 1
      fi
      
      echo "🚀 Creating Go project: $PROJECT_NAME ($PROJECT_TYPE)"
      
      mkdir "$PROJECT_NAME"
      cd "$PROJECT_NAME"
      
      # Initialize Go module
      go mod init "$MODULE_PATH"
      
      # Create directory structure based on project type
      case "$PROJECT_TYPE" in
          "web")
              mkdir -p cmd/server internal/handler internal/service internal/repository pkg
              cat > cmd/server/main.go << 'EOF'
      package main
      
      import (
          "log"
          "net/http"
          "os"
      
          "github.com/gorilla/mux"
      )
      
      func main() {
          port := os.Getenv("PORT")
          if port == "" {
              port = "8080"
          }
      
          r := mux.NewRouter()
          r.HandleFunc("/health", healthHandler).Methods("GET")
          r.HandleFunc("/", homeHandler).Methods("GET")
      
          log.Printf("Server starting on port %s", port)
          log.Fatal(http.ListenAndServe(":"+port, r))
      }
      
      func healthHandler(w http.ResponseWriter, r *http.Request) {
          w.Header().Set("Content-Type", "application/json")
          w.WriteHeader(http.StatusOK)
          w.Write([]byte(`{"status":"healthy"}`))
      }
      
      func homeHandler(w http.ResponseWriter, r *http.Request) {
          w.Header().Set("Content-Type", "text/plain")
          w.WriteHeader(http.StatusOK)
          w.Write([]byte("Hello, World!"))
      }
      EOF
              go get github.com/gorilla/mux
              ;;
          "cli")
              mkdir -p cmd pkg
              cat > cmd/main.go << 'EOF'
      package main
      
      import (
          "flag"
          "fmt"
          "os"
      )
      
      func main() {
          var name = flag.String("name", "World", "Name to greet")
          flag.Parse()
      
          if flag.NArg() > 0 {
              fmt.Fprintf(os.Stderr, "Unexpected arguments: %v\n", flag.Args())
              os.Exit(1)
          }
      
          fmt.Printf("Hello, %s!\n", *name)
      }
      EOF
              ;;
          "library")
              mkdir -p pkg
              cat > pkg/lib.go << EOF
      // Package $PROJECT_NAME provides...
      package $PROJECT_NAME
      
      // Version returns the version of the library.
      func Version() string {
          return "0.1.0"
      }
      
      // Hello returns a greeting message.
      func Hello(name string) string {
          if name == "" {
              name = "World"
          }
          return "Hello, " + name + "!"
      }
      EOF
              cat > pkg/lib_test.go << EOF
      package $PROJECT_NAME
      
      import "testing"
      
      func TestHello(t *testing.T) {
          tests := []struct {
              name     string
              input    string
              expected string
          }{
              {"empty name", "", "Hello, World!"},
              {"with name", "Go", "Hello, Go!"},
          }
      
          for _, tt := range tests {
              t.Run(tt.name, func(t *testing.T) {
                  result := Hello(tt.input)
                  if result != tt.expected {
                      t.Errorf("Hello(%q) = %q, want %q", tt.input, result, tt.expected)
                  }
              })
          }
      }
      
      func BenchmarkHello(b *testing.B) {
          for i := 0; i < b.N; i++ {
              Hello("Benchmark")
          }
      }
      EOF
              ;;
          *)
              cat > main.go << 'EOF'
      package main
      
      import "fmt"
      
      func main() {
          fmt.Println("Hello, World!")
      }
      EOF
              ;;
      esac
      
      # Create common files
      cat > .gitignore << 'EOF'
      # Binaries
      *.exe
      *.exe~
      *.dll
      *.so
      *.dylib
      
      # Test binary, built with `go test -c`
      *.test
      
      # Output of the go coverage tool
      *.out
      
      # Go workspace file
      go.work
      go.work.sum
      
      # Dependency directories
      vendor/
      
      # IDE
      .vscode/
      .idea/
      
      # OS
      .DS_Store
      Thumbs.db
      
      # Environment variables
      .env
      .env.local
      EOF
      
      cat > Makefile << 'EOF'
      .PHONY: build test clean run fmt lint
      
      # Build the application
      build:
      	go build -o bin/app ./...
      
      # Run tests
      test:
      	go test -v ./...
      
      # Run tests with coverage
      test-cover:
      	go test -v -cover ./...
      
      # Clean build artifacts
      clean:
      	go clean
      	rm -rf bin/
      
      # Run the application
      run:
      	go run ./...
      
      # Format code
      fmt:
      	gofmt -s -w .
      	goimports -w .
      
      # Lint code
      lint:
      	golangci-lint run
      
      # Tidy dependencies
      tidy:
      	go mod tidy
      
      # Download dependencies
      deps:
      	go mod download
      
      # Verify dependencies
      verify:
      	go mod verify
      
      # Check for vulnerabilities
      vuln:
      	govulncheck ./...
      EOF
      
      # Create README
      cat > README.md << EOF
      # $PROJECT_NAME
      
      A Go $PROJECT_TYPE project.
      
      ## Setup
      
      \`\`\`bash
      go mod download
      \`\`\`
      
      ## Development
      
      \`\`\`bash
      # Run the application
      make run
      
      # Build the application
      make build
      
      # Run tests
      make test
      
      # Format code
      make fmt
      
      # Lint code
      make lint
      
      # Check for vulnerabilities
      make vuln
      \`\`\`
      
      ## Project Structure
      
      - \`cmd/\` - Main applications
      - \`pkg/\` - Library code that can be used by external applications
      - \`internal/\` - Private application and library code
      EOF
      
      # Initialize git repository
      git init
      git add .
      git commit -m "Initial commit"
      
      echo "✅ Go project $PROJECT_NAME created successfully!"
      echo "📁 Navigate to the project: cd $PROJECT_NAME"
      echo "🔧 Download dependencies: make deps"
      echo "🚀 Run the application: make run"
    '';
    executable = true;
  };

  # Air configuration for live reloading
  home.file.".air.toml" = {
    text = ''
      root = "."
      testdata_dir = "testdata"
      tmp_dir = "tmp"
      
      [build]
        args_bin = []
        bin = "./tmp/main"
        cmd = "go build -o ./tmp/main ."
        delay = 0
        exclude_dir = ["assets", "tmp", "vendor", "testdata"]
        exclude_file = []
        exclude_regex = ["_test.go"]
        exclude_unchanged = false
        follow_symlink = false
        full_bin = ""
        include_dir = []
        include_ext = ["go", "tpl", "tmpl", "html"]
        include_file = []
        kill_delay = "0s"
        log = "build-errors.log"
        poll = false
        poll_interval = 0
        rerun = false
        rerun_delay = 500
        send_interrupt = false
        stop_on_root = false
      
      [color]
        app = ""
        build = "yellow"
        main = "magenta"
        runner = "green"
        watcher = "cyan"
      
      [log]
        main_only = false
        time = false
      
      [misc]
        clean_on_exit = false
      
      [screen]
        clear_on_rebuild = false
        keep_scroll = true
    '';
  };
}