{ pkgs, ... }: let
  update-script = pkgs.writeShellApplication {
    name = "dreamhost-ddns";
    runtimeInputs = with pkgs; [ curl jq iproute2 gnugrep gawk coreutils ];
    text = builtins.readFile ./ddns.sh;
  };
in {
  systemd.services.dreamhost-ddns = {
    description = "Update phazonicridley.com AAAA record on Dreamhost";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${update-script}/bin/dreamhost-ddns";
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
