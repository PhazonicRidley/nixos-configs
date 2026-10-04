{
  domains,
  config,
  ...
}:
let
  matrix_domain = "matrix.${domains.com}";
  libhal_domain = "libhal.${domains.xyz}";
  forgejo_domain = "git-libhal.${domains.xyz}";
  jfrog_domain = "jfrog.${libhal_domain}";
  grafana_domain = "grafana.phazonic.lan";

  # TODO: Refactor this out as its duplicate code from roboserver's nginx config
  withCloudflareConfigs =
    attr:
    {
      forceSSL = true;
      sslCertificate = ../../certs/cloudflare-cert.pem;
      sslCertificateKey = config.sops.secrets."cloudflare/key".path;
    }
    // attr;

  intCert = {
    sslCertificate = ../../certs/wildcard-internal-lan.crt;
    sslCertificateKey = config.sops.secrets."lan-cert/key".path;
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

    virtualHosts = {
      "${libhal_domain}" = withCloudflareConfigs {
        locations."/" = {
          # TODO: this is to be the docs
        };
      };


      "${forgejo_domain}" = withCloudflareConfigs {
          forceSSL = true;
          extraConfig = "client_max_body_size 512M;";
          locations."/".proxyPass = "http://127.0.0.1:3000";
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
  };

  # ACME/Let's Encrypt configuration
  security.acme = {
    acceptTerms = true;
    defaults.email = "ma13hew@gmail.com";
    defaults.server = "https://acme-v02.api.letsencrypt.org/directory";

    certs."${domains.com}" = {
      domain = domains.com;
      extraDomainNames = [ "*.${domains.com}" ];
      dnsProvider = "dreamhost";
      environmentFile = config.sops.secrets."dreamhost-acme-env".path;
      group = config.services.nginx.group;
      reloadServices = [ "nginx" ];

      dnsResolver = "1.1.1.1:53";
    };
  };
}
