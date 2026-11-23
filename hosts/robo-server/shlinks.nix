{ config, ... }:
let
  shortDomain = "sh";
in
{
  virtualisation.oci-containers = {
    backend = "docker"; # NixOS defaults to podman

    containers = {
      shlink = {
        image = "ghcr.io/shlinkio/shlink:stable";
        ports = [ "127.0.0.1:8080:8080" ];
        volumes = [ "shlink-data:/etc/shlink/data" ]; # SQLite DB lives here
        environment = {
          DEFAULT_DOMAIN = shortDomain;
          IS_HTTPS_ENABLED = "false";
        };
        # Contains: INITIAL_API_KEY=<uuid>   (only applied on first boot with an empty DB)
        environmentFiles = [ config.sops.secrets."shlink/env".path ];
      };

      shlink-web = {
        image = "ghcr.io/shlinkio/shlink-web-client:latest";
        ports = [ "127.0.0.1:8081:8080" ];
        environment = {
          SHLINK_SERVER_URL = "https://shlink.int.phazonicridley.com";
          SHLINK_SERVER_NAME = "Shlink";
        };
        # Contains: SHLINK_SERVER_API_KEY=<same uuid>
        # Drop this line to add the server manually in the UI instead.
        environmentFiles = [ config.sops.secrets."shlink/web_env".path ];

        dependsOn = [ "shlink" ];
      };
    };
  };
}
