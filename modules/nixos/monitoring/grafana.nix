{ config, lib, ... }:

let
  domain = "grafana.thomas.ritaine.com";
  serversDomain = "servers.thomas.ritaine.com";
  serversPublicDashboardUid = "51f620a731704f52bb48d17680def9be";
in
{
  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        inherit domain;
        root_url = "https://${domain}/";
      };
    };

    provision = {
      enable = true;

      datasources.settings.datasources = [
        {
          name = "Prometheus Data";
          type = "prometheus";
          uid = "prometheus-ds-primary";
          access = "proxy";
          url = "http://127.0.0.1:${toString config.services.prometheus.port}";
          isDefault = true;
          editable = false;
        }
      ];

      dashboards.settings.providers = [
        {
          name = "Local Provisioned Dashboards";
          disableDeletion = true;
          options = {
            path = "/etc/grafana-dashboards";
            foldersFromFilesStructure = false;
          };
        }
      ];
    };
  };

  environment.etc =
    lib.mapAttrs' (name: _: {
      name = "grafana-dashboards/${name}";
      value = {
        source = ./dashboards/${name};
      };
    }) (builtins.readDir ./dashboards)
    // {
      "traefik/dynamic/grafana.yml".text = ''
        http:
          middlewares:
            grafana-redirect-server-map-dashboard:
              redirectRegex:
                regex: "^https?://${serversDomain}/.*"
                replacement: "https://${domain}/public-dashboards/${serversPublicDashboardUid}"

          routers:
            grafana:
              rule: "Host(`${domain}`)"
              service: "grafana"

            grafana-redirect-server-map-dashboard:
              rule: "Host(`${serversDomain}`)"
              middlewares:
                - grafana-redirect-server-map-dashboard
              service: "grafana"

          services:
            grafana:
              loadBalancer:
                servers:
                  - url: "http://127.0.0.1:3000"
      '';
    };

  services.restic.backups.daily.paths = [ "/var/lib/grafana" ];
}
