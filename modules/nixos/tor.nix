{ pkgs, ... }:
{
  services.tor = {
    enable = true;
    openFirewall = true;

    relay = {
      enable = true;
      role = "bridge";
    };

    settings = {
      Nickname = "TISSOU";
      ContactInfo = "thomas.ritaine@outlook.com";

      # ORPort is mandatory for relays/bridges.
      # 3001 is a common choice, or stick to your previous 3007.
      ORPort = 3007;

      # Correct structure for ServerTransportPlugin
      ServerTransportPlugin = {
        transports = [ "obfs4" ];
        exec = "${pkgs.obfs4}/bin/lyrebird";
      };

      ServerTransportListenAddr = "obfs4 0.0.0.0:4272";

      # Performance & Sensible Defaults
      BandwidthRate = "50 MB";
      BandwidthBurst = "100 MB";
      MaxAdvertisedBandwidth = "80 MB";

      HardwareAccel = 1;
      NumCPUs = 1;
      AvoidDiskWrites = 1;
      SafeLogging = 1;

      # Networking
      AddressDisableIPv6 = 1;

      # Explicitly Reject Exit traffic
      ExitPolicy = [ "reject *:*" ];
      ExitRelay = false;
      IPv6Exit = false;
    };
  };

  # Backup
  services.restic.backups.daily.paths = [ "/var/lib/tor" ];
}
