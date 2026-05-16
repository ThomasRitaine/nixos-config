{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ cloudflared ];

  users = {
    users.cloudflared = {
      isSystemUser = true;
      group = "cloudflared";
    };
    groups.cloudflared = { };
  };

  age.secrets."cloudflared-tunnel-config" = {
    file = ../../secrets/servers/phoenix86/cloudflared-tunnel-config.age;
    owner = "cloudflared";
    group = "cloudflared";
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      "771c0877-3149-40b3-bd89-7a94aab7b4d9" = {
        credentialsFile = config.age.secrets."cloudflared-tunnel-config".path;
        default = "http_status:404";
        ingress = {
          "phoenix86-thomas.ritaine.com" = {
            service = "https://localhost:443";
            originRequest = { noTLSVerify = true; };
          };
          "ssh-phoenix86-thomas.ritaine.com" = {
            service = "ssh://localhost:22";
          };
        };
      };
    };
  };
}
