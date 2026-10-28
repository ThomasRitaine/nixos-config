{ lib, ... }:
{
  services.adguardhome = {
    enable = true;
    host = "0.0.0.0";
    port = 3005;

    mutableSettings = true;

    settings = {
      dns = {
        # Listening on every interface means AdGuard needs no specific IP to exist at boot
        bind_hosts = [ "0.0.0.0" ];
        port = 53;
        ratelimit = 0;
        # Only used to resolve hostnames in upstreams; the upstreams below are IP-based
        bootstrap_dns = [
          "1.1.1.1" # Cloudflare
          "9.9.9.9" # Quad9
        ];
        upstream_dns = [
          "https://1.1.1.1/dns-query" # Cloudflare
          "https://8.8.8.8/dns-query" # Google
        ];
        # Refuses queries from anywhere else, as the host has a public IPv6 address
        allowed_clients = [
          "127.0.0.0/8" # this host
          "::1/128" # this host
          "192.168.1.0/24" # home LAN
          "172.16.0.0/12" # docker
          "100.64.0.0/10" # tailnet
          "fd7a:115c:a1e0::/48" # tailnet
        ];
        # Name clients via reverse DNS: LAN devices from the Freebox, tailnet devices from Tailscale.
        # A reverse zone is the network part of the address written backwards, one label per
        # byte for IPv4 (in-addr.arpa) and one label per hex digit for IPv6 (ip6.arpa).
        use_private_ptr_resolvers = true;
        local_ptr_upstreams = [
          "192.168.1.254" # Freebox, default for every private range not matched below
          "[/1.168.192.in-addr.arpa/]192.168.1.254" # 192.168.1.0/24 -> Freebox, names *.home
          "[/64.100.in-addr.arpa/]100.100.100.100" # 100.64.0.0/16 -> Tailscale resolver, names *.internal
          "[/0.e.1.a.c.5.1.1.a.7.d.f.ip6.arpa/]100.100.100.100" # fd7a:115c:a1e0::/48 -> Tailscale resolver
        ];
        # Ranges treated as private: their reverse lookups go to local_ptr_upstreams, and only
        # clients inside them get answers. Replaces AdGuard's default list, so the standard
        # ranges are repeated with the tailnet one.
        private_networks = [
          "10.0.0.0/8" # RFC 1918
          "172.16.0.0/12" # RFC 1918, docker
          "192.168.0.0/16" # RFC 1918, home LAN
          "169.254.0.0/16" # IPv4 link-local
          "100.64.0.0/10" # CGNAT, tailnet
          "127.0.0.0/8" # IPv4 loopback
          "::1/128" # IPv6 loopback
          "fd00::/8" # IPv6 unique local, includes the tailnet fd7a:115c:a1e0::/48
          "fe80::/10" # IPv6 link-local
        ];
      };
      # Where AdGuard finds names for clients not declared as persistent clients
      clients.runtime_sources = {
        rdns = true; # Reverse DNS through local_ptr_upstreams
        hosts = true; # /etc/hosts on this host
        arp = true; # Neighbour table: devices seen on the LAN, IP only without a name
        whois = false; # Public WHOIS data, meaningless for private addresses
        dhcp = false; # AdGuard's own DHCP leases, unused as the Freebox does DHCP
      };
      # The router handles DHCP; this stops the "starting dhcp server" error at every start
      dhcp.enabled = false;
      filtering = {
        protection_enabled = true;
      };
      filters = [
        {
          enabled = true;
          url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
          name = "AdGuard DNS filter";
          id = 1;
        }
        {
          enabled = true;
          url = "https://raw.githubusercontent.com/hagezi/dns-blocklists/main/adblock/pro.txt";
          name = "HaGeZi Multi PRO";
          id = 2;
        }
      ];
      user_rules = [
        # Stops Firefox from silently switching to its own DNS-over-HTTPS resolver
        "||use-application-dns.net^$dnsrewrite=NXDOMAIN;;"
        # Turns off iCloud Private Relay on this network so Apple devices stay filtered
        "||mask.icloud.com^$dnsrewrite=NXDOMAIN;;"
        "||mask-h2.icloud.com^$dnsrewrite=NXDOMAIN;;"
      ];
    };
  };

  systemd.services.adguardhome = {
    after = [
      "network-online.target"
      "tailscaled.service"
    ];
    wants = [
      "network-online.target"
      "tailscaled.service"
    ];
  };

  # The host's own DNS uses the local AdGuard first, so it never depends on the
  # ISP's DHCP DNS list. This keeps exit-node DNS working for tailnet clients.
  networking.nameservers = lib.mkBefore [
    "127.0.0.1"
    "1.1.1.1"
  ];

  # DNS is open on the LAN interfaces only; the web UI is reachable over the
  # tailnet only, as tailscale0 is a trusted interface
  networking.firewall = {
    enable = true;
    interfaces = {
      enp0s13f0u1u1 = {
        # wired LAN
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };
      wlp0s20f3 = {
        # Wi-Fi LAN
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };
    };
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "false";
      # AdGuard needs port 53, which resolved's stub listener would otherwise take
      DNSStubListener = "no";
    };
  };

  services.restic.backups.daily.paths = [ "/var/lib/AdGuardHome" ];
}
