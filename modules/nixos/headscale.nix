let
  domain = "vpn.thomas.ritaine.com";
in
{
  services.headscale = {
    enable = true;
    settings = {
      server_url = "https://${domain}";
      dns = {
        base_domain = "internal";
        magic_dns = true;
        nameservers.global = [
          "1.1.1.1"
          "8.8.8.8"
        ];
      };
      # Allow nodes to register without manual approval if using valid keys
      ip_prefixes = [ "100.64.0.0/10" ];
    };
  };

  # Traefik Integration
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
}
