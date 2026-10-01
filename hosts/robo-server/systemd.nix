{ pkgs, domains, ... }:

{
  services.matrix-synapse = {
    enable = true;
    settings = {
      server_name = domains.com;
      enable_registration = false;
      database.name = "sqlite3";
    };

    extraConfigFiles = [ "/etc/matrix-synapse/secrets.yaml" ];
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      conan_server = {
        image = "conanio/conan_server:latest";
        ports = [ "9300:9300" ];
        volumes = [ "/var/conan:/root/.conan_server" ];
      };
    };
  };

  systemd.services = {
    retronas = {
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

    # TODO: Redo CE's infra. Only compilers are bind-mounted (camdrive/godbolt ->
    # /opt/compiler-explorer); conan libraries (/root/.conan2, /opt/full_deploy) land
    # in the container's writable layer (~29G and growing). Mount those too, and
    # declare ce in virtualisation.oci-containers instead of `docker start`ing a
    # hand-made container. ce_test (~68G) has the same problem.
    compiler-explorer = {
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
  };
}
