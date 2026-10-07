{
  lib,
  ...
}:
{
  networking.networkmanager.unmanaged = [
    "interface-name:microvm"
    "interface-name:vm-*"
  ];

  systemd.network = {
    enable = true;
    netdevs."10-microvm".netdevConfig = {
      Kind = "bridge";
      Name = "microvm";
    };

    networks = {
      "10-microvm" = {
        matchConfig.Name = "microvm";
        networkConfig = {
          DHCPServer = true;
          IPv6SendRA = true;
        };
        addresses = [
          { Address = "10.68.0.1/24"; }
          { Address = "fd12:3456:789a::1/64"; }
        ];
        ipv6Prefixes = [
          { Prefix = "fd12:3456:789a::/64"; }
        ];
      };

      "11-microvm" = {
        matchConfig.Name = "vm-*";
        # Attach to the bridge that was configured above
        networkConfig.Bridge = "microvm";
        bridgeConfig.Isolated = true;
      };

    };
    wait-online.enable = lib.mkForce false;
  };

  # Allow inbound traffic for the DHCP server
  networking = {
    firewall.allowedUDPPorts = [ 67 ];
    nat = {
      enable = true;
      externalInterface = "enp122s0f4u1u3"; # replace with your real uplink name
      internalInterfaces = [ "microvm" ];
    };
  };

}
