{
  lib,
  pkgs,
  ...
}:

let
  libhal_domain = "libhal.phazonicridley.xyz";
  forgejo_domain = "git.${libhal_domain}";
in
{
  services.forgejo = {
    enable = true;
    stateDir = "/srv/forgejo";
    database.type = "postgres";

    settings = {
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

  systemd.services.forgejo.serviceConfig = {
    AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
    CapabilityBoundingSet = lib.mkForce [ "CAP_NET_BIND_SERVICE" ];
    PrivateUsers = lib.mkForce false;
  };
}
