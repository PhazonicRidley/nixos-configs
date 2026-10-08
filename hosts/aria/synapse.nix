{ domains, ... }: {
  services.matrix-synapse = {
    enable = true;
    settings = {
      server_name = domains.com;
      enable_registration = false;
      database = {
        name = "psycopg2";
        args = {
          user = "matrix-synapse";
          database = "matrix-synapse";
        };
      };
    };

    extraConfigFiles = [ "/etc/matrix-synapse/secrets.yaml" ];
  };

  services.postgresql = {
    enable = true;
    ensureDatabases = [ "matrix-synapse" ];
    ensureUsers = [
      {
        name = "matrix-synapse";
        ensureDBOwnership = true;
      }
    ];
  };
}
