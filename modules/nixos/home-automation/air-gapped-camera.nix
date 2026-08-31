{
  # ---------------------------------------------------------------------------
  # 1. NETWORK CONFIGURATION FOR enp1s0
  # ---------------------------------------------------------------------------
  networking.networkmanager.unmanaged = [
    "enp1s0"
    "interface-name:enp1s0"
  ];
  networking.firewall.trustedInterfaces = [ "enp1s0" ];

  systemd.network.enable = true;
  systemd.network.wait-online.enable = false;

  systemd.network.networks."10-camera-enp1s0" = {
    matchConfig.Name = "enp1s0";
    address = [ "192.168.20.1/24" ];
    networkConfig = {
      LinkLocalAddressing = "ipv6";
      ConfigureWithoutCarrier = true;
    };
    linkConfig.RequiredForOnline = "no";
  };

  networking.hosts = {
    "192.168.20.50" = [
      "camera-entrance.home.arpa"
      "camera-entrance"
    ];
  };

  # ---------------------------------------------------------------------------
  # 2. ISOLATED DHCP SERVER (dnsmasq)
  # ---------------------------------------------------------------------------
  services.dnsmasq = {
    enable = true;
    settings = {
      port = 0; # Pure DHCP mode
      interface = "enp1s0";
      bind-dynamic = true;

      # Pinned static lease
      dhcp-host = "d0:3b:f4:06:af:a0,192.168.20.50,camera-entrance,24h";
      dhcp-range = [ "192.168.20.50,192.168.20.100,255.255.255.0,24h" ];
      domain = "home.arpa";
      local = "/home.arpa/";

      # Provide standard subnet mask & gateway (point to Mini PC)
      # No WAN access occurs because Mini PC does not route/NAT traffic from enp1s0
      dhcp-option = [
        "option:netmask,255.255.255.0"
        "option:router,192.168.20.1"
        "option:dns-server,192.168.20.1"
      ];
    };
  };

  systemd.services.dnsmasq.after = [
    "network.target"
    "systemd-networkd.service"
  ];
}
