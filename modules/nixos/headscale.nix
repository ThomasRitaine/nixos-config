{ config, lib, ... }:

let
  domain = "vpn.thomas.ritaine.com";
  phoenix86TailscaleIP = "100.64.0.16";

  # MagicDNS suffix. tailscale.nix routes it to tailscaled's resolver on nodes
  # running with --accept-dns=false (this host included).
  tailnetDomain = "internal";
  tailnetDelegate = "systemd/dns-delegate.d/tailnet.dns-delegate";
in
{
  # This host runs tailscale with --accept-dns=false. Without the delegate from
  # tailscale.nix, *.internal stops resolving here and in every Docker container
  # (the Jellyfin Live TV outage of 2026-10-30). Fail the build instead.
  assertions = [
    {
      assertion = lib.hasInfix "Domains=~${tailnetDomain}" (
        toString (config.environment.etc.${tailnetDelegate}.text or "")
      );
      message = ''
        headscale.nix: the tailnet DNS delegate for "~${tailnetDomain}" is missing.
        Import tailscale.nix with bypassHeadscaleDns = true and
        tailnetDomain = "${tailnetDomain}", or *.internal names will not resolve.
      '';
    }
  ];

  services.headscale = {
    enable = true;
    settings = {
      server_url = "https://${domain}";

      dns = {
        base_domain = tailnetDomain;
        magic_dns = true;
        override_local_dns = true;
        # Tailscale queries every global nameserver in parallel and keeps the
        # first answer. Mixing AdGuard with unfiltered resolvers (1.1.1.1,
        # 8.8.8.8) let the faster unfiltered one win, bypassing the filter
        # almost every time. Every entry here must therefore filter: home
        # AdGuard first, AdGuard DNS public (default filtering) as fallback
        # so DNS keeps working when home is down.
        nameservers.global = [
          phoenix86TailscaleIP
          "94.140.14.14" # AdGuard DNS, default filtering
          "94.140.15.15" # AdGuard DNS, default filtering
        ];
      };

      ip_prefixes = [ "100.64.0.0/10" ];

      policy = {
        mode = "file";
        path = "/etc/headscale/policy.hujson";
      };
    };
  };

  environment.etc."headscale/policy.hujson".text = ''
    {
      "groups": {
        "group:admin": ["thomas@"]
      },

      "tagOwners": {
        "tag:server": ["group:admin"],
        "tag:home": ["group:admin"],
        "tag:exit": ["group:admin"]
      },

      "autoApprovers": {
        "exitNode": ["tag:exit"]
      },

      "grants": [
        {
          "src": ["group:admin"],
          "dst": ["*"],
          "ip": ["*"]
        },
        {
          "src": ["group:admin"],
          "dst": ["autogroup:internet"],
          "ip": ["*"]
        },
        {
          "src": ["autogroup:member"],
          "dst": ["autogroup:internet"],
          "via": ["tag:exit"],
          "ip": ["*"]
        },
        {
          "src": ["autogroup:member"],
          "dst": ["autogroup:member"],
          "ip": ["*"]
        },
        {
          "src": ["autogroup:member"],
          "dst": ["tag:server"],
          "ip": ["*"]
        },
        {
          "src": ["autogroup:member"],
          "dst": ["tag:home"],
          "ip": [
            // DNS
            "udp:53", "tcp:53",
            // Sunshine client ports (HTTPS/HTTP API, RTSP, Video/Input/Audio)
            "tcp:47984", "tcp:47989", "tcp:48010",
            "udp:47998-48000", "udp:48010"
          ]
        },
        {
          "src": ["tag:server"],
          "dst": ["tag:server"],
          "ip": ["*"]
        },
        {
          "src": ["tag:server"],
          "dst": ["autogroup:member"],
          "ip": ["*"]
        },
        {
          "src": ["tag:server"],
          "dst": ["tag:home"],
          "ip": ["*"]
        },
        {
          "src": ["tag:home"],
          "dst": ["tag:server"],
          "ip": ["*"]
        }
      ]
    }
  '';

  systemd.services.headscale.restartTriggers = [
    config.environment.etc."headscale/policy.hujson".source
  ];

  environment.etc."traefik/dynamic/headscale.yml" = {
    text = ''
      http:
        routers:
          headscale:
            rule: "Host(`${domain}`)"
            entryPoints:
              - "websecure"
            service: "headscale"

        services:
          headscale:
            loadBalancer:
              servers:
                - url: "http://127.0.0.1:8080"
    '';
  };

  services.restic.backups.daily.paths = [ "/var/lib/headscale" ];
}
