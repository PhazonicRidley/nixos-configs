{ pkgs, config, ... }:
let
  update-script = pkgs.writeShellApplication {
    name = "dreamhost-ddns";
    runtimeInputs = with pkgs; [
      curl
      jq
      iproute2
      gnugrep
      gawk
      coreutils
    ];
    # DreamHost v1 API client (modules/nixos/dreamhost/api.sh) + the DDNS logic
    text = config.dreamhostAcme.apiLib + "\n" + builtins.readFile ./ddns.sh;
  };
in
{
  systemd.services.dreamhost-ddns = {
    description = "Update phazonicridley.com AAAA record on Dreamhost";
    serviceConfig = {
      Type = "oneshot";
      Environment = "DREAMHOST_API_KEY_FILE=${config.sops.secrets."dreamhost/dns_key".path}";
      ExecStart = "${update-script}/bin/dreamhost-ddns matrix";
    };
  };

  systemd.timers.dreamhost-ddns = {
    wantedBy = [ "timers.target" ];
    description = "Periodically update Dreamhost AAAA DNS record";
    timerConfig = {
      OnBootSec = "5min";
      OnUnitActiveSec = "5min";
      Persistent = true;
      Unit = "dreamhost-ddns.service";
    };
  };
}
