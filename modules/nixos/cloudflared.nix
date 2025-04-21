{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ cloudflared ];

  services.cloudflared = {
    enable = true;
    tunnels = {
      "771c0877-3149-40b3-bd89-7a94aab7b4d9" = {
        credentialsFile =
          "/etc/nixos/secrets/771c0877-3149-40b3-bd89-7a94aab7b4d9.json";
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
