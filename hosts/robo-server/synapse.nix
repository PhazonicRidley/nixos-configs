{
  domains,
  ...
}:
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
}
