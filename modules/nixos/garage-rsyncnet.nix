{
  config,
  lib,
  pkgs,
  ...
}:

lib.mkIf (config.networking.hostName == "orarm") {
  age.secrets = {
    rsyncnet-ssh-key = {
      file = ../../secrets/servers/rsyncnet-ssh-key.age;
      owner = "root";
    };
    rsyncnet-user = {
      file = ../../secrets/servers/rsyncnet-user.age;
    };
  };

  services.garage.settings.data_dir = lib.mkForce "/mnt/garage-rsyncnet-data";

  environment.systemPackages = [
    pkgs.rclone
    pkgs.fuse3
  ];

  systemd.services.rclone-rsyncnet-garage = {
    description = "Rclone VFS Mount for Garage Data";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = pkgs.writeShellScript "rclone-mount" ''
        set -eu
        USER=$(cat ${config.age.secrets.rsyncnet-user.path})
        mkdir -p /mnt/garage-rsyncnet-data /run/rclone

        cat <<EOF > /run/rclone/rclone.conf
        [rsyncnet]
        type = sftp
        host = $USER.rsync.net
        user = $USER
        key_file = ${config.age.secrets.rsyncnet-ssh-key.path}
        use_insecure_cipher = false
        EOF

        exec ${pkgs.rclone}/bin/rclone mount "rsyncnet:garage_data" /mnt/garage-rsyncnet-data \
          --config=/run/rclone/rclone.conf \
          --vfs-cache-mode=full \
          --vfs-cache-max-size=100G \
          --vfs-cache-max-age=48h \
          --allow-other \
          --dir-perms=0700 \
          --file-perms=0600 \
          --no-modtime \
          --no-checksum
      '';
      ExecStop = "${pkgs.util-linux}/bin/umount /mnt/garage-rsyncnet-data";
      Restart = "always";
      RestartSec = "10s";
    };
  };

  systemd.services.garage = {
    after = [ "rclone-rsyncnet-garage.service" ];
    requires = [ "rclone-rsyncnet-garage.service" ];
  };

  systemd.tmpfiles.rules = [
    "d /mnt/garage-rsyncnet-data 0700 root root -"
  ];
}
