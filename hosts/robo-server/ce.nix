{ pkgs, ... }:

{
  systemd.services.compiler-explorer = {
    description = "Compiler Explorer (ce) docker container";
    after = [ "docker.service" "network-online.target" ];
    requires = [ "docker.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.docker}/bin/docker start ce";
      ExecStop = "${pkgs.docker}/bin/docker stop ce";
    };
  };
}
