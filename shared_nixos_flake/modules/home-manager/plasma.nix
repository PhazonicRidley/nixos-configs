{
  ...
}:

{
  programs.plasma = {
    enable = true;

    # Shortcuts - correct structure
    shortcuts = {
      ksmserver = {
        "Lock Session" = [
          "Screensaver"
          "Alt+L"
        ];
      };

      kwin = {
        "Expose" = "Meta+,";
        "Switch Window Down" = "Meta+J";
        "Switch Window Left" = "Meta+H";
        "Switch Window Right" = "Meta+L";
        "Switch Window Up" = "Meta+K";
        "Switch to Desktop 1" = "Ctrl+F1";
        "Switch to Desktop 2" = "Ctrl+F2";
      };

      plasmashell = {
        "activate application launcher" = [
          "Meta"
          "Alt+F1"
        ];
      };

      # For application shortcuts
      "services/org.kde.spectacle.desktop"."RectangularRegionScreenShot" = "Alt+Shift+S";
    };

    workspace = {
      iconTheme = "Papirus-Dark";
    };

    # Low-level config file settings - correct structure
    configFile = {
      # File name as key, then groups and settings
      "kwinrc"."Desktops"."Number" = {
        value = 1;
        # Optional: immutable = true; # Prevents changes through GUI
      };

      "kwinrc"."Tiling".padding = 4;

      "kwinrc"."Xwayland".Scale = 1;

      "baloofilerc"."Basic Settings"."Indexing-Enabled" = false;

      "dolphinrc".General = {
        AutoExpandFolders = true;
        RememberOpenedTabs = false;
        ShowFullPath = true;
      };

      "plasmarc"."Theme".name = "breeze-dark";

      "ksmserverrc".General.loginMode = "emptySession";

      "kwalletrc".Wallet."First Use" = false;
    };

    # Data files (in $XDG_DATA_HOME)
    dataFile = {
      # Similar structure to configFile
    };

    # For custom commands/hotkeys (different from shortcuts)
    hotkeys.commands."konsole" = {
      name = "Launch Konsole";
      key = "Ctrl+Alt+T";
      command = "konsole";
    };
  };
}
