{
  isHeadscaleServer ? false,
  bypassHeadscaleDns ? isHeadscaleServer,
  useStaticFallbackDns ? isHeadscaleServer,
  tags ? [ "tag:server" ],
}:
{ config, lib, ... }:

{
  age.secrets.tailscale-token = {
    file = ../../secrets/servers/tailscale-token.age;
  };

  networking.nameservers = lib.mkIf useStaticFallbackDns [
    "1.1.1.1"
    "8.8.8.8"
  ];

  services.tailscale = {
    enable = true;

    authKeyFile = config.age.secrets.tailscale-token.path;

    extraUpFlags = [
      "--login-server=https://vpn.thomas.ritaine.com"
      "--advertise-exit-node"
      "--accept-routes"
      "--accept-dns=${if bypassHeadscaleDns then "false" else "true"}"
    ]
    ++ lib.optionals (tags != [ ]) [
      "--advertise-tags=${lib.concatStringsSep "," tags}"
    ];

    useRoutingFeatures = "both";
  };

  networking.firewall = {
    checkReversePath = "loose";
    allowedUDPPorts = [ 41641 ];
    trustedInterfaces = [ "tailscale0" ];
  };

  services.resolved.enable = true;

  services.restic.backups.daily.paths = [ "/var/lib/tailscale" ];
}
