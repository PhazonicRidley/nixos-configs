{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./disk-config.nix
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    inputs.nixos-cli.nixosModules.nixos-cli
    inputs.optnix.nixosModules.optnix
    inputs.disko.nixosModules.disko
  ];

  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    curl
    fastfetch
    docker-compose
    htop
    nixd
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQViKzWhCVMQEs31w5+J9kwb6GZA8xopG1YSTD7z5j/ phazonic@MurphyCurse"
    ];
  };

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

    firewall.allowedTCPPorts = [
      22
      80
      443
    ];

  };

  services.tailscale = {
    enable = true;
    # authKeyFile = "/var/lib/secrets/tailscale-auth-key";

  };

  # Disable suspension and sleep (server should stay on)
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  system.stateVersion = "24.05";

  home-manager.users.phazonic = import ../../home;
}
