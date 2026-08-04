{ pkgs, ... }:

{
  systemd.services.retronas = {
    description = "RetroNAS docker-compose stack";
    after = [ "docker.service" "network-online.target" ];
    requires = [ "docker.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/home/phazonic/retronas";
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose start";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose stop";
    };
  };
}
