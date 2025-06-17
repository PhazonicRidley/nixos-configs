inputs@{ self, pkgs, config, lib, ...}: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = "nix-command flakes";
  networking.hostName = "Xiao";
  system.primaryUser = "phazonic";

  environment.systemPackages =
  [ pkgs.vim
    pkgs.neovim
    pkgs.fastfetch
    pkgs.bat
    pkgs.starship
    pkgs.iterm2
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Barebones zsh and starship config for consistancy with user
  programs.zsh = {
    enable = true;
    promptInit = ''
      eval "$(starship init zsh)"
    '';
  };

  programs.tmux = {
    enable = true;
    enableMouse = true;
  };

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.defaults = {
    CustomUserPreferences = {
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          # Disable 'Cmd + Space' for Spotlight Search
          "64" = {
            enabled = false;
          };
        };
      };
    };
  };

  system.stateVersion = 6;
  system.activationScripts.applications.text = let
  env = pkgs.buildEnv {
  name = "system-applications";
  paths = config.environment.systemPackages;
  pathsToLink = "/Applications";
  };
  in
  pkgs.lib.mkForce ''
  # Set up applications.
  echo "setting up /Applications..." >&2
  rm -rf /Applications/Nix\ Apps
  mkdir -p /Applications/Nix\ Apps
  find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
  while read -r src; do
    app_name=$(basename "$src")
    echo "copying $src" >&2
    ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
  done
  '';

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Homebrew config (TODO: potentially move to its own module to be used across macs)
  homebrew = {
    enable = true;
    taps = [
      "homebrew/cask"  # Explicitly keep this tap
    ];

    brews = [
      "rustup" # this is a temp thing until i find a rust conf i like
      "llvm@17"
    ];

    casks = [
      "google-chrome"
      "raycast"
      "telegram-desktop"
      "discord"
      "steam"
      "webex"
    ];

    onActivation.cleanup = "zap";
  };

  users.users.phazonic = {
    home = "/Users/phazonic";
  };
}
