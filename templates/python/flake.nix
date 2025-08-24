{
  description = "Python project template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        
        # Python version - adjust as needed
        python = pkgs.python311;
        
        # Python packages for development
        pythonPackages = python.pkgs;
        
        # Development dependencies
        devDeps = with pythonPackages; [
          pip
          setuptools
          wheel
          flake8
          pytest
          pytest-cov
          pytest-xdist
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            python
          ] ++ devDeps ++ (with pkgs; [
            # Development tools
            poetry        # Package manager
            black         # Code formatter
            isort         # Import sorter
            mypy          # Type checker
            ruff          # Fast Python linter
            pyright       # Python language server
            
            # System dependencies that Python packages might need
            pkg-config
            zlib
            openssl
            libffi
            
            # Database libraries (if needed)
            postgresql
            sqlite
            
            # Optional: useful utilities
            jq
            curl
          ]) ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
            pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
          ];

          shellHook = ''
            echo "🐍 Python development environment loaded!"
            echo "🐍 Python version: $(python --version)"
            echo "📦 pip version: $(pip --version)"
            echo "📝 Poetry version: $(poetry --version)"
            echo ""
            echo "Development workflow:"
            echo "  python -m venv venv     # Create virtual environment"
            echo "  source venv/bin/activate # Activate venv"
            echo "  pip install -r requirements.txt # Install deps"
            echo ""
            echo "With Poetry:"
            echo "  poetry install          # Install dependencies"
            echo "  poetry shell            # Activate environment"
            echo "  poetry add <package>    # Add dependency"
            echo "  poetry run python main.py # Run with poetry"
            echo ""
            echo "Code quality:"
            echo "  black .                 # Format code"
            echo "  isort .                 # Sort imports" 
            echo "  ruff check .            # Lint code"
            echo "  mypy .                  # Type checking"
            echo "  pytest                  # Run tests"
          '';

          # Environment variables
          PYTHONDONTWRITEBYTECODE = "1";
          PYTHONUNBUFFERED = "1";
          PIP_REQUIRE_VIRTUALENV = "0";  # Allow pip in nix shell
          PYTHONPATH = "$PWD/src:$PYTHONPATH";
        };

        # Package a Python application
        packages.default = pythonPackages.buildPythonApplication {
          pname = "python-project";
          version = "0.1.0";
          
          src = ./.;
          
          pyproject = true;
          
          build-system = with pythonPackages; [
            poetry-core
          ];
          
          # Dependencies - adjust as needed
          propagatedBuildInputs = with pythonPackages; [
            requests
            click
            # Add your dependencies here
          ];
          
          # Development dependencies for testing
          nativeCheckInputs = with pythonPackages; [
            pytest
            pytest-cov
          ];
          
          # Enable tests
          doCheck = true;
          
          # Test command
          checkPhase = ''
            pytest tests/
          '';
          
          meta = with pkgs.lib; {
            description = "A Python project";
            homepage = "https://github.com/user/project";
            license = licenses.mit;
            maintainers = [ maintainers.user ];
          };
        };

        # Alternative: Package with Poetry
        # To use poetry2nix, add it as an input:
        #   inputs.poetry2nix.url = "github:nix-community/poetry2nix";
        # Then uncomment and use:
        # packages.poetry = pkgs.poetry2nix.mkPoetryApplication {
        #   projectDir = ./.;
        #   
        #   # Override dependencies if needed
        #   overrides = pkgs.poetry2nix.overrides.withDefaults (final: prev: {
        #     # Example override:
        #     # some-package = prev.some-package.overridePythonAttrs (old: {
        #     #   buildInputs = old.buildInputs ++ [ final.some-build-dep ];
        #     # });
        #   });
        #   
        #   meta = with pkgs.lib; {
        #     description = "A Python project built with Poetry";
        #     license = licenses.mit;
        #   };
        # };

        # Python library package
        packages.lib = pythonPackages.buildPythonPackage {
          pname = "python-library";
          version = "0.1.0";
          
          src = ./.;
          
          pyproject = true;
          
          build-system = with pythonPackages; [
            setuptools
            wheel
          ];
          
          propagatedBuildInputs = with pythonPackages; [
            # Library dependencies
          ];
          
          nativeCheckInputs = with pythonPackages; [
            pytest
            pytest-cov
          ];
          
          doCheck = true;
          
          pythonImportsCheck = [ "mypackage" ]; # Replace with actual package name
          
          meta = with pkgs.lib; {
            description = "A Python library";
            license = licenses.mit;
          };
        };
      });
}