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
          "1.1.1.1"
          "9.9.9.9"
        ];
        upstream_dns = [
          "https://1.1.1.1/dns-query"
          "https://8.8.8.8/dns-query"
        ];
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

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      53
      3005
    ];
    allowedUDPPorts = [ 53 ];
  };

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "false";
      DNSStubListener = "no";
    };
  };

  services.restic.backups.daily.paths = [ "/var/lib/AdGuardHome" ];
}
