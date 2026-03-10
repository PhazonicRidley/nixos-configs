# Shared NixOS base configuration
# Common settings for all NixOS machines
{ inputs, pkgs, ... }:

{
  # Nix settings
  nix.extraOptions =
    let
      experimentalFeatures = builtins.concatStringsSep " " [
        "flakes"
        "nix-command"
      ];
    in
    ''
      experimental-features = ${experimentalFeatures}
      warn-dirty = false
    '';

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Timezone and locale
  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Networking base
  networking.networkmanager.enable = true;

  # Docker
  virtualisation.docker.enable = true;

  # Shell
  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # SSH
  services.openssh.enable = true;

  # Printing
  services.printing.enable = true;

  # nix-ld for running non-NixOS binaries
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      zstd
    ];
  };

  # Common system packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    tcpdump
    home-manager
  ];

  # Home-manager integration
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    backupFileExtension = "backup";
  };
}
