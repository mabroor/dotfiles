{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [
      pkgs.home-manager
    ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  environment.darwinConfig = "$HOME/dotfiles";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix = {
    package = pkgs.nix;
    settings = {
      "extra-experimental-features" = [ "nix-command" "flakes" ];
    };
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs = {
    gnupg.agent.enable = true;
    zsh.enable = true;  # default shell on catalina
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      # Programming fonts
      (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" "Hack" "SourceCodePro" "UbuntuMono" ]; })
      monaspace
      jetbrains-mono
      fira-code
      fira-code-symbols
      source-code-pro
      hack-font
      ubuntu_font_family
      cascadia-code
      
      # System fonts
      atkinson-hyperlegible
      inter
      roboto
      roboto-mono
      open-sans
      liberation_ttf
      
      # Iconic and symbol fonts
      font-awesome
      material-design-icons
      
      # Apple fonts (if available)
      sf-pro
      sf-compact
      sf-mono
      ny-font
    ];
  };

  services = {

  };

  homebrew = {
    enable = true;

    casks = [
      "1password"
      # "bartender"
      # "brave-browser"
      "firefox"
      # "karabiner-elements"
      "obsidian"
      "raycast"
      "rectangle"
      # "soundsource"
      "wezterm"
    ];

    masApps = {
      "Macfamilytree-10"  = 1567970985;
      "Tailscale" = 1475387142;
      "Amphetamine" = 937984704;
    };
  };

  system.defaults = {
    # Dock configuration
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.5;
      orientation = "bottom";
      tilesize = 48;
      largesize = 64;
      magnification = true;
      minimize-to-application = true;
      show-process-indicators = true;
      show-recents = false;
      static-only = false;
      mru-spaces = false;
      expose-animation-duration = 0.1;
      expose-group-apps = true;
      dashboard-in-overlay = false;
      disable-dashboard = true;
      wvous-bl-corner = 1;  # Bottom-left corner: disabled
      wvous-br-corner = 1;  # Bottom-right corner: disabled
      wvous-tl-corner = 2;  # Top-left corner: Mission Control
      wvous-tr-corner = 4;  # Top-right corner: Desktop
    };

    # Finder configuration
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = false;
      CreateDesktop = false;  # Don't show icons on desktop
      FXDefaultSearchScope = "SCcf";  # Search current folder by default
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv";  # List view by default
      QuitMenuItem = true;  # Allow quitting Finder
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;  # Show full path in title
      _FXSortFoldersFirst = true;  # Sort folders first
    };

    # Global system settings
    NSGlobalDomain = {
      # Appearance
      AppleInterfaceStyle = "Dark";  # Dark mode
      AppleInterfaceStyleSwitchesAutomatically = false;
      
      # Keyboard and input
      ApplePressAndHoldEnabled = false;  # Disable press-and-hold for keys
      InitialKeyRepeat = 15;  # Fast initial key repeat
      KeyRepeat = 2;  # Fast key repeat
      AppleKeyboardUIMode = 3;  # Enable full keyboard access
      
      # Mouse and trackpad
      AppleEnableSwipeNavigateWithScrolls = true;
      AppleEnableMouseSwipeNavigateWithScrolls = true;
      
      # Measurements and formats
      AppleMeasurementUnits = "Centimeters";
      AppleMetricUnits = 1;
      AppleTemperatureUnit = "Celsius";
      
      # Interface behavior
      AppleShowAllExtensions = true;
      AppleScrollerPagingBehavior = true;  # Jump to spot clicked on scroll bar
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSDisableAutomaticTermination = true;
      NSDocumentSaveNewDocumentsToCloud = false;
      NSNavPanelExpandedStateForSaveMode = true;  # Expand save panel by default
      NSNavPanelExpandedStateForSaveMode2 = true;
      PMPrintingExpandedStateForPrint = true;  # Expand print panel by default
      PMPrintingExpandedStateForPrint2 = true;
      
      # Window management
      NSWindowResizeTime = 0.001;  # Fast window resize
      NSUseAnimatedFocusRing = false;  # Disable focus ring animation
      
      # Menu and toolbar
      AppleReduceDesktopTinting = true;
      NSToolbarTitleViewRolloverDelay = 0;
    };

    # Login window settings
    loginwindow = {
      DisableConsoleAccess = true;
      GuestEnabled = false;
      PowerOffDisabledWhileLoggedIn = true;
      RestartDisabledWhileLoggedIn = true;
      SHOWFULLNAME = false;  # Show username/password fields instead of user list
      ShutDownDisabledWhileLoggedIn = true;
    };

    # Screenshot settings
    screencapture = {
      disable-shadow = false;
      location = "~/Desktop";
      show-thumbnail = true;
      type = "png";
    };

    # Menu bar settings
    menuExtraClockAnalog = false;

    # Trackpad settings
    trackpad = {
      Clicking = true;  # Tap to click
      TrackpadRightClick = true;  # Two-finger right click
      TrackpadThreeFingerDrag = false;  # Three-finger drag disabled
      ActuationStrength = 1;  # Silent clicking
      FirstClickThreshold = 1;  # Light touch
      SecondClickThreshold = 1;  # Light touch
    };

    # Mouse settings
    ".GlobalPreferences"."com.apple.mouse.scaling" = 2.5;  # Mouse speed
    
    # Custom user defaults for specific applications
    CustomUserPreferences = {
      # Activity Monitor
      "com.apple.ActivityMonitor" = {
        IconType = 5;  # CPU Usage
        SortColumn = "CPUUsage";
        SortDirection = 0;
        ShowCategory = 1;  # All Processes
        UpdatePeriod = 2;  # Update every 2 seconds
      };

      # Archive Utility
      "com.apple.archiveutility" = {
        dearchive-reveal-after = true;
      };

      # Disk Utility
      "com.apple.DiskUtility" = {
        DUDebugMenuEnabled = true;
        advanced-image-options = true;
      };

      # TextEdit
      "com.apple.TextEdit" = {
        RichText = false;  # Plain text mode by default
        PlainTextEncoding = 4;  # UTF-8
        PlainTextEncodingForWrite = 4;  # UTF-8
      };

      # Time Machine
      "com.apple.TimeMachine" = {
        DoNotOfferNewDisksForBackup = true;
      };

      # Safari (if installed)
      "com.apple.Safari" = {
        IncludeInternalDebugMenu = true;
        IncludeDevelopMenu = true;
        WebKitDeveloperExtrasEnabledPreferenceKey = true;
        "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
        ShowFavoritesBar = false;
        ShowSideBar = false;
        HomePage = "about:blank";
        NewTabBehavior = 1;  # New tab opens with homepage
        NewWindowBehavior = 1;  # New window opens with homepage
        TabCreationPolicy = 2;  # New tabs open at end of tab bar
      };

      # Console
      "com.apple.Console" = {
        UseInfoPanel = true;
      };

      # Contacts
      "com.apple.AddressBook" = {
        ABShowDebugMenu = true;
      };

      # App Store
      "com.apple.appstore" = {
        WebKitDeveloperExtras = true;
        ShowDebugMenu = true;
      };

      # iTerm2 (if installed via Homebrew)
      "com.googlecode.iterm2" = {
        PrefsCustomFolder = "~/.config/iterm2";
        LoadPrefsFromCustomFolder = true;
      };
    };

    # System-wide settings
    SoftwareUpdate = {
      AutomaticallyInstallMacOSUpdates = false;
    };

    # Universal Access
    universalaccess = {
      closeViewScrollWheelToggle = true;
      HIDScrollZoomModifierMask = 262144;  # Ctrl key for zoom
      mouseDriverCursorSize = 1.0;
      reduceMotion = false;
      reduceTransparency = false;
    };

    # Spaces and Mission Control
    spaces = {
      spans-displays = false;  # Don't span spaces across displays
    };

    # LaunchServices (file associations)
    LaunchServices = {
      LSQuarantine = false;  # Disable quarantine for downloaded applications
    };

    # Firewall
    alf = {
      allowdownloadsignedenabled = 1;
      allowsignedenabled = 1;
      globalstate = 1;  # Enable firewall
      loggingenabled = 0;
      stealthenabled = 1;  # Enable stealth mode
    };
  };
}