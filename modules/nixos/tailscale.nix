{
  isHeadscaleServer ? false,
  # Runs this node with --accept-dns=false: tailscaled leaves the OS DNS alone.
  # The tailnet DNS delegate below is enabled together with it, so *.internal
  # names keep resolving. Never split the two.
  bypassHeadscaleDns ? isHeadscaleServer,
  useStaticFallbackDns ? isHeadscaleServer,
  tags ? [ "tag:server" ],
  # MagicDNS suffix. Must match dns.base_domain in headscale.nix (asserted there).
  tailnetDomain ? "internal",
}:
{ config, lib, ... }:

let
  tailnetDelegate = "systemd/dns-delegate.d/tailnet.dns-delegate";
in
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

  # With --accept-dns=false, tailscaled configures no DNS on tailscale0, so
  # *.internal would go to the regular resolvers, and public ones answer
  # NXDOMAIN. This delegate sends only *.internal to tailscaled's local
  # resolver, which answers tailnet names even with --accept-dns=false (it
  # forwards nothing else). Every other query keeps using the host resolvers.
  # Docker containers benefit too: the embedded DNS forwards to 127.0.0.53.
  # Requires systemd >= 258, see systemd.dns-delegate(5). "~" makes the domain
  # routing-only (no search domain), and DefaultRoute is off by default, so
  # this scope never receives queries for any other domain.
  environment.etc.${tailnetDelegate} = lib.mkIf bypassHeadscaleDns {
    text = ''
      [Delegate]
      DNS=100.100.100.100
      Domains=~${tailnetDomain}
    '';
  };

  # systemd-resolved reads delegate files at startup
  systemd.services.systemd-resolved.restartTriggers = lib.mkIf bypassHeadscaleDns [
    config.environment.etc.${tailnetDelegate}.source
  ];

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
