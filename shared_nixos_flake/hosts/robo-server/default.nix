# RoboServer - Home server with Matrix Synapse, Nginx, DNS
{ inputs, config, pkgs, domains, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./synapse.nix
    ./nginx.nix
    ../../modules/nixos/base.nix
  ];

  # Hostname
  networking.hostName = "RoboServer";

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
    packages = [ pkgs.kdePackages.kate ];
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

  # Firewall
  networking.firewall.allowedTCPPorts = [ 53 22 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  # DNS server
  services.dnsmasq = {
    enable = true;
    settings = {
      server = [ "1.1.1.1" "8.8.8.8" ];
      address = [ "/phazonicridley.com/192.168.1.251" "/phazonicridley.xyz/192.168.1.251" ];
      listen-address = [ "127.0.0.1" "192.168.1.251" ];
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
  };

  system.stateVersion = "25.05";
}