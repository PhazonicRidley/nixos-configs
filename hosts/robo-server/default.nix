# RoboServer - Home server with Matrix Synapse, Nginx, DNS
{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./synapse.nix
    ./nginx.nix
    ./conan-server.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/avahi.nix
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
  services.openssh.settings.PasswordAuthentication = true;
  # Additional system packages
  environment.systemPackages = with pkgs; [
    fastfetch
    docker-compose
    gcc14
    htop
  ];


  boot.kernel.sysctl."net.ipv4.ip_forward" = 0;

  networking = {
    
    vlans = {
      gayming = { id = 30; interface = "enp39s0"; };
    };

    interfaces = {
      "gayming".useDHCP = true;
    };

    networkmanager = {
      enable = true;
      insertNameservers = [
        "127.0.0.1"
        "1.1.1.1"
        "8.8.8.8"
      ];
    };

    hostName = "RoboServer";
    firewall = {
      allowedTCPPorts = [
        53
        22
      ];
      allowedUDPPorts = [ 53 ];
    };
  };

  # DNS server
  services.dnsmasq = {
    enable = true;
    settings = {
      server = [
        "1.1.1.1"
        "8.8.8.8"
        "192.168.20.2"
      ];
      address = [ "/phazonicridley.com/192.168.20.2" ];
      listen-address = [
        "127.0.0.1"
        "192.168.20.2"
      ];
      bind-interfaces = true;
    };

  };

  # Disable suspension and sleep (server should stay on)
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Home-manager user config
  home-manager.users.phazonic = import ./home.nix;
  home-manager.extraSpecialArgs = {
    inherit inputs;
    username = "phazonic";
    isGlobalPkgs = false;
  };

  system.stateVersion = "25.05";
}

