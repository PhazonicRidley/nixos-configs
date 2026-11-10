{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.darwinBase;
in
{
  imports = [
    ./homebrew.nix
    ../common/nix-settings.nix
  ];

  options.darwinBase = {
    enable = lib.mkEnableOption "darwinBase";
    primaryUser = lib.mkOption {
      type = lib.types.str;
      default = "phazonic";
    };
    hostPlatform = lib.mkOption {
      type = lib.types.str;
      default = "aarch64-darwin";
    };

    additionalBrews = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    additionalCasks = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {

    # Maybe move to common/nix-settings.nix
    nixpkgs = {
      inherit (cfg) hostPlatform;
      config.allowUnfree = true;
    };

    # System
    system = {
      inherit (cfg) primaryUser;
      stateVersion = 6;
    };

    # Fonts
    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
    ];

    # Homebrew packages
    homebrew = {
      brews = [
        "usbutils"
        "iproute2mac"
      ]
      ++ cfg.additionalBrews;
      casks = [
        "scroll-reverser"
        "rectangle"
      ]
      ++ cfg.additionalCasks;
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
  };
}
