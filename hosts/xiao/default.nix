# Xiao - MacBook Pro (Darwin aarch64)
{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ../../modules/common/nix-settings.nix
    ../../modules/darwin/homebrew.nix
    inputs.home-manager.darwinModules.home-manager
  ];

  # Platform
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # System
  networking.hostName = "Xiao";
  system.primaryUser = "phazonic";
  system.stateVersion = 6;

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  # Homebrew packages (non-Nix managed apps)
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";

    brews = [
      "rustup"
      "usbutils"
      "arm-none-eabi-gdb"
      "llvm@21"
      "clang-format"
      "iproute2mac"
      "colima"
      "docker"
      "docker-compose"
      "qemu"
      "lima-additional-guestagents"
    ];

    casks = [
      "scroll-reverser"
      "rectangle"
      "saleae-logic"
      "signal"
      "obsidian"
      "utm"
      "google-chrome"
      "telegram-desktop"
      "discord"
      "steam"
      "webex"
      "firefox"
    ];
  };

  # Launch agents (start at login)
  launchd.user.agents = {
    scroll-reverser = {
      command = "/Applications/Scroll Reverser.app/Contents/MacOS/Scroll Reverser";
      serviceConfig = {
        RunAtLoad = true;
        KeepAlive = false;
      };
    };
    rectangle = {
      command = "/Applications/Rectangle.app/Contents/MacOS/Rectangle";
      serviceConfig = {
        RunAtLoad = true;
        KeepAlive = false;
      };
    };
  };

  # User
  users.users.phazonic = {
    home = "/Users/phazonic";
  };

  # Home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.phazonic = import ./home.nix;
    extraSpecialArgs = {
      inherit inputs;
      username = "phazonic";
      isGlobalPkgs = true;
    };
    sharedModules = [
      inputs.mac-app-util.homeManagerModules.default
    ];
  };
}
