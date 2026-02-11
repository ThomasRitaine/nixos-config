{ config, ... }:
{
  age.secrets.beszel-key-and-token = {
    file = ../../secrets/servers/beszel-key-and-token.age;
  };

  services.beszel.agent = {
    enable = true;
    environmentFile = config.age.secrets.beszel-key-and-token.path;
    environment = {
      HUB_URL = "http://vps-8karm.internal:8090";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 45876 ];
  };
}
