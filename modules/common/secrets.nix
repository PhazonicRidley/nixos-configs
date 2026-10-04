{
  pkgs,
  config,
  lib,
  ...
}:

let
  web_secrets = rec {
    # TODO: Change to hosts/<hostname>/<hostname>.yaml, requires changing folder names
    sopsFile = ../../secrets/${lib.toLower config.networking.hostName}.yaml;
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
  sops.secrets = web_secrets.secrets;
}
