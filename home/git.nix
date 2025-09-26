{ config, ... }:
{
  programs.git = {
    enable = true;

    # Enable Git Large File Storage support
    lfs.enable = true;

    # User information
    userName = "Mabroor Ahmed";
    userEmail = "mabroor@gmail.com";

    # Modern Git settings with explanations
    extraConfig = {
      # Use 'main' as the default branch name for new repositories
      # This replaces the outdated 'master' terminology
      init = {
        defaultBranch = "main";
      };

      # Core settings
      core = {
        # Use the system's default editor
        editor = "nvim";

        # Enable auto-conversion of line endings (CRLF -> LF on commit, LF -> CRLF on checkout for Windows)
        autocrlf = "input";

        # Protect against whitespace issues
        whitespace = "trailing-space,space-before-tab";

        # Use a global gitignore file
        excludesFile = "${config.xdg.configHome}/git/ignore";

        # Enable file system monitor for better performance in large repos
        fsmonitor = true;

        # Abbreviate SHA-1 hashes to 12 characters (more unique than default 7)
        abbrev = 12;
      };

      # User interface settings
      color = {
        # Enable colored output in terminal
        ui = "auto";

        # Color configuration for different states
        status = {
          added = "green";
          changed = "yellow";
          untracked = "red";
        };

        diff = {
          meta = "yellow bold";
          frag = "magenta bold";
          old = "red";
          new = "green";
        };
      };

      # Pull behavior
      pull = {
        # Only allow fast-forward merges when pulling (safer)
        ff = "only";

        # Rebase local commits on top of pulled commits (cleaner history)
        rebase = true;
      };

      # Push behavior
      push = {
        # Push to the tracking branch (safer than 'matching')
        default = "current";

        # Automatically set up tracking for new branches
        autoSetupRemote = true;

        # Push tags that are reachable from pushed commits
        followTags = true;
      };

      # Fetch behavior
      fetch = {
        # Automatically prune deleted remote branches
        prune = true;

        # Prune deleted remote tags
        pruneTags = true;

        # Fetch in parallel for better performance
        parallel = 3;
      };

      # Merge behavior
      merge = {
        # Use the zdiff3 conflict style (shows original version too)
        conflictStyle = "zdiff3";

        # Include summary of commits being merged
        log = true;

        # Use histogram diff algorithm (better for code)
        tool = "vimdiff";
      };

      # Rebase behavior
      rebase = {
        # Automatically squash fixup! and squash! commits
        autoSquash = true;

        # Automatically stash/unstash uncommitted changes
        autoStash = true;

        # Show abbreviated commit SHAs in todo list
        abbreviateCommands = true;
      };

      # Diff settings
      diff = {
        # Use histogram algorithm (better for code changes)
        algorithm = "histogram";

        # Use patience diff for better results with reordered functions
        indentHeuristic = true;

        # Colorize moved lines in diffs
        colorMoved = "default";

        # Detect renamed files
        renames = true;
      };

      # Commit settings
      commit = {
        # Show diff in commit message editor
        verbose = true;

        # Sign commits with GPG (uncomment if you have GPG set up)
        # gpgSign = true;
      };

      # Stash settings
      stash = {
        # Show patch when listing stashes
        showPatch = true;
      };

      # Status settings
      status = {
        # Show branch and tracking info in short format
        short = true;
        branch = true;

        # Show individual files in untracked directories
        showUntrackedFiles = "all";
      };

      # Branch settings
      branch = {
        # Sort branches by most recently used
        sort = "-committerdate";
      };

      # Blame settings
      blame = {
        # Show dates in ISO format
        date = "iso";

        # Color lines by age
        coloring = "highlightRecent";
      };

      # Log settings
      log = {
        # Use ISO date format in logs
        date = "iso";

        # Follow renames when showing file history
        follow = true;
      };

      # Grep settings
      grep = {
        # Show line numbers in grep output
        lineNumber = true;

        # Extended regex by default
        extendedRegexp = true;
      };

      # Help settings
      help = {
        # Automatically correct typos in commands
        autoCorrect = "prompt";
      };

      # URL shortcuts - use SSH for GitHub
      url = {
        "git@github.com:" = {
          insteadOf = "https://github.com/";
        };
      };

      # Enable rerere (reuse recorded resolution)
      # Remembers how you resolved conflicts and reapplies them
      rerere = {
        enabled = true;
        autoUpdate = true;
      };

      # Credential settings
      credential = {
        # Cache credentials for 15 minutes
        helper = "cache --timeout=900";
      };

      # GitHub specific settings
      github = {
        user = "mabroor";
      };

      # Hub CLI settings
      hub = {
        protocol = "ssh";
      };

      # Filter for Git LFS
      filter = {
        lfs = {
          clean = "git-lfs clean -- %f";
          smudge = "git-lfs smudge -- %f";
          process = "git-lfs filter-process";
          required = true;
        };
      };
    };

    # Git aliases for common operations
    aliases = {
      # Status and info
      st = "status --short --branch";
      s = "status --short --branch";

      # Staging
      aa = "add --all";
      au = "add --update";
      ap = "add --patch";

      # Committing
      ci = "commit -v";
      amend = "commit -v --amend";
      fixup = "commit --fixup";

      # Branching
      co = "checkout";
      cob = "checkout -b";
      b = "branch";
      bd = "branch -d";
      bD = "branch -D";

      # Remote operations
      fa = "fetch --all";
      fap = "fetch --all --prune";

      # Merging and rebasing
      ff = "merge --ff-only";
      ms = "merge --no-commit --log --no-ff";
      mc = "merge --log --no-ff";
      rc = "rebase --continue";
      rs = "rebase --skip";
      rba = "rebase --abort";  # Changed from 'ra' to avoid conflict
      ri = "rebase --interactive";

      # Diffing
      di = "diff";
      dc = "diff --cached";
      ds = "diff --staged";
      dh1 = "diff HEAD~1";

      # Logging
      l = "log --graph --pretty=format:'%C(auto,yellow)%h%C(auto,reset) %C(auto,green)(%ar)%C(auto,reset) %C(auto,bold blue)<%an>%C(auto,reset) %C(auto,red)%d%C(auto,reset) %s'";
      la = "log --graph --all --pretty=format:'%C(auto,yellow)%h%C(auto,reset) %C(auto,green)(%ar)%C(auto,reset) %C(auto,bold blue)<%an>%C(auto,reset) %C(auto,red)%d%C(auto,reset) %s'";
      r = "log --graph --pretty=format:'%C(auto,yellow)%h%C(auto,reset) %C(auto,green)(%ar)%C(auto,reset) %C(auto,bold blue)<%an>%C(auto,reset) %C(auto,red)%d%C(auto,reset) %s' -20";
      ra = "log --graph --all --pretty=format:'%C(auto,yellow)%h%C(auto,reset) %C(auto,green)(%ar)%C(auto,reset) %C(auto,bold blue)<%an>%C(auto,reset) %C(auto,red)%d%C(auto,reset) %s' -20";  # Recent All - shows recent commits from all branches

      # Show current commit
      h = "log --pretty=format:'%C(auto,yellow)%h%C(auto,reset) %C(auto,green)(%ar)%C(auto,reset) %C(auto,bold blue)<%an>%C(auto,reset) %C(auto,red)%d%C(auto,reset) %s' -1";
      head = "log --pretty=format:'%C(auto,yellow)%h%C(auto,reset) %C(auto,green)(%ar)%C(auto,reset) %C(auto,bold blue)<%an>%C(auto,reset) %C(auto,red)%d%C(auto,reset) %s' -1";
      hp = "show --patch --pretty=format:'%C(auto,yellow)%h%C(auto,reset) %C(auto,green)(%ar)%C(auto,reset) %C(auto,bold blue)<%an>%C(auto,reset) %C(auto,red)%d%C(auto,reset) %s'";

      # Working with remotes
      pushf = "push --force-with-lease";
      pl = "pull";

      # Stashing
      ss = "stash save";
      sp = "stash pop";
      sl = "stash list";

      # Finding things
      find = "!git ls-files | grep -i";
      grep = "grep -In";

      # Maintenance
      cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master\\|develop' | xargs -n 1 git branch -d";

      # Undo operations
      undo = "reset --soft HEAD~1";
      unstage = "reset HEAD --";

      # Ignore/acknowledge files
      ignored = "!git ls-files -v | grep '^[[:lower:]]' | cut -c 3-";
      ignore = "update-index --assume-unchanged";
      acknowledge = "update-index --no-assume-unchanged";

      # Show files in last commit
      last = "log -1 HEAD --stat";

      # List contributors
      contributors = "shortlog --summary --numbered";

      # Show branches sorted by last commit
      recent = "for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:yellow)%(refname:short)%(color:reset) - %(color:red)%(objectname:short)%(color:reset) - %(contents:subject) - %(authorname) (%(color:green)%(committerdate:relative)%(color:reset))'";
    };

    # Git ignore patterns (global)
    ignores = [
      # macOS
      ".DS_Store"
      "._*"

      # Windows
      "Thumbs.db"
      "Desktop.ini"

      # Editors
      "*~"
      "*.swp"
      "*.swo"
      ".idea/"
      ".vscode/"
      "*.sublime-*"

      # Dependencies
      "node_modules/"
      "vendor/"

      # Build outputs
      "dist/"
      "build/"
      "*.log"

      # Environment files
      ".env"
      ".env.local"

      # Temporary files
      "*.tmp"
      "*.temp"

      # Direnv
      ".direnv/"
      ".envrc"
    ];
  };
}