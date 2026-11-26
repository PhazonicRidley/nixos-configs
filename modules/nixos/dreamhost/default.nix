# DreamHost DNS-01 for ACME, via DreamHost's v1 API.
#
# DreamHost retired its legacy API (api.dreamhost.com/?key=...&cmd=...) in Nov 2026,
# and lego's built-in `dreamhost` provider still speaks only that. So certs listed
# in `dreamhostAcme.certs` use lego's generic `exec` provider with our own hook
# (./acme-hook.sh) that talks to the new Bearer-token API instead.
#
# Usage, next to a normal security.acme.certs.<name> definition:
#   dreamhostAcme.certs = [ "<name>" ];
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dreamhostAcme;

  # Shared v1 API client, prepended to each script that uses it
  apiLib = builtins.readFile ./api.sh;

  acmeHook = pkgs.writeShellApplication {
    name = "dreamhost-acme-hook";
    runtimeInputs = with pkgs; [
      curl
      jq
      coreutils
    ];
    text = apiLib + "\n" + builtins.readFile ./acme-hook.sh;
  };
in
{
  options.dreamhostAcme = {
    certs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Names of security.acme.certs entries that solve DNS-01 through DreamHost's v1 API.";
    };

    apiLib = lib.mkOption {
      type = lib.types.lines;
      readOnly = true;
      default = apiLib;
      description = "Shell source of the DreamHost v1 API client, for other scripts (e.g. DDNS) to reuse.";
    };
  };

  config = lib.mkIf (cfg.certs != [ ]) {
    security.acme.certs = lib.genAttrs cfg.certs (_: {
      dnsProvider = "exec";
      # Exposed to the service as DREAMHOST_API_KEY_FILE=<systemd credential path>
      credentialFiles.DREAMHOST_API_KEY_FILE = config.sops.secrets."dreamhost/dns_key".path;
    });

    systemd.services = lib.listToAttrs (
      map (
        cert:
        lib.nameValuePair "acme-order-renew-${cert}" {
          environment = {
            EXEC_PATH = lib.getExe acmeHook;
            # DreamHost applies record changes asynchronously (HTTP 202), so give propagation time
            EXEC_PROPAGATION_TIMEOUT = "1800";
            EXEC_POLLING_INTERVAL = "30";
          };
        }
      ) cfg.certs
    );
  };
}
