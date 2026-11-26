{
  domains,
  config,
  lib,
  ...
}:

let
  conan_domain = "conan.${domains.xyz}";
  libhal_domain = "libhal.${domains.xyz}";
  ce_domain = "ce.${domains.xyz}";
  jfrog_domain = "jfrog.${domains.xyz}";

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

  # RoboServer's 443 is reachable from the internet (WAN port-forward), and nginx serves
  # whatever vhost the client names, regardless of DNS. Internal vhosts must therefore
  # check the *source address* themselves. Port-forwarded traffic keeps the real client IP,
  # and there is no real_ip config, so $remote_addr can't be spoofed via headers.
  internalSources = [
    "127.0.0.1"
    "::1"
    "192.168.0.0/16" # LAN + VLANs; Tailscale subnet-router traffic arrives SNATed from MilesPrower
    "100.64.0.0/10" # Tailscale v4
    "fd7a:115c:a1e0::/48" # Tailscale v6
    "fdbe:a276:cdec::/48" # LAN ULA
    "2600:1700:65a3:700::/60" # AT&T-delegated GUA prefix (MilesPrower sources from it); update if AT&T changes it
  ];

  internalOnlyConfig = lib.concatMapStrings (src: "allow ${src};\n") internalSources + "deny all;\n";

  # Restrict a vhost to internal sources (anything else gets 403)
  withInternalOnly =
    attr:
    attr
    // {
      extraConfig = internalOnlyConfig + (attr.extraConfig or "");
    };

  # copyparty (RetroNAS file server), served as both retronas.phazonic.lan and retronas.int.<domain>
  copypartyLocation = {
    proxyPass = "http://127.0.0.1:3923";
  };

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
      locations."/" = copypartyLocation;
    };
  };

in
{
  imports = [ ../../modules/nixos/dreamhost ];

  # DNS-01 for these certs goes through DreamHost's v1 API (see modules/nixos/dreamhost)
  dreamhostAcme.certs = [ "int.${domains.com}" ];

  services.nginx = {
    enable = true;

    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    clientMaxBodySize = "2G";

    virtualHosts = {

      "sh" = withInternalCert (withInternalOnly {
        locations."= /" = {
          proxyPass = "http://127.0.0.1:8080";
          recommendedProxySettings = true;
          extraConfig = ''
            if ($http_accept ~* "text/html") {
              return 301 https://shlink.int.${domains.com};
            }
          '';
        };

        locations."/" = {
          proxyPass = "http://127.0.0.1:8080";
          recommendedProxySettings = true;
        };
      });

      "shlink.int.${domains.com}" = withInternalOnly {
        useACMEHost = "int.${domains.com}";
        forceSSL = true;

        locations."/" = {
          proxyPass = "http://127.0.0.1:8081"; # Web UI
        };

        locations."/rest/".proxyPass = "http://127.0.0.1:8080"; # Shlink API, same origin as the UI
      };

      # Same copyparty backend as retronas.phazonic.lan, but with the publicly trusted *.int cert
      "retronas.int.${domains.com}" = withInternalOnly {
        useACMEHost = "int.${domains.com}";
        forceSSL = true;
        locations."/" = copypartyLocation;
      };

      "a.int.${domains.com}" = withInternalOnly {
        useACMEHost = "int.${domains.com}";
        forceSSL = true;
      };
      "int.${domains.com}" = withInternalOnly {
        useACMEHost = "int.${domains.com}";
        forceSSL = true;
      };

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

      "retronas" = withInternalCert (withInternalOnly {
        locations."/" = {
          extraConfig = ''
            return 301 $scheme://retronas.phazonic.lan$request_uri;
          '';
        };
      });

      # "${domains.com}" = {
      #   useACMEHost = domains.com;
      #   forceSSL = true;
      #   locations."/" = { };
      # };

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
    }
    // (builtins.mapAttrs (
      name: cfg:
      withInternalCert (
        withInternalOnly (
          cfg
          // {
            serverAliases = [ "${name}.phazonic.internal" ];
          }
        )
      )
    ) internalHosts);
  };

  # ACME/Let's Encrypt configuration
  security.acme = {
    acceptTerms = true;
    defaults.email = "ma13hew@gmail.com";
    defaults.server = "https://acme-v02.api.letsencrypt.org/directory";

    certs."int.${domains.com}" = {
      domain = "int.${domains.com}";
      extraDomainNames = [
        "int.${domains.com}"
        "*.int.${domains.com}"
      ];
      group = config.services.nginx.group;
      reloadServices = [ "nginx" ];

      dnsResolver = "1.1.1.1:53";
    };

    # certs."${domains.com}" = {
    #   domain = domains.com;
    #   extraDomainNames = [ "*.${domains.com}" ];
    #   # (also add it to dreamhostAcme.certs above)
    #   group = config.services.nginx.group;
    #   reloadServices = [ "nginx" ];
    #
    #   dnsResolver = "1.1.1.1:53";
    # };
  };
}
