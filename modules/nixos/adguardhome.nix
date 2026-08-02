{ pkgs, ... }:
let
  phoenix86TailscaleIP = "100.64.0.16";
  phoenix86LocalEthernetIP = "192.168.1.110";
in
{
  services.adguardhome = {
    enable = true;
    host = "0.0.0.0";
    port = 3005;

    mutableSettings = true;

    settings = {
      dns = {
        bind_hosts = [ "0.0.0.0" ];
        port = 53;
        ratelimit = 0;
        bootstrap_dns = [
          "1.1.1.1"
          "8.8.8.8"
        ];
        upstream_dns = [
          "https://dns.cloudflare.com/dns-query"
          "tls://dns.google"
        ];
      };
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
    preStart = ''
      for _ in $(seq 1 30); do
        if ${pkgs.iproute2}/bin/ip -4 addr show enp0s20f0u2u4 2>/dev/null | grep -q "${phoenix86LocalEthernetIP}" || \
           ${pkgs.iproute2}/bin/ip -4 addr show tailscale0 2>/dev/null | grep -q "${phoenix86TailscaleIP}"; then
          exit 0
        fi
        sleep 1
      done
      echo "No valid network interfaces (Ethernet or Tailscale) came up within 30s" >&2
      exit 1
    '';
  };

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
