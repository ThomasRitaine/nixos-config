{
  config,
  lib,
  pkgs,
  enableAppBackup ? false,
  ...
}:

{
  age.secrets = {
    restic-s3-creds.file = ../../../secrets/servers/restic-s3-creds.age;
    restic-s3-endpoint.file = ../../../secrets/servers/restic-s3-endpoint.age;
    restic-password.file = ../../../secrets/servers/${config.networking.hostName}/restic-password.age;
  };

  services.restic.backups.daily = {
    initialize = true;

    environmentFile = config.age.secrets.restic-s3-creds.path;
    passwordFile = config.age.secrets.restic-password.path;
    repositoryFile = "/run/restic/repo_url";

    paths = lib.mkIf enableAppBackup [
      "/home/app-manager/applications"
    ];

    exclude = lib.mkIf enableAppBackup [
      "*.tar.gz"
      ".git"
    ];

    backupPrepareCommand = lib.mkBefore ''
      mkdir -p /run/restic

      # Construct the full S3 repository URL dynamically using the decrypted endpoint secret
      BASE_URL=$(cat ${config.age.secrets.restic-s3-endpoint.path} | xargs)
      echo "s3:''${BASE_URL}/${config.networking.hostName}" > /run/restic/repo_url

      ${lib.optionalString enableAppBackup ''
        # Generate a dynamic list of directories to ensure new apps are backed up in their own path
        find /home/app-manager/applications -mindepth 1 -maxdepth 1 -type d > /run/restic/dynamic_paths.txt

        # Trigger the SQL dump service synchronously before Restic starts reading the filesystem
        echo "[$(date "+%Y-%m-%d %H:%M:%S")] [INFO] Starting automated SQL export..."
        if ! ${pkgs.systemd}/bin/systemctl start --wait docker-sql-databases-dump.service; then
          echo "[$(date "+%Y-%m-%d %H:%M:%S")] [ERROR] SQL export failed! Proceeding with file-only backup."
        else
          echo "[$(date "+%Y-%m-%d %H:%M:%S")] [INFO] SQL export completed successfully."
        fi
      ''}
    '';

    extraBackupArgs = [
      "--compression max"
      "--exclude-if-present=.nobackup"
    ]
    ++ lib.optional enableAppBackup "--files-from /run/restic/dynamic_paths.txt";

    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];

    timerConfig = {
      OnCalendar = "02:00";
      Persistent = true; # Ensures backup runs at next boot if the machine was off at 02:00
    };
  };

  # Helper service to dump databases from containers into the backup path
  systemd.services.docker-sql-databases-dump = lib.mkIf enableAppBackup {
    description = "Automated SQL Export for Dockerized Databases";

    path = with pkgs; [
      docker
      bash
      coreutils
      findutils
      gnugrep
      procps
    ];

    serviceConfig = {
      Type = "oneshot";
      User = "app-manager";
      ExecStart = "${pkgs.bash}/bin/bash ${./docker-sql-databases-dump.sh}";
      StandardOutput = "journal";
      StandardError = "journal";
    };
  };
}
