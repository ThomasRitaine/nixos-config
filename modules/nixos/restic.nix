{ config, lib, ... }:

{
  age.secrets = {
    restic-s3-creds.file = ../../secrets/servers/restic-s3-creds.age;
    restic-s3-endpoint.file = ../../secrets/servers/restic-s3-endpoint.age;
    restic-password.file = ../../secrets/servers/${config.networking.hostName}/restic-password.age;
  };

  services.restic.backups.daily = {
    initialize = true;

    environmentFile = config.age.secrets.restic-s3-creds.path;
    passwordFile = config.age.secrets.restic-password.path;
    repositoryFile = "/run/restic/repo_url";

    backupPrepareCommand = lib.mkBefore ''
      mkdir -p /run/restic
      # Read the endpoint, strip whitespace, append hostname, save to file
      BASE_URL=$(cat ${config.age.secrets.restic-s3-endpoint.path} | xargs)
      echo "s3:''${BASE_URL}/${config.networking.hostName}" > /run/restic/repo_url
    '';

    extraBackupArgs = [
      "--compression max"
    ];

    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];

    timerConfig = {
      OnCalendar = "02:00";
      Persistent = true;
    };
  };
}
