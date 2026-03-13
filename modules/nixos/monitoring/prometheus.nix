{
  config,
  ...
}:
{
  services.prometheus = {
    enable = true;
    port = 9090;
    checkConfig = false;

    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          {
            targets = [ "127.0.0.1:${toString config.services.prometheus.port}" ];
          }
        ];
      }
    ];
  };

  services.restic.backups.daily.paths = [ "/var/lib/prometheus2" ];
}
