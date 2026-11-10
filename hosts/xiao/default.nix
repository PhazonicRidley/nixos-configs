# Xiao - MacBook Pro (Darwin aarch64)
{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ../../modules/darwin/base.nix
    inputs.home-manager.darwinModules.home-manager
  ];

  darwinBase = {
    enable = true;
    primaryUser = "phazonic";
    hostPlatform = "aarch64-darwin";

    additionalBrews = [
      "rustup"
      "arm-none-eabi-gdb"
      "llvm@21"
      "clang-format"
      "qemu"
      "lima-additional-guestagents"
      "colima"
      "docker"
      "docker-compose"
    ];

    additionalCasks = [
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

  # Networking
  networking.hostName = "Xiao";

  # Homebrew packages (non-Nix managed apps)

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
