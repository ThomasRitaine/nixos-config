{ lib, ... }:
{
  services.traefik = {
    enable = true;
    staticConfigOptions = import ./static.nix {
      email = "thomas.ritaine@outlook.com";
    };
  };

  # Copy files from 'dynamic' folder to /etc/traefik/dynamic
  environment.etc = lib.mapAttrs' (name: _: {
    name = "traefik/dynamic/${name}";
    value = {
      source = ./dynamic/${name};
    };
  }) (builtins.readDir ./dynamic);

  systemd.tmpfiles.rules = [
    "d /var/lib/traefik/certificates 0755 traefik traefik -"
  ];

  systemd.services.traefik.serviceConfig.SupplementaryGroups = [ "docker" ];

  # Backup
  services.restic.backups.daily.paths = [ "/var/lib/traefik" ];
}
