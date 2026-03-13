{
  traefikEnable ? false,
  domain ? "s3.thomas.ritaine.com",
}:
{
  config,
  pkgs,
  lib,
  ...
}:
{
  age.secrets.garage-rpc-secret = {
    file = ../../secrets/servers/garage-rpc-secret.age;
    owner = "garage";
    group = "garage";
  };

  age.secrets.garage-bootstrap-peers = {
    file = ../../secrets/servers/garage-bootstrap-peers.age;
    owner = "garage";
    group = "garage";
  };

  age.secrets.garage-metrics-token = {
    file = ../../secrets/servers/garage-metrics-token.age;
    owner = "garage";
    group = "garage";
  };

  users.users.garage = {
    isSystemUser = true;
    group = "garage";
    description = "Garage Object Storage User";
  };
  users.groups.garage = { };

  services.garage = {
    enable = true;
    package = pkgs.garage_2;

    settings = {
      metadata_dir = "/var/lib/garage/meta";
      data_dir = "/var/lib/garage/data";
      db_engine = "sqlite";

      replication_factor = 2;
      consistency_mode = "consistent";
      compression_level = 1;

      # RPC (Inter-node communication)
      rpc_bind_addr = "[::]:3901";
      rpc_public_addr = "${config.networking.hostName}.internal:3901";
      rpc_secret_file = config.age.secrets.garage-rpc-secret.path;

      # S3 API
      s3_api = {
        s3_region = "eu-west-1";
        api_bind_addr = "[::]:3900";
        root_domain = ".${domain}";
      };

      # Web Static Hosting
      s3_web = {
        bind_addr = "[::]:3902";
        root_domain = ".web.${domain}";
        add_host_to_metrics = false;
      };

      # Admin API
      admin = {
        api_bind_addr = "[::]:3903";
      };
    };
  };

  systemd.services.garage.environment = {
    GARAGE_METRICS_TOKEN_FILE = config.age.secrets.garage-metrics-token.path;
  };

  systemd.services.garage.serviceConfig = {
    DynamicUser = false;
    Restart = "always";
    RestartSec = "5s";
  };

  # Automatically register the node to the cluster with 175GB capacity
  systemd.services.garage-auto-provision = {
    description = "Garage Capacity Assignment";
    wantedBy = [ "multi-user.target" ];
    after = [ "garage.service" ];
    requires = [ "garage.service" ];
    path = [
      pkgs.gawk
      pkgs.gnugrep
      config.services.garage.package
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      GARAGE_BIN="${config.services.garage.package}/bin/garage"
      sleep 10

      if [ "${config.networking.hostName}" != "vps-8karm" ]; then
        $GARAGE_BIN node connect $(cat ${config.age.secrets.garage-bootstrap-peers.path}) || true
      fi

      LOCAL_NODE_ID=$($GARAGE_BIN status | grep "${config.networking.hostName}" | awk '{print $1}')

      if [ -n "$LOCAL_NODE_ID" ]; then
        # Stage the 175GB capacity limit and assign a default zone
        $GARAGE_BIN layout assign -c 175G -z default "$LOCAL_NODE_ID" || true
      fi
    '';
  };

  # Open RPC and Admin ports.
  # API ports are accessed via Traefik (localhost) or Tailscale (internal)
  networking.firewall.allowedTCPPorts = [
    3901
    3903
  ];

  # Traefik exposing
  environment.etc."traefik/dynamic/garage.yml" = lib.mkIf traefikEnable {
    text = ''
      http:
        routers:
          garage-s3-api:
            rule: "Host(`${domain}`) || HostRegexp(`{bucket:.+}.${domain}`)"
            entryPoints:
              - "websecure"
            service: "garage-s3-api"

          garage-s3-web:
            rule: "Host(`web.${domain}`) || HostRegexp(`{bucket:.+}.web.${domain}`)"
            entryPoints:
              - "websecure"
            service: "garage-s3-web"

        services:
          garage-s3-api:
            loadBalancer:
              servers:
                - url: "http://127.0.0.1:3900"

          garage-s3-web:
            loadBalancer:
              servers:
                - url: "http://127.0.0.1:3902"
    '';
  };

  # Backup
  services.restic.backups.daily.paths = [ "/var/lib/garage/meta" ];
}
