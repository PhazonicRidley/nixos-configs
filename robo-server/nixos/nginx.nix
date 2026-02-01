{ config, pkgs, ... }:

{

  services.nginx = {
    enable = true;

    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    clientMaxBodySize = "2G";

    virtualHosts."jfrog.phazonicridley.xyz".globalRedirect = "conan.phazonicridley.xyz";

    virtualHosts."conan.phazonicridley.xyz" = {
      forceSSL = true;
      #enableACME = true;
      sslCertificate = "/var/lib/cloudflare-certs/cert.pem";
      sslCertificateKey = "/var/lib/cloudflare-certs/key.pem";
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
  };

  # ACME/Let's Encrypt configuration
  #security.acme = {
  #	acceptTerms = true;
  #	defaults.email = "ma13hew@gmail.com";
  #};

  # Open firewall for HTTP
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
