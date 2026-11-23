{
  lib,
  domains,
  ...
}:
let
  serverV4 = "192.168.20.2";
  serverV6 = "fdbe:a276:cdec:20::2";

  # MilesPrower serves these reverse proxies itself (no ULA, so IPv4 only)
  milesProwerV4 = "192.168.67.4";
  proxyFqdns = map (name: "${name}.int.${domains.com}") (
    builtins.attrNames (import ../milesprower/proxies.nix)
  );

  # Names that resolve to RoboServer (A + AAAA)
  serverNames = [
    "int.phazonicridley.com"
    "sh"
    "retronas"
    "retronas.lan"
    "lan"
    "internal"
  ];
in
{
  # DNS server
  services.dnsmasq = {
    enable = true;
    settings = {
      server = [
        "9.9.9.9"
        "1.1.1.1"
        "2620:fe::fe"
        "2606:4700:4700::1111"
      ];

      address =
        lib.concatMap (name: [
          "/${name}/${serverV4}"
          "/${name}/${serverV6}"
        ]) serverNames
        ++ map (fqdn: "/${fqdn}/${milesProwerV4}") proxyFqdns
        ++ [
          "/att/192.168.1.254"
        ];

      # att has no IPv6 address, so answer its AAAA queries locally (empty answer) instead of forwarding upstream
      # Same for the MilesPrower proxies: no AAAA, and don't fall through to RoboServer's wildcard v6
      local = [ "/att/" ] ++ map (fqdn: "/${fqdn}/") proxyFqdns;

      listen-address = [
        "127.0.0.1"
        "::1"
        serverV4
        serverV6
      ];
      bind-dynamic = true;
    };
  };
}
