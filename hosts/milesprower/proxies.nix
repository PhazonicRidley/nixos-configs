# Reverse proxies served by MilesPrower: name -> backend address (host[:port]).
# Each entry becomes https://<name>.int.<domain>, and RoboServer's DNS points
# that name at MilesPrower (see hosts/robo-server/dns.nix).
# TODO: discover these via mDNS instead of listing them by hand.
{
  voron = "192.168.128.190";
}
