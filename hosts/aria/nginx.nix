{
  domains,
  config,
  ...
}:
let
  matrix_domain = "matrix.${domains.com}";
  libhal_domain = "libhal.${domains.xyz}";
  jfrog_domain = "jfrog.${libhal_domain}";
  grafana_domain = "grafana.phazonic.lan";

  withCloudflareConfigs =
    attr:
    {
      forceSSL = true;
      sslCertificate = "/var/lib/cloudflare-certs/cert.pem";
      sslCertificateKey = "/var/lib/cloudflare-certs/key.pem";
    }
    // attr;

  intCert = {
    sslCertificate = "/opt/lan-cert/wildcard-internal-lan.crt";
    sslCertificateKey = "/opt/lan-cert/wildcard-internal-lan.key";
  };

  withInternalCert =
    attr:
    {
      enableACME = false;
      forceSSL = false;
      addSSL = true;
      inherit (intCert) sslCertificate sslCertificateKey;

    }
    // attr;

in
{
  services.nginx = {
    enable = true;

    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    clientMaxBodySize = "2G";

    "${libhal_domain}" = withCloudflareConfigs {
      locations."/" = {
        proxyPass = "http://localhost:3000";
      };

    };

    "${domains.com}" = {
      useACMEHost = domains.com;
      forceSSL = true;
      locations."= /.well-known/matrix/server".extraConfig =
        let
          body = {
            "m.server" = "${matrix_domain}:443";
          };
        in
        ''
          add_header Content-Type application/json;
          return 200 '${builtins.toJSON body}';
        '';

      locations."= /.well-known/matrix/client".extraConfig =
        let
          body = {
            "m.homeserver" = {
              "base_url" = "https://${matrix_domain}";
            };
            "m.identity_server" = {
              "base_url" = "https://vector.im";
            };
          };
        in
        ''
            				add_header Content-Type application/json;
            				add_header Access-Control-Allow-Origin *;
            				return 200 '${builtins.toJSON body}';
          			   '';

      locations."/" = {
        return = "404";
      };
    };

    "${matrix_domain}" = {
      useACMEHost = domains.com;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8008";
      };
    };

    "_" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 80;
        }
        {
          addr = "[::]";
          port = 80;
        }
        {
          addr = "0.0.0.0";
          port = 443;
          ssl = true;
        }
        {
          addr = "[::]";
          port = 443;
          ssl = true;
        }
      ];
      extraConfig = "ssl_reject_handshake on;";
      default = true;
      locations."/" = {
        return = 444;
      };
    };
  };
}
