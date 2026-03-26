{
  config,
  lib,
  oracleHosts ? [ ],
  ...
}:

let
  additionalHosts = [ "phoenix86" ];
  allHosts = lib.unique ([ config.networking.hostName ] ++ additionalHosts ++ oracleHosts);

  garageTargets = builtins.map (host: "${host}.internal:3903") allHosts;
  resticTargets = builtins.map (host: "${host}.internal:9753") allHosts;
  nodeTargets = builtins.map (host: "${host}.internal:9100") allHosts;
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
        job_name = "traefik";
        static_configs = [
          {
            targets = [ "127.0.0.1:8082" ];
          }
        ];
      }
      {
        job_name = "garage";
        bearer_token_file = "/run/credentials/prometheus.service/garage-token";
        static_configs = [
          {
            targets = garageTargets;
          }
        ];
      }
      {
        job_name = "restic";
        static_configs = [
          {
            targets = resticTargets;
          }
        ];
      }
      {
        job_name = "node_exporter";
        static_configs = [
          {
            targets = nodeTargets;
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
