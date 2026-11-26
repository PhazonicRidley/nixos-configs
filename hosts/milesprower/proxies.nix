# Reverse proxies served by MilesPrower: name -> backend address (host[:port]).
# Each entry becomes https://<name>.int.<domain>, and RoboServer's DNS points
# that name at MilesPrower (see hosts/robo-server/dns.nix).
#
# These live here (not on RoboServer) because RoboServer is internet-exposed and
# must not be able to open connections into the trusted LAN; whoever terminates
# TLS sees the decrypted traffic, so the proxy has to be as trusted as the backend.
{
  ha = "192.168.128.205"; # Home Assistant (needs http.trusted_proxies set to MilesPrower)
}
