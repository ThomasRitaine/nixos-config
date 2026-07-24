{ pkgs, ... }:
let
  phoenix86TailscaleIP = "100.64.0.16";
in
{
  services.adguardhome = {
    enable = true;
    host = "127.0.0.1";
    port = 3005;

    mutableSettings = true;

    settings = {
      dns = {
        bind_hosts = [ phoenix86TailscaleIP ];
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
    after = [ "tailscaled.service" ];
    wants = [ "tailscaled.service" ];
    preStart = ''
      for _ in $(seq 1 30); do
        if ${pkgs.iproute2}/bin/ip -4 addr show tailscale0 2>/dev/null | grep -q "${phoenix86TailscaleIP}"; then
          exit 0
        fi
        sleep 1
      done
      echo "tailscale0 did not come up with ${phoenix86TailscaleIP} within 30s" >&2
      exit 1
    '';
  };

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  services.restic.backups.daily.paths = [ "/var/lib/AdGuardHome" ];
}
