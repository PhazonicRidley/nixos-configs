{
  config,
  lib,
  domains,
  ...
}:
let
  intDomain = "int.${domains.com}";

  # name -> backend address, shared with RoboServer's DNS config
  proxies = import ./proxies.nix;

  proxyHosts = lib.mapAttrs' (
    name: backend:
    lib.nameValuePair "${name}.${intDomain}" {
      useACMEHost = intDomain;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://${backend}";
        proxyWebsockets = true; # HA frontend (and most web UIs) need websocket upgrades
      };
    }
  ) proxies;
in
{
  imports = [ ../../modules/nixos/dreamhost ];

  # DNS-01 for these certs goes through DreamHost's v1 API (see modules/nixos/dreamhost)
  dreamhostAcme.certs = [ intDomain ];

  services.nginx = {
    enable = true;

    recommendedProxySettings = true; # Host, X-Real-IP, X-Forwarded-*
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    virtualHosts = proxyHosts // {
      # Drop requests for names we don't serve
      "_" = {
        default = true;
        rejectSSL = true;
        locations."/".return = "444";
      };
    };
  };

  # Same wildcard cert RoboServer uses for *.int.<domain> (DNS-01 via DreamHost)
  security.acme = {
    acceptTerms = true;
    defaults.email = "ma13hew@gmail.com";
    defaults.server = "https://acme-v02.api.letsencrypt.org/directory";

    certs.${intDomain} = {
      domain = intDomain;
      extraDomainNames = [ "*.${intDomain}" ];
      group = config.services.nginx.group;
      reloadServices = [ "nginx" ];
      dnsResolver = "1.1.1.1:53";
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
