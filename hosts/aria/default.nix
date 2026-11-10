{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/common/secrets.nix
    ./forgejo.nix
    ./nginx.nix
    ./synapse.nix
    inputs.nixos-cli.nixosModules.nixos-cli
    inputs.optnix.nixosModules.optnix
    inputs.disko.nixosModules.disko
  ];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  services.openssh = {
    enable = true;
    # Listen on all addresses instead of binding the tailscale IP: if sshd
    # starts before tailscale0 has its address, that bind fails and sshd
    # silently runs on localhost only. The firewall below only opens 2222 on
    # tailscale0, so it is still tailnet-only. Port 22 is Forgejo's SSH server.
    ports = [ 2222 ];
    openFirewall = false;

    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "phazonic" ];
    };
  };

  environment.systemPackages = with pkgs; [
    curl
    fastfetch
    docker-compose
    htop
    nixd
  ];

  # Console/sudo password, decrypted before users are created.
  sops.secrets.master_pass = {
    sopsFile = ../../secrets/aria.yaml;
    neededForUsers = true;
  };

  # With mutable users, NixOS only applies a declared password when it first
  # creates the user and keeps whatever /etc/shadow already has afterwards, so
  # the sops password would never reach the existing phazonic account. Make
  # users fully declarative instead (`passwd` changes are reset on activation).
  users.mutableUsers = false;

  # User configuration
  users.users.phazonic = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.master_pass.path;
    description = "Madeline Schneider";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINgFpBjoDEVwG25M8hHf10tzJXKRfnKLC/2o3nqr9d61 phazonic@Xiao"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQViKzWhCVMQEs31w5+J9kwb6GZA8xopG1YSTD7z5j/ phazonic@MurphyCurse"
    ];
  };

  users.users.root.hashedPasswordFile = config.sops.secrets.master_pass.path;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQViKzWhCVMQEs31w5+J9kwb6GZA8xopG1YSTD7z5j/ phazonic@MurphyCurse"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINgFpBjoDEVwG25M8hHf10tzJXKRfnKLC/2o3nqr9d61 phazonic@Xiao"
  ];

  networking = {
    networkmanager = {
      enable = true;
      insertNameservers = [
        "1.1.1.1"
        "8.8.8.8"
      ];
    };

    hostName = "Aria";

    firewall = {
      allowedTCPPorts = [
        22
        80
        443
      ];

      interfaces.tailscale0.allowedTCPPorts = [ 2222 ];
    };

  };

  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets."tailscale-auth/key".path;
    useRoutingFeatures = "client";
    extraSetFlags = [ "--accept-routes" ];
  };

  system.stateVersion = "24.05";

  home-manager.users.phazonic = import ../../home;
}
