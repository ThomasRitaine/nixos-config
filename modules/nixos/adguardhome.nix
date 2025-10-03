{
  services = {
    adguardhome = {
      enable = true;
      openFirewall = true;
      port = 3000;
      allowDHCP = true;
    };
  };
  networking.firewall = {
    allowedTCPPorts = [ 53 3000 67 68 ];
    allowedUDPPorts = [ 53 67 68 ];
  };
}
