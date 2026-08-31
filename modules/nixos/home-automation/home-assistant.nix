{ config, pkgs, ... }:

{
  # ---------------------------------------------------------------------------
  # 1. Z-WAVE JS CONFIGURATION
  # ---------------------------------------------------------------------------
  users.users.zwave-js = {
    isSystemUser = true;
    group = "zwave-js";
  };
  users.groups.zwave-js = { };

  age.secrets.zwave-secrets = {
    file = ../../../secrets/servers/box-office/zwave-secrets.age;
    owner = "zwave-js";
    group = "zwave-js";
    mode = "0400";
  };

  services.zwave-js = {
    enable = true;
    serialPort = "/dev/serial/by-id/usb-Zooz_800_Z-Wave_Stick_533D004242-if00";
    secretsConfigFile = config.age.secrets.zwave-secrets.path;
  };

  # ---------------------------------------------------------------------------
  # 2. MOSQUITTO MQTT BROKER
  # ---------------------------------------------------------------------------
  age.secrets.mqtt-password = {
    file = ../../../secrets/servers/box-office/mqtt-password.age;
    mode = "0400";
  };

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        acl = [ "pattern readwrite #" ];
        omitPasswordAuth = false;
        settings.allow_anonymous = false;
        users.hass = {
          acl = [ "readwrite #" ];
          passwordFile = config.age.secrets.mqtt-password.path;
        };
      }
    ];
  };

  # ---------------------------------------------------------------------------
  # 3. HOME ASSISTANT CORE & FRIGATE INTEGRATION
  # ---------------------------------------------------------------------------
  age.secrets.ha-secrets = {
    file = ../../../secrets/servers/box-office/ha-secrets.age;
    path = "/var/lib/hass/secrets.yaml";
    owner = "hass";
    group = "hass";
    mode = "0400";
  };

  services.home-assistant = {
    enable = true;

    customComponents = [
      pkgs.home-assistant-custom-components.frigate
    ];

    config = {
      homeassistant = {
        name = "!secret home_name";
        latitude = "!secret home_latitude";
        longitude = "!secret home_longitude";
        time_zone = "!secret home_timezone";
        unit_system = "metric";
        temperature_unit = "C";
      };
      http = {
        use_x_forwarded_for = true;
        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];
      };
    };

    extraPackages = python3Packages: [
      pkgs.ffmpeg
    ];

    extraComponents = [
      "default_config"
      "met"
      "zwave_js"
      "mqtt"
      "stream"
      "onvif"
      "ffmpeg"
    ];
  };

  systemd.services.home-assistant.serviceConfig.SupplementaryGroups = [ "dialout" ];

  # ---------------------------------------------------------------------------
  # 4. FIREWALL & BACKUPS
  # ---------------------------------------------------------------------------
  networking.firewall.allowedTCPPorts = [
    8123 # Home Assistant Web UI
    1883 # Mosquitto MQTT
    3000 # Z-Wave JS WebSocket
  ];

  networking.firewall.allowedUDPPorts = [
    3702 # ONVIF WS-Discovery
    5353 # mDNS / Zeroconf
  ];

  services.restic.backups.daily.paths = [
    "/var/lib/hass"
    "/var/lib/zwave-js"
  ];
}
