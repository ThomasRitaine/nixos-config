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

    # Used at first login (when the node needs to log in)
    extraUpFlags = [
      "--reset"
      "--login-server=https://vpn.thomas.ritaine.com"
      "--advertise-exit-node"
      "--accept-routes"
      "--accept-dns=${if bypassHeadscaleDns then "false" else "true"}"
    ]
    ++ lib.optionals (tags != [ ]) [
      "--advertise-tags=${lib.concatStringsSep "," tags}"
    ];

    # Reapplied on every activation via `tailscale set`, so later changes take effect
    extraSetFlags = [
      "--advertise-exit-node"
      "--accept-routes"
      "--accept-dns=${if bypassHeadscaleDns then "false" else "true"}"
    ];

    useRoutingFeatures = "both";
  };

  # Restart even after a clean exit (code 0), and never give up
  systemd.services.tailscaled = {
    serviceConfig = {
      Restart = lib.mkForce "always";
      RestartSec = "5s";
    };
    startLimitIntervalSec = 0;
    after = lib.mkIf isHeadscaleServer [ "headscale.service" ];
    wants = lib.mkIf isHeadscaleServer [ "headscale.service" ];
  };

  # More buffer for bursts of network events (container churn)
  boot.kernel.sysctl = {
    "net.core.rmem_default" = 2097152; # 2 MB
    "net.core.rmem_max" = 16777216; # 16 MB
  };

  networking.firewall = {
    checkReversePath = "loose";
    allowedUDPPorts = [ 41641 ];
    trustedInterfaces = [ "tailscale0" ];
  };

  services.resolved.enable = true;

  services.restic.backups.daily.paths = [ "/var/lib/tailscale" ];
}
