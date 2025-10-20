{ pkgs, config, lib, ... }:

let cfg = config.services.application-backup;
in {
  options = {
    services.application-backup = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable application backup service";
      };

      environmentFile = lib.mkOption {
        type = lib.types.path;
        default = "${config.flakePath}/secrets/backup.env";
        description =
          "Path to environment file containing S3_BUCKET_NAME, S3_ENDPOINT, AWS_ACCESS_KEY_ID, and AWS_SECRET_ACCESS_KEY";
      };

      applicationsDir = lib.mkOption {
        type = lib.types.str;
        default = "/home/app-manager/applications";
        description = "Directory containing applications to backup";
      };

      user = lib.mkOption {
        type = lib.types.str;
        default = "app-manager";
        description = "User to run the backup as";
      };

      schedule = lib.mkOption {
        type = lib.types.str;
        default = "02:00";
        description = "When to run backups (systemd timer format)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.application-backup = {
      description = "Backup applications and Docker volumes";
      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        ExecStart = "${pkgs.bash}/bin/bash ${./script.sh}";
        EnvironmentFile = cfg.environmentFile;
        StandardOutput = "append:/var/log/application-backup.log";
        StandardError = "append:/var/log/application-backup.log";
      };
      environment = { APPS_DIR = cfg.applicationsDir; };
      path = with pkgs; [ docker awscli2 jq gnutar gzip coreutils findutils ];
    };

    systemd.timers.application-backup = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = cfg.schedule;
        Persistent = true;
      };
    };
  };
}
