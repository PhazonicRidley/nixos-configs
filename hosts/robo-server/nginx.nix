{
  domains,
  config,
  ...
}:

let
  matrix_domain = "matrix.${domains.com}";
  conan_domain = "conan.${domains.xyz}";
  libhal_domain = "libhal.${domains.xyz}";
  ce_domain = "ce.${domains.xyz}";
  jfrog_domain = "jfrog.${domains.xyz}";

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

  internalHosts = {
    "phazonic.lan" = { };

    "ca.phazonic.lan" = {

      root = "/var/www";
      locations = {
        "/" = {
          tryFiles = "/madeline-ca.crt =404";
          extraConfig = ''
            add_header Content-Disposition "attachment; filename=madeline-ca.crt";
          '';
        };

        "/madeline-ca.crt" = {
          tryFiles = "$uri $uri/ =404";
        };
      };
    };

    "retronas.phazonic.lan" = {

      locations."/" = {
        proxyPass = "http://127.0.0.1:3923";
      };
    };
  };

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

      "${jfrog_domain}".globalRedirect = conan_domain;

      "${ce_domain}" = withCloudflareConfigs {
        locations."/" = {
          proxyPass = "http://localhost:10242";
        };
      };

      "${libhal_domain}" = withCloudflareConfigs {
        locations."/" = {
          proxyPass = "http://localhost:3000";
        };

      };

      "${conan_domain}" = withCloudflareConfigs {
        locations."/ui/" = {
          alias = "/var/conan/data/";
          extraConfig = ''
            				disable_symlinks if_not_owner;	
            				autoindex on;
            				'';

        };

        locations."/" = {
          proxyPass = "http://localhost:9300";
          #proxyWebsockets = true;
          #extraConfig = ''
          #proxy_set_header Host $host;
          #proxy_set_header X-Real-IP $remote_addr;
          #proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          #proxy_set_header X-Forwarded-Proto $scheme;
          #proxy_set_header User-Agent $http_user_agent;
          #'';
          extraConfig = ''
            				client_max_body_size 2G;
            				proxy_request_buffering off;
                        			if ($http_user_agent ~* "(Mozilla|Chrome|Safari|Firefox|Edge)") {
                            			return 301 /ui$request_uri;
                        			}
                      			'';
        };

      };

      "retronas" = withInternalCert {
        locations."/" = {
          extraConfig = ''
            return 301 $scheme://retronas.phazonic.lan$request_uri;
          '';
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
          { addr = "0.0.0.0"; port = 80; }
          { addr = "[::]"; port = 80; }
          { addr = "0.0.0.0"; port = 443; ssl = true; }
          { addr = "[::]"; port = 443; ssl = true; }
        ];
        extraConfig = "ssl_reject_handshake on;";
        default = true;
        locations."/" = {
          return = 444;
        };
      };
    }
    // (builtins.mapAttrs (
      name: cfg:
      withInternalCert (
        cfg
        // {
          serverAliases = [ "${name}.phazonic.internal" ];
        }
      )
    ) internalHosts);
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
      environmentFile = "/var/lib/secrets/dreamhost-acme-env";
      group = config.services.nginx.group;
      reloadServices = [ "nginx" ];

      dnsResolver = "1.1.1.1:53";
    };
  };
}
