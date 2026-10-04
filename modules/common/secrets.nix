{
  pkgs,
  config,
  lib,
  ...
}:

let
  mkSopsFilePath =
    {
      dir ? config.networking.hostName,
    }:
    ../../secrets/${lib.toLower dir}.yaml;

  tailscale_secrets = rec {
    sopsFile = mkSopsFilePath { dir = "tailscale"; };
    secrets = {
      "tailscale-auth/key" = {
        inherit sopsFile;
      };
    };
  };

  forgejo_secrets = rec {
    sopsFile = mkSopsFilePath { dir = "forgejo"; };
    owner = "forgejo";
    secrets = {
      "forgejo/internal_token" = {
        inherit sopsFile owner;
      };

      "forgejo/oauth2_jwt_secret" = {
        inherit sopsFile owner;
      };
    };
  };

  web_secrets = rec {
    sopsFile = mkSopsFilePath { dir = "web"; };
    nginxUser = config.services.nginx.user;
    restartUnits = [ "nginx.service" ];

    secrets = {
      "cloudflare/key" = {
        inherit sopsFile restartUnits;
        owner = nginxUser;
      };

      "lan-cert/key" = {
        inherit sopsFile restartUnits;
        owner = nginxUser;
      };

      "dreamhost-acme-env" = {
        inherit sopsFile;
      };
    };
  };
in
{
  # TODO: move this to a devShell
  environment.systemPackages = with pkgs; [
    sops
    age
  ];

  sops.age.keyFile = "/var/lib/sops-nix/keys.txt";
  sops.secrets = lib.mkMerge [
    (lib.mkIf config.services.nginx.enable web_secrets.secrets)
    (lib.mkIf config.services.tailscale.enable tailscale_secrets.secrets)
    (lib.mkIf config.services.forgejo.enable forgejo_secrets.secrets)
  ];
}
