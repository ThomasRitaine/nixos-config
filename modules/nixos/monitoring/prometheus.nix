{
  config,
  oracleHosts ? [ ],
  ...
}:

let
  garageTargets = builtins.map (host: "${host}.internal:3903") oracleHosts;
in
{
  systemd.services.prometheus.serviceConfig.LoadCredential = [
    "garage-token:${config.age.secrets.garage-metrics-token.path}"
  ];

  services.prometheus = {
    enable = true;
    port = 9090;
    checkConfig = false;

    scrapeConfigs = [
      {
        job_name = "garage";
        bearer_token_file = "/run/credentials/prometheus.service/garage-token";
        static_configs = [
          {
            targets = [ "${config.networking.hostName}.internal:3903" ] ++ garageTargets;
          }
        ];
      }
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
