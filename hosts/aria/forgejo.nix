{
  lib,
  pkgs,
  config,
  domains,
  ...
}:
let
  # libhal_domain = "libhal.${domains.xyz}";
  forgejo_domain = "git-libhal.${domains.xyz}";
in
{
  services.forgejo = {
    enable = true;
    stateDir = "/srv/forgejo";
    database.type = "postgres";

    settings = {

      DEFAULT = {
        APP_NAME = "Libhal Mirror";
        APP_SLOGAN = "Libhal backup git server and runner";
      };

      server = {
        DOMAIN = forgejo_domain;
        ROOT_URL = "https://${forgejo_domain}";
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = 3000;

        START_SSH_SERVER = true;
        SSH_LISTEN_HOST = "0.0.0.0";
      };

      session = {
        COOKIE_SECURE = true;
        DISABLE_REGISTRATION = true;
      };
    };
  };

  services.postgresql.package = pkgs.postgresql_17;
  environment.systemPackages = [ config.services.forgejo.package ];

  systemd.services.forgejo.serviceConfig = {
    AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
    CapabilityBoundingSet = lib.mkForce [ "CAP_NET_BIND_SERVICE" ];
    PrivateUsers = lib.mkForce false;
  };
}
