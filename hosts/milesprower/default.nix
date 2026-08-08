# MilesPrower - A node for tailscale subnet routing (Maybe some other stuff too idk)
{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
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

    hostName = "RoboServer";
    firewall = {
      allowedTCPPorts = [
        53
        22
      ];
      allowedUDPPorts = [ 53 ];
    };
  };

  # TODO: Replace with ansible playbook
  services.tailscale = {
    enable = true;

    useRoutingFeatures = "server";
    authKeyFile = "/var/lib/secrets/tailscale-auth-key";
    extraUpFlags = [
      "--advertise-routes=192.168.0.0/16, 10.0.0.0/16" # Will be ansible variables
      "--accept-routes"
    ];

  };

  # Disable suspension and sleep (server should stay on)
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  security.pki.certificateFiles = [
    ../murphy-curse/certs/madeline-ca.crt
  ];

  system.stateVersion = "25.11";

  home-manager.users.phazonic = import ../../home;

}
