{ pkgs, ... }:

let
  home = "/home/nintendo-switch";
  romDir = "${home}/ROMs/switch";
  addonsDir = "${home}/ROMs/addons";
  hdmiSink = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__HDMI1__sink";

  # Pegasus tool launcher: Switch Home Menu
  edenHome = pkgs.writeShellScript "switch-home-menu" ''
    export EDEN_BIN="${pkgs.eden}/bin/eden"
    exec ${pkgs.bash}/bin/bash ${./scripts/switch-home-menu.sh}
  '';

  # Pegasus tool launcher: Eden settings GUI
  edenGui = pkgs.writeShellScript "eden-settings" ''
    export EDEN_BIN="${pkgs.eden}/bin/eden"
    exec ${pkgs.bash}/bin/bash ${./scripts/eden-settings.sh}
  '';

  # Controller preset switcher (used by Pegasus "Controllers" tab and CLI)
  setSwitchControllers = pkgs.writeShellScriptBin "set-switch-controllers" ''
    set -euo pipefail
    exec ${pkgs.python3}/bin/python3 ${./scripts/set-switch-controllers.py} "$@"
  '';

  # Metadata generator: wraps the external Python script with Nix store paths
  updatePegasusMetadata = pkgs.writeShellScriptBin "update-pegasus-metadata" ''
    set -euo pipefail
    if [ "$(id -u)" -ne 0 ]; then
      exec sudo "$0" "$@"
    fi

    ${pkgs.python3}/bin/python3 ${./scripts/update-pegasus-metadata.py} \
      --rom-dir "${romDir}" \
      --eden-bin "${pkgs.eden}/bin/eden" \
      --eden-home-script "${edenHome}" \
      --eden-gui-script "${edenGui}" \
      --set-controllers-bin "${setSwitchControllers}/bin/set-switch-controllers"

    chown -R nintendo-switch:users "${home}/ROMs"
  '';

  # CLI helper: import-switch-games
  importSwitchGames = pkgs.writeShellScriptBin "import-switch-games" ''
    set -euo pipefail
    export ROM_DIR="${romDir}"
    export ADDONS_DIR="${addonsDir}"
    export UPDATE_METADATA_BIN="${updatePegasusMetadata}/bin/update-pegasus-metadata"
    export FIND_BIN="${pkgs.findutils}/bin/find"

    exec ${pkgs.bash}/bin/bash ${./scripts/import-switch-games.sh} "$@"
  '';

  # Greetd autologin session
  session = pkgs.writeShellScript "nintendo-switch-session" ''
    export PEGASUS_FE_BIN="${pkgs.pegasus-frontend}/bin/pegasus-fe"
    exec ${pkgs.bash}/bin/bash ${./scripts/session.sh}
  '';

  pegasusGameDirs = pkgs.writeText "game_dirs.txt" ''
    ${romDir}
  '';
in
{
  imports = [
    ./sunshine.nix
  ];

  users.users.nintendo-switch = {
    isNormalUser = true;
    uid = 1100;
    extraGroups = [
      "video"
      "render"
      "input"
      "audio"
    ];
  };

  # GPU Acceleration
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  # Autologin session: Gamescope + Pegasus
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        user = "nintendo-switch";
        command = "${session}";
      };
      default_session = {
        user = "nintendo-switch";
        command = "${session}";
      };
    };
  };
  systemd.services.greetd.unitConfig.StartLimitIntervalSec = 0;

  # Directories and Pegasus config files
  systemd.tmpfiles.settings."10-pegasus" = {
    "${home}/.config".d = {
      user = "nintendo-switch";
      group = "users";
      mode = "0755";
    };
    "${home}/.config/pegasus-frontend".d = {
      user = "nintendo-switch";
      group = "users";
      mode = "0755";
    };
    "${home}/.config/pegasus-frontend/game_dirs.txt"."L+".argument = "${pegasusGameDirs}";
    "${home}/ROMs".d = {
      user = "nintendo-switch";
      group = "users";
      mode = "0755";
    };
    "${romDir}".d = {
      user = "nintendo-switch";
      group = "users";
      mode = "0755";
    };
    "${addonsDir}".d = {
      user = "nintendo-switch";
      group = "users";
      mode = "0755";
    };
  };

  # Audio routing: HDMI priority
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.extraConfig = {
      "51-hdmi-default" = {
        "monitor.alsa.rules" = [
          {
            matches = [ { "node.name" = hdmiSink; } ];
            actions.update-props = {
              "priority.session" = 2000;
              "priority.driver" = 2000;
            };
          }
        ];
      };
      "52-no-restore" = {
        "wireplumber.settings" = {
          "node.restore-default-targets" = false;
          "node.stream.restore-target" = false;
        };
      };
    };
  };

  # Controller and Bluetooth support
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.FastConnectable = true;
  };

  services.joycond.enable = true;
  services.udev.packages = [
    pkgs.game-devices-udev-rules
    pkgs.eden
  ];

  environment.systemPackages = with pkgs; [
    eden
    pegasus-frontend
    updatePegasusMetadata
    importSwitchGames
    setSwitchControllers
    pulseaudio
    alsa-utils
    usbutils
    evtest
  ];

  programs.bash.interactiveShellInit = ''
    ns() { sudo -u nintendo-switch XDG_RUNTIME_DIR=/run/user/1100 "$@"; }
  '';

  systemd.slices."user-1100".sliceConfig = {
    CPUWeight = 80;
    MemoryHigh = "8G";
  };

  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="drm", KERNEL=="card[0-9]", ATTR{engine/rcs0/preempt_timeout_ms}="10000"
    ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="2dc8", ATTR{power/control}="on"
    ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="5411", ATTR{power/control}="on"
  '';
}
