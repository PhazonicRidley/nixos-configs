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
  networking.hostName = "WorkComputah";
  system.primaryUser = "madeline.schneider";
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
      "usbutils"
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
      "obsidian"
      "utm"
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
  users.users."madeline.schneider" = {
    home = "/Users/madeline.schneider";
  };

  # Home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."madeline.schneider" = import ./home.nix;
    extraSpecialArgs = {
      inherit inputs;
      username = "madeline.schneider";
    };
    sharedModules = [
      inputs.mac-app-util.homeManagerModules.default
    ];
  };
}
