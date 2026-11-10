# JamesPi, raspberrypi at dad's house
{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/avahi.nix
    ../../modules/common/secrets.nix
    inputs.sops-nix.nixosModules.sops
  ];

  # Bootloader is nixos-raspberrypi's (uboot + extlinux, set by
  # raspberry-pi-3.base). Turn off what base.nix enables for EFI machines.
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  # The kernel is built against nixos-raspberrypi's pinned 26.05 nixpkgs
  # (cached), while the system is unstable. Unstable reads these defaults from
  # attrs (kernel.buildDTBs, kernel.target) that the 26.05 kernel lacks, so set
  # them directly. Only valid with the default "uboot" bootloader.
  hardware.deviceTree.enable = true;
  system.boot.loader.kernelFile = "Image";

  system.nixos.tags =
    let
      cfg = config.boot.loader.raspberry-pi;
    in
    [
      "raspberry-pi-${cfg.variant}"
      cfg.bootloader
      config.boot.kernelPackages.kernel.version
    ];

  # User configuration
  users.users.phazonic = {
    isNormalUser = true;
    description = "Madeline Schneider";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINgFpBjoDEVwG25M8hHf10tzJXKRfnKLC/2o3nqr9d61 phazonic@Xiao"
    ];
  };

  # SSH with password auth enabled
  services.openssh.settings = {
    PasswordAuthentication = true;
    PermitRootLogin = "yes";
  };

  # Additional system packages
  environment.systemPackages = with pkgs; [
    fastfetch
    docker-compose
    htop
  ];

  networking = {
    networkmanager = {
      enable = true;
      insertNameservers = [
        "192.168.20.2"
        "1.1.1.1"
        "8.8.8.8"
      ];
    };

    hostName = "JamesPi";
    firewall = {
      allowedTCPPorts = [
        53
        22
      ];
      allowedUDPPorts = [
        53
        5353
      ];
    };
  };

  services.tailscale = {
    enable = true;

    useRoutingFeatures = "server";
    authKeyFile = config.sops.secrets."tailscale-auth/key".path; # "/var/lib/secrets/tailscale-auth-key";
    extraUpFlags = [
      "--advertise-routes=10.177.0.0/16"
      "--snat-subnet-routes=false"
    ];

  };

  security.pki.certificateFiles = [
    ../../certs/madeline-ca.crt
  ];

  system.stateVersion = "26.05";

  home-manager.users.phazonic = import ../../home;

}
