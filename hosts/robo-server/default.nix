# RoboServer - Home server with Matrix Synapse, Nginx, DNS
{
  inputs,
  pkgs,
  wanIface,
  gamingVlanInfo,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./systemd.nix
    ./nginx.nix
    ./dns.nix
    ./ddns.nix
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
    nixd
    nixfmt
  ];

  boot.kernel.sysctl = {
    "net.ipv4.conf.all.forwarding" = true;
    "net.ipv6.conf.all.forwarding" = true;

    # Enable loose mode for asymmetric networking, kernel won't drop packets on the return path coming from tailnet
    "net.ipv4.conf.all.rp_filter" = 2;
    "net.ipv4.conf.default.rp_filter" = 2;
    
    # Disable ipv6 routing between the two vlans
    "net.ipv6.conf.${gamingVlanInfo.iface}.autoconf" = 0;
    "net.ipv6.conf.${gamingVlanInfo.iface}.accept_ra" = 0;
  };

  networking = {

    vlans = {
      ${gamingVlanInfo.iface} = {
        id = 30;
        interface = wanIface;
      };
    };

    interfaces = {
      "${gamingVlanInfo.iface}".useDHCP = true;
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
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];

      interfaces = {
        "${wanIface}" = {
          allowedTCPPorts = [ 22 53 80 443 8080 ];
          allowedUDPPorts = [ 53 ];
        };
        "${gamingVlanInfo.iface}".allowedTCPPorts = [
          80
          443
        ];
        "tailscale0".allowedTCPPorts = [
          22
          53
          80
          443
          8080
        ];
      };

      extraCommands = ''
        iptables -A OUTPUT -d ${gamingVlanInfo.net} -m conntrack --ctstate NEW -j DROP

        iptables -I FORWARD -i ${wanIface} -o ${gamingVlanInfo.iface} -j DROP
        iptables -I FORWARD -i ${gamingVlanInfo.iface} -o ${wanIface} -j DROP

        iptables -I DOCKER-USER -i ${wanIface} -o ${gamingVlanInfo.iface} -j DROP
        iptables -I DOCKER-USER -i ${gamingVlanInfo.iface} -o ${wanIface} -j DROP


         # IPv6 — interface-only match, no CIDR needed
         ip6tables -I FORWARD -i ${wanIface} -o ${gamingVlanInfo.iface} -j DROP
         ip6tables -I FORWARD -i ${gamingVlanInfo.iface} -o ${wanIface} -j DROP
         ip6tables -I DOCKER-USER -i ${wanIface} -o ${gamingVlanInfo.iface} -j DROP
         ip6tables -I DOCKER-USER -i ${gamingVlanInfo.iface} -o ${wanIface} -j DROP
      '';
    };
  };

  services.tailscale = {
    enable = true;
  };

  services.vscode-server = {
    enable = true;
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
