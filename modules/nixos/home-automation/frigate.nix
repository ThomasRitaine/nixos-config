{ config, pkgs, ... }:

{
  age.secrets.frigate-env = {
    file = ../../../secrets/servers/box-office/frigate-env.age;
  };

  systemd.services.frigate.serviceConfig = {
    EnvironmentFile = config.age.secrets.frigate-env.path;
    SupplementaryGroups = [
      "render"
      "video"
    ];
    # Grant PMU access for Intel GPU metrics polling
    AmbientCapabilities = [ "CAP_PERFMON" ];
    CapabilityBoundingSet = [ "CAP_PERFMON" ];
  };
  # Optional: Relax kernel perf event restriction for unprivileged PMU polling
  boot.kernel.sysctl = {
    "kernel.perf_event_paranoid" = 0;
  };

  services.frigate = {
    enable = true;
    hostname = "frigate.local";
    checkConfig = false;
    settings = {
      mqtt = {
        host = "127.0.0.1";
        user = "{FRIGATE_MQTT_USER}";
        password = "{FRIGATE_MQTT_PASSWORD}";
      };
      ffmpeg.hwaccel_args = "preset-vaapi";
      detectors.cpu1 = {
        type = "cpu";
        num_threads = 3;
      };

      cameras.annke_c800 = {
        ffmpeg.inputs = [
          {
            path = "rtsp://{FRIGATE_ANNKE_CAM_USER}:{FRIGATE_ANNKE_CAM_PASSWORD}@192.168.20.50:554/Streaming/Channels/102";
            roles = [ "detect" ];
          }
          {
            path = "rtsp://{FRIGATE_ANNKE_CAM_USER}:{FRIGATE_ANNKE_CAM_PASSWORD}@192.168.20.50:554/Streaming/Channels/101";
            roles = [ "record" ];
          }
        ];
        detect = {
          width = 640;
          height = 360;
          fps = 5;
        };
        objects.track = [
          "person"
        ];
        record = {
          enabled = true;
          retain = {
            days = 3;
            mode = "all";
          };
          events.retain = {
            default = 14;
            mode = "active_objects";
          };
        };
        onvif = {
          host = "192.168.20.50";
          port = 80;
          user = "{FRIGATE_ANNKE_CAM_USER}";
          password = "{FRIGATE_ANNKE_CAM_PASSWORD}";
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    5000
    8554
  ];
}
