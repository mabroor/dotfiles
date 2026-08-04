# Python development environment
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Python interpreters
    python313        # Python 3.13 (current stable)
    # python312        # Python 3.12 (latest) - Commented out to avoid version conflict
    pypy3           # PyPy for performance-critical applications
    
    # Package managers and virtual environment tools
    python313Packages.pip       # Package installer
    pipx                         # Install Python apps in isolated environments
    poetry                       # Modern dependency management
    python313Packages.virtualenv # Virtual environment creator
    pipenv                       # Higher-level interface to pip and virtualenv
    
    # Development tools
    black                        # Code formatter
    isort                        # Import sorter
    python313Packages.flake8    # Linting
    mypy                         # Static type checking
    pylint                       # Comprehensive linting
    python313Packages.autopep8  # PEP 8 formatter
    ruff                        # Fast Python linter (Rust-based)
    
    # Language servers and IDE tools
    pyright                     # Python language server
    python313Packages.rope      # Refactoring library
    python313Packages.jedi      # Autocompletion library
    
    # Testing frameworks
    python313Packages.pytest   # Testing framework
    python313Packages.pytest-cov # Coverage plugin for pytest
    python313Packages.pytest-xdist # Parallel test execution
    python313Packages.tox       # Test automation
    python313Packages.coverage # Code coverage measurement
    
    # Documentation tools
    python313Packages.sphinx   # Documentation generator
    python313Packages.mkdocs   # Documentation site generator
    
    # Debugging and profiling
    python313Packages.ipdb      # Enhanced debugger with IPython
    # Sampling profiler; its test suite needs ptrace access unavailable in
    # sandboxed/container builds, so skip checks.
    (py-spy.overrideAttrs (_: { doCheck = false; }))
    
    # Popular libraries for data science and web development
    python313Packages.requests # HTTP library
    python313Packages.fastapi  # Modern web framework
    python313Packages.flask    # Lightweight web framework
    python313Packages.django   # Full-featured web framework
    python313Packages.numpy    # Scientific computing
    python313Packages.pandas   # Data manipulation
    python313Packages.matplotlib # Plotting library
    python313Packages.jupyter  # Interactive computing
    python313Packages.ipython  # Enhanced interactive Python
    
    # Database libraries
    python313Packages.psycopg2 # PostgreSQL adapter
    python313Packages.pymongo  # MongoDB driver
    python313Packages.redis    # Redis client
    python313Packages.sqlalchemy # SQL toolkit and ORM
    python313Packages.alembic  # Database migration tool
    
    # Utilities
    python313Packages.click    # Command line interface creation
    python313Packages.rich     # Rich text and beautiful formatting
    python313Packages.typer    # Modern CLI framework
    python313Packages.pydantic # Data validation using Python type hints
    python313Packages.httpx    # HTTP client for Python 3
    python313Packages.aiohttp  # Async HTTP client/server
  ];

  # Shell aliases for Python development
  programs.fish.shellAliases = {
    # Python aliases
    "py" = "python3";
    "py2" = "python2";
    "py3" = "python3";
    "py311" = "python3.11";
    # "py312" = "python3.12";  # Commented out since python312 is not installed
    "ipy" = "ipython";
    
    # pip aliases
    "pip3" = "python3 -m pip";
    "pips" = "pip3 install";
    "pipu" = "pip3 install --upgrade";
    "pipun" = "pip3 uninstall";
    "pipl" = "pip3 list";
    "pipf" = "pip3 freeze";
    "pipr" = "pip3 install -r requirements.txt";
    
    # Virtual environment aliases
    "venv" = "python3 -m venv";
    "activate" = "source venv/bin/activate";
    "deactivate" = "deactivate";
    
    # Poetry aliases
    "po" = "poetry";
    "poi" = "poetry install";
    "poa" = "poetry add";
    "poad" = "poetry add --group dev";
    "por" = "poetry remove";
    "pos" = "poetry shell";
    "pob" = "poetry build";
    "pop" = "poetry publish";
    "pou" = "poetry update";
    "pol" = "poetry lock";
    "pov" = "poetry version";
    "porun" = "poetry run";
    
    # Testing aliases
    "pytest" = "python -m pytest";
    "ptest" = "python -m pytest";  # Renamed from 'test' to avoid fish reserved keyword
    "testv" = "python -m pytest -v";
    "testc" = "python -m pytest --cov";
    "testw" = "python -m pytest --watch";
    
    # Code quality aliases
    "black" = "python -m black";
    "isort" = "python -m isort";
    "flake8" = "python -m flake8";
    "mypy" = "python -m mypy";
    "ruff-check" = "ruff check";
    "ruff-fix" = "ruff check --fix";
    "format-py" = "black . && isort .";
    "lint-py" = "ruff check . && mypy .";
    
    # Django aliases
    "dj" = "python manage.py";
    "djrun" = "python manage.py runserver";
    "djmig" = "python manage.py migrate";
    "djmake" = "python manage.py makemigrations";
    "djshell" = "python manage.py shell";
    "djtest" = "python manage.py test";
    
    # Jupyter aliases
    "jup" = "jupyter";
    "juplab" = "jupyter lab";
    "jupnb" = "jupyter notebook";
  };

  # Environment variables
  home.sessionVariables = {
    # Python configuration
    PYTHONDONTWRITEBYTECODE = "1"; # Don't write .pyc files
    PYTHONUNBUFFERED = "1";        # Unbuffer stdout and stderr
    PIP_REQUIRE_VIRTUALENV = "1";  # Require virtual environment for pip
    
    # Poetry configuration
    POETRY_VENV_IN_PROJECT = "1";  # Create virtual environments in project directory
    POETRY_CACHE_DIR = "${config.home.homeDirectory}/.cache/poetry";
  };

  # Python development scripts
  home.file.".local/bin/py-project-init" = {
    text = ''
      #!/usr/bin/env bash
      # Python project initialization script
      
      set -euo pipefail
      
      PROJECT_NAME="$1"
      PROJECT_TYPE="''${2:-basic}" # basic, web, data, cli
      
      if [ -z "$PROJECT_NAME" ]; then
          echo "Usage: $0 <project-name> [project-type]"
          echo "Project types: basic, web, data, cli"
          exit 1
      fi
      
      echo "🐍 Creating Python project: $PROJECT_NAME ($PROJECT_TYPE)"
      
      mkdir "$PROJECT_NAME"
      cd "$PROJECT_NAME"
      
      # Initialize Poetry project
      poetry init --no-interaction --name "$PROJECT_NAME" --author "Your Name <your.email@example.com>"
      
      # Add dependencies based on project type
      case "$PROJECT_TYPE" in
          "web")
              poetry add fastapi uvicorn sqlalchemy alembic pydantic
              poetry add --group dev pytest pytest-cov httpx
              mkdir -p app tests
              cat > app/main.py << 'EOF'
      from fastapi import FastAPI
      
      app = FastAPI()
      
      @app.get("/")
      def read_root():
          return {"Hello": "World"}
      
      @app.get("/health")
      def health_check():
          return {"status": "healthy"}
      EOF
              ;;
          "data")
              poetry add pandas numpy matplotlib jupyter ipython
              poetry add --group dev pytest pytest-cov
              mkdir -p notebooks data src tests
              cat > src/__init__.py << 'EOF'
      """Data analysis project."""
      __version__ = "0.1.0"
      EOF
              ;;
          "cli")
              poetry add typer rich
              poetry add --group dev pytest pytest-cov
              mkdir -p src tests
              cat > src/main.py << 'EOF'
      import typer
      from rich.console import Console
      
      console = Console()
      app = typer.Typer()
      
      @app.command()
      def hello(name: str = "World"):
          """Say hello to NAME."""
          console.print(f"Hello {name}!")
      
      if __name__ == "__main__":
          app()
      EOF
              ;;
          *)
              poetry add requests
              poetry add --group dev pytest pytest-cov black isort mypy
              mkdir -p src tests
              cat > src/__init__.py << 'EOF'
      """Python project."""
      __version__ = "0.1.0"
      EOF
              ;;
      esac
      
      # Add common dev dependencies
      poetry add --group dev black isort mypy ruff
      
      # Create common files
      cat > .gitignore << 'EOF'
      # Byte-compiled / optimized / DLL files
      __pycache__/
      *.py[cod]
      *$py.class
      
      # Virtual environments
      venv/
      env/
      .env
      .venv
      
      # IDE
      .vscode/
      .idea/
      
      # Testing
      .pytest_cache/
      .coverage
      htmlcov/
      
      # Distribution / packaging
      dist/
      build/
      *.egg-info/
      
      # Jupyter
      .ipynb_checkpoints/
      
      # OS
      .DS_Store
      Thumbs.db
      EOF
      
      cat > pyproject.toml.append << 'EOF'
      
      [tool.black]
      line-length = 88
      target-version = ['py311']
      
      [tool.isort]
      profile = "black"
      
      [tool.mypy]
      python_version = "3.11"
      warn_return_any = true
      warn_unused_configs = true
      
      [tool.pytest.ini_options]
      testpaths = ["tests"]
      addopts = "-v --tb=short"
      
      [tool.ruff]
      line-length = 88
      target-version = "py311"
      EOF
      cat pyproject.toml.append >> pyproject.toml
      rm pyproject.toml.append
      
      # Create test file
      cat > tests/test_main.py << 'EOF'
      """Test main module."""
      
      def test_example():
          """Test example function."""
          assert True
      EOF
      
      # Create README
      cat > README.md << EOF
      # $PROJECT_NAME
      
      A Python $PROJECT_TYPE project.
      
      ## Setup
      
      \`\`\`bash
      poetry install
      poetry shell
      \`\`\`
      
      ## Development
      
      \`\`\`bash
      # Run tests
      pytest
      
      # Format code
      black .
      isort .
      
      # Lint code
      ruff check .
      mypy .
      \`\`\`
      EOF
      
      echo "✅ Python project $PROJECT_NAME created successfully!"
      echo "📁 Navigate to the project: cd $PROJECT_NAME"
      echo "🔧 Install dependencies: poetry install"
      echo "🐚 Activate environment: poetry shell"
    '';
    executable = true;
  };

  # Virtual environment helper script
  home.file.".local/bin/venv-create" = {
    text = ''
      #!/usr/bin/env bash
      # Create and activate a Python virtual environment
      
      set -euo pipefail
      
      VENV_NAME="''${1:-venv}"
      PYTHON_VERSION="''${2:-python3}"
      
      echo "🐍 Creating virtual environment: $VENV_NAME"
      
      $PYTHON_VERSION -m venv "$VENV_NAME"
      source "$VENV_NAME/bin/activate"
      
      pip install --upgrade pip setuptools wheel
      
      echo "✅ Virtual environment $VENV_NAME created and activated"
      echo "📝 To activate later: source $VENV_NAME/bin/activate"
      echo "🚪 To deactivate: deactivate"
    '';
    executable = true;
  };
}