# Python development environment.
#
# Packages live in the flake's `python` devShell (or `python-data` for the
# numpy/pandas/jupyter stack):
#   nix develop github:mabroor/dotfiles#python
{ config, ... }:

{
  programs.fish.shellAliases = {
    "py" = "python3";
    "py3" = "python3";
    "ipy" = "ipython";

    # pip aliases call the pip executable directly. `python3 -m pip` fails on
    # this setup because nixpkgs ships pip as a wrapped application rather than
    # a module importable from the ambient interpreter.
    "pips" = "pip install";
    "pipu" = "pip install --upgrade";
    "pipun" = "pip uninstall";
    "pipl" = "pip list";
    "pipf" = "pip freeze";
    "pipr" = "pip install -r requirements.txt";

    # Virtual environments. fish needs the .fish activation script; sourcing
    # the bash one is a syntax error. `deactivate` is defined by the activate
    # script itself, so it is not aliased here.
    "venv" = "python3 -m venv";
    "activate" = "source venv/bin/activate.fish";

    # Poetry
    "po" = "poetry";
    "poi" = "poetry install";
    "poa" = "poetry add";
    "poad" = "poetry add --group dev";
    "por" = "poetry remove";
    "pob" = "poetry build";
    "pop" = "poetry publish";
    "pou" = "poetry update";
    "pol" = "poetry lock";
    "pov" = "poetry version";
    "porun" = "poetry run";

    # Testing. These invoke the real binaries rather than `python -m <tool>`,
    # which raised ModuleNotFoundError for the same reason as pip above.
    "ptest" = "pytest";
    "testv" = "pytest -v";
    "testc" = "pytest --cov";

    # Code quality
    "ruff-check" = "ruff check";
    "ruff-fix" = "ruff check --fix";
    "format-py" = "black . && isort .";
    "lint-py" = "ruff check . && mypy .";

    # Django
    "dj" = "python manage.py";
    "djrun" = "python manage.py runserver";
    "djmig" = "python manage.py migrate";
    "djmake" = "python manage.py makemigrations";
    "djshell" = "python manage.py shell";
    "djtest" = "python manage.py test";

    # Jupyter
    "jup" = "jupyter";
    "juplab" = "jupyter lab";
    "jupnb" = "jupyter notebook";
  };

  # PYTHONDONTWRITEBYTECODE is deliberately unset: disabling the bytecode cache
  # makes every interpreter start recompile all imported modules, which is a
  # per-run cost on large test suites and Django management commands.
  home.sessionVariables = {
    PYTHONUNBUFFERED = "1";
    POETRY_CACHE_DIR = "${config.home.homeDirectory}/.cache/poetry";
  };
}
