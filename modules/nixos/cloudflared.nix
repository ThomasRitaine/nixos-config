{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ cloudflared ];

  services.cloudflared = {
    enable = true;
    tunnels = {
      "21b52d0a-924c-4955-a10a-109eb3926a41" = {
        credentialsFile = "/etc/nixos/secrets/cloudflare-tunnel-token.txt";
        default = "http_status:404";
      };
    };
  };
}
