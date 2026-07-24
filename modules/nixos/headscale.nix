{ config, ... }:

let
  domain = "vpn.thomas.ritaine.com";
  phoenix86TailscaleIP = "100.64.0.16";
in
{
  services.headscale = {
    enable = true;
    settings = {
      server_url = "https://${domain}";

      dns = {
        base_domain = "internal";
        magic_dns = true;
        override_local_dns = true;
        nameservers.global = [
          phoenix86TailscaleIP
          "1.1.1.1"
          "8.8.8.8"
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
          "ip": ["udp:53", "tcp:53"]
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
