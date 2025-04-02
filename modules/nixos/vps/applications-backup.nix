{ pkgs, ... }: {
  systemd.services.backup = {
    description = "Run the backup script for app-manager";
    serviceConfig = {
      Type = "oneshot";
      User = "app-manager";
      ExecStart =
        "${pkgs.zsh}/bin/zsh /home/app-manager/server-config/backup/cron_backup.sh";
      StandardOutput =
        "append:/home/app-manager/server-config/backup/logs/cron_run.log";
      StandardError =
        "append:/home/app-manager/server-config/backup/logs/cron_run.log";
    };
  };

  systemd.timers.backup = {
    wantedBy = [ "timers.target" ];
    timerConfig = { OnCalendar = "02:00"; };
  };
}
