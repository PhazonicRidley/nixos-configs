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
      "kicad"
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
  };

  # User. programs.zsh.enable puts this zsh on PATH and in /etc/shells.
  programs.zsh.enable = true;
  users.users.phazonic = {
    home = "/Users/phazonic";
    shell = pkgs.zsh;
  };

  nix.linux-builder = {
    enable = true;
    config.virtualisation = {
      cores = 6;
      darwin-builder = {
        memorySize = 8192;
        diskSize = 40960;
      };
    };
  };

  # Prebuilt RPi kernels/firmware for JamesPi (and the installer images).
  # Set here rather than via flake nixConfig: we're not a trusted user, so
  # the daemon ignores substituters passed from the flake or command line.
  nix.settings = {
    extra-substituters = [ "https://nixos-raspberrypi.cachix.org" ];
    extra-trusted-public-keys = [
      "nixos-raspberrypi.cachix.org-1:4iMO9LXa8BqhU+Rpg6LQKiGa2lsNh/j2oiYLNOQ5sPI="
    ];
  };

  # Home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.phazonic = import ./home.nix;
    extraSpecialArgs = {
      inherit inputs;
      username = "phazonic";
    };
    sharedModules = [
      inputs.mac-app-util.homeManagerModules.default
    ];
  };
}
