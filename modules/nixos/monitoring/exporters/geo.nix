{ config, pkgs, ... }:
{
  # Enable node_exporter specifically for the textfile collector
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [ "textfile" ];
    extraFlags = [ "--collector.textfile.directory=/var/lib/node_exporter/textfile" ];
  };

  # Create the directory for the textfile collector
  systemd.tmpfiles.rules = [
    "d /var/lib/node_exporter/textfile 0755 node-exporter node-exporter -"
  ];

  # Run a script on boot to fetch the server's geographic location
  systemd.services.generate-geo-metric = {
    description = "Generate GeoIP Prometheus Metric";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    requires = [ "network-online.target" ];
    path = [
      pkgs.curl
      pkgs.jq
    ];
    script = ''
      GEO=$(curl -s "http://ip-api.com/json/?fields=lat,lon,city")

      LAT=$(echo $GEO | jq -r .lat)
      LON=$(echo $GEO | jq -r .lon)
      CITY=$(echo $GEO | jq -r .city)
      HOSTNAME="${config.networking.hostName}"

      # Format as a Prometheus metric and write to the textfile directory
      echo "server_location{hostname=\"$HOSTNAME\",city=\"$CITY\",lat=\"$LAT\",lon=\"$LON\"} 1" > /var/lib/node_exporter/textfile/geo.prom.tmp
      mv /var/lib/node_exporter/textfile/geo.prom.tmp /var/lib/node_exporter/textfile/geo.prom
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
