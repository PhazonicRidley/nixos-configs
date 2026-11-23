{
  lib,
  ...
}:
let
  serverV4 = "192.168.20.2";
  serverV6 = "fdbe:a276:cdec:20::2";

  # Names that resolve to RoboServer (A + AAAA)
  intDomain = "int.phazonicridley.com";
  serverNames = [
    "${intDomain}"
    "sh"
    "retronas"
    "retronas.lan"
    "lan"
    "internal"
  ];
in
{
  # DNS server
  services.dnsmasq = {
    enable = true;
    settings = {
      server = [
        "9.9.9.9"
        "1.1.1.1"
        "2620:fe::fe"
        "2606:4700:4700::1111"
      ];

      address =
        lib.concatMap (name: [
          "/${name}/${serverV4}"
          "/${name}/${serverV6}"
        ]) serverNames
        ++ [
          "/att/192.168.1.254"
          "/voron2.${intDomain}/192.168.128.190"
        ];

      # att has no IPv6 address, so answer its AAAA queries locally (empty answer) instead of forwarding upstream
      local = [ "/att/" ];

      listen-address = [
        "127.0.0.1"
        "::1"
        serverV4
        serverV6
      ];
      bind-dynamic = true;
    };
  };
}
