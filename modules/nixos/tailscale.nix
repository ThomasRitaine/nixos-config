{ config, ... }:

{
  age.secrets.tailscale-token = {
    file = ../../secrets/servers/tailscale-token.age;
  };

  services.tailscale = {
    enable = true;

    authKeyFile = config.age.secrets.tailscale-token.path;

    extraUpFlags = [
      "--login-server=https://vpn.thomas.ritaine.com"
      "--advertise-exit-node"
      "--accept-routes" # Accept routes advertised by other nodes
      "--accept-dns=true" # Accept DNS settings from Headscale
    ];

    useRoutingFeatures = "both";
  };

  networking.firewall = {
    checkReversePath = "loose";
    allowedUDPPorts = [ 41641 ];
    trustedInterfaces = [ "tailscale0" ];
  };

  # Tailscale's MagicDNS requires systemd-resolved on NixOS
  services.resolved.enable = true;
}
