{ config, ... }:

{
  virtualisation.containers.enable = true;
  virtualisation.podman.enable = true;

  systemd.tmpfiles.rules = [
    "d /var/lib/foldingathome 0755 root root -"
  ];

  age.secrets.foldingathome-token = {
    file = ../../secrets/servers/foldingathome-token.age;
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers.foldingathome = {
      image = "lscr.io/linuxserver/foldingathome:latest";

      volumes = [
        "/var/lib/foldingathome:/config:rw"
        "${config.age.secrets.foldingathome-token.path}:/run/secrets/token:ro,Z"
      ];

      environment = {
        TZ = "Etc/UTC";
        MACHINE_NAME = config.networking.hostName;
        FILE__ACCOUNT_TOKEN = "/run/secrets/token";
      };

      ports = [ ];

      autoStart = true;
    };
  };
}
