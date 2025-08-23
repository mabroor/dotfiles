{
  description = "JavaScript/Node.js project template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        
        # Node.js version - adjust as needed
        nodejs = pkgs.nodejs_20;
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Node.js and package managers
            nodejs
            nodePackages.npm
            nodePackages.yarn
            nodePackages.pnpm
            bun
            
            # Development tools
            nodePackages.typescript
            nodePackages.typescript-language-server
            nodePackages.prettier
            nodePackages.eslint
            nodePackages.vscode-langservers-extracted
            
            # Build tools
            nodePackages.webpack-cli
            nodePackages.vite
            
            # Testing
            nodePackages.jest
            
            # Utilities
            nodePackages.nodemon
            nodePackages.concurrently
            nodePackages.npm-check-updates
            
            # System dependencies
            python3  # For native modules
            pkg-config
          ] ++ lib.optionals stdenv.isDarwin [
            darwin.apple_sdk.frameworks.CoreServices
          ] ++ lib.optionals stdenv.isLinux [
            glibc
          ];

          shellHook = ''
            echo "🚀 JavaScript/Node.js development environment loaded!"
            echo "📦 Node.js version: $(node --version)"
            echo "📦 npm version: $(npm --version)"
            echo "🧶 yarn version: $(yarn --version)"
            echo "⚡ pnpm version: $(pnpm --version)"
            echo "🥟 bun version: $(bun --version)"
            echo ""
            echo "Available package managers:"
            echo "  npm install     # Install with npm"
            echo "  yarn install    # Install with yarn"
            echo "  pnpm install    # Install with pnpm"
            echo "  bun install     # Install with bun"
            echo ""
            echo "Development tools:"
            echo "  npm run dev     # Start development server"
            echo "  npm test        # Run tests"
            echo "  npm run build   # Build for production"
            echo "  npm run lint    # Run linter"
            echo "  ncu             # Check for updates"
          '';

          # Environment variables
          NODE_ENV = "development";
          NPM_CONFIG_PREFIX = "$HOME/.npm-global";
          PNPM_HOME = "$HOME/.local/share/pnpm";
          
          # Add npm global packages to PATH
          shellHook = ''
            export PATH="$HOME/.npm-global/bin:$HOME/.local/share/pnpm:$PATH"
          '';
        };

        # Package a Node.js application
        packages.default = pkgs.buildNpmPackage {
          pname = "javascript-project";
          version = "1.0.0";
          
          src = ./.;
          
          npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Update this
          
          buildPhase = ''
            npm run build
          '';
          
          installPhase = ''
            mkdir -p $out/bin
            cp -r dist/* $out/
            # Add executable script if needed
          '';
          
          meta = with pkgs.lib; {
            description = "A JavaScript project";
            homepage = "https://github.com/user/project";
            license = licenses.mit;
            maintainers = [ maintainers.user ];
          };
        };

        # Alternative: Package with yarn
        packages.yarn = pkgs.mkYarnPackage {
          pname = "javascript-project-yarn";
          version = "1.0.0";
          
          src = ./.;
          
          buildPhase = ''
            yarn build
          '';
          
          distPhase = ''
            cp -r deps/project/dist $out/
          '';
          
          meta = with pkgs.lib; {
            description = "A JavaScript project built with Yarn";
            license = licenses.mit;
          };
        };
      });
}