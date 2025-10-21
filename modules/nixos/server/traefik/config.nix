{ config, lib, ... }:

let
  cfg = config.services.traefik-server;
  moduleDir = ./.;

  staticConfig = import ./static.nix {
    email = cfg.email;
    dynamicConfigDir = "${moduleDir}/dynamic";
  };
in {
  options.services.traefik-server = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Traefik reverse proxy";
    };

    email = lib.mkOption {
      type = lib.types.str;
      default = "thomas.ritaine@outlook.com";
      description = "Email for Let's Encrypt";
    };
  };

  config = lib.mkIf cfg.enable {
    services.traefik = {
      enable = true;
      staticConfigOptions = staticConfig;
    };

    systemd.tmpfiles.rules =
      [ "d /var/lib/traefik/certificates 0755 traefik traefik -" ];

    systemd.services.traefik.serviceConfig.SupplementaryGroups = [ "docker" ];
  };
}
