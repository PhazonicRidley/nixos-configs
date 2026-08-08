{
  ...
}:
{
  # DNS server
  services.dnsmasq = {
    enable = true;
    settings = {
      server = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      address = [
        "/phazonicridley.com/192.168.20.2"
        "/retronas/192.168.20.2"
        "/retronas.lan/192.168.20.2"
        "/att/192.168.1.254"
        "/lan/192.168.20.2"
        "/internal/192.168.20.2"
      ];
      listen-address = [
        "127.0.0.1"
        "192.168.20.2"
      ];
      #      bind-interfaces = true;
      bind-dynamic = true;

    };

  };
}
