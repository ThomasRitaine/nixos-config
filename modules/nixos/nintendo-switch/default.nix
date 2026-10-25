{ lib, pkgs, ... }:

let
  home = "/home/nintendo-switch";
  romDir = "${home}/ROMs/switch";
  addonsDir = "${home}/ROMs/addons";

  # Physical HDMI output that game audio is mirrored to.
  hdmiSink = "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__HDMI1__sink";

  # Stable launcher paths for Pegasus metadata (valid across rebuilds and garbage collection).
  binDir = "/run/current-system/sw/bin";

  # qt-config.ini keys enforced on every Eden launch. Values use Eden's enums.
  edenPinnedSettings = {
    resolution_setup = "3"; # 1x
    gpu_accuracy = "1"; # medium
    accelerate_astc = "1"; # decode ASTC textures on the GPU
    log_filter = ''"*:Warning"'';
  };

  # Eden wrapper: applies the pinned settings, then starts Eden.
  edenTuned = pkgs.writeShellScriptBin "eden" ''
    ${pkgs.python3}/bin/python3 ${./scripts/apply-eden-settings.py} ${
      lib.escapeShellArgs (lib.mapAttrsToList (k: v: "${k}=${v}") edenPinnedSettings)
    } || true
    exec ${pkgs.eden}/bin/eden "$@"
  '';

  # Pegasus with the shutdown, reboot and suspend menu entries hidden.
  pegasusLocked = pkgs.writeShellScriptBin "pegasus-fe" ''
    exec ${pkgs.pegasus-frontend}/bin/pegasus-fe \
      --disable-menu-shutdown \
      --disable-menu-reboot \
      --disable-menu-suspend \
      "$@"
  '';

  # Copies the game-audio sink to the HDMI output once that sink exists.
  # node.dont-fallback stops the loopback from targeting the default sink
  # (game-audio itself) when HDMI is unavailable, which would create a feedback loop.
  gameAudioHdmiMirror = pkgs.writeShellScript "game-audio-hdmi-mirror" ''
    for _ in $(${pkgs.coreutils}/bin/seq 60); do
      if ${pkgs.pulseaudio}/bin/pactl list short sinks 2>/dev/null \
        | ${pkgs.gnugrep}/bin/grep -qF ${lib.escapeShellArg hdmiSink}; then
        break
      fi
      ${pkgs.coreutils}/bin/sleep 2
    done
    exec ${pkgs.pipewire}/bin/pw-loopback \
      --name game-audio-to-hdmi \
      --capture game-audio \
      --playback ${lib.escapeShellArg hdmiSink} \
      --capture-props 'stream.capture.sink=true node.dont-fallback=true' \
      --playback-props 'node.dont-fallback=true'
  '';

  # Pegasus tool launcher: Switch Home Menu
  edenHome = pkgs.writeShellScriptBin "switch-home-menu" ''
    export EDEN_BIN="${edenTuned}/bin/eden"
    exec ${pkgs.bash}/bin/bash ${./scripts/switch-home-menu.sh}
  '';

  # Pegasus tool launcher: Eden settings GUI
  edenGui = pkgs.writeShellScriptBin "eden-settings" ''
    export EDEN_BIN="${edenTuned}/bin/eden"
    exec ${pkgs.bash}/bin/bash ${./scripts/eden-settings.sh}
  '';

  # Controller preset switcher (used by the Pegasus "Controllers" tab and the CLI)
  setSwitchControllers = pkgs.writeShellScriptBin "set-switch-controllers" ''
    set -euo pipefail
    exec ${pkgs.python3}/bin/python3 ${./scripts/set-switch-controllers.py} "$@"
  '';

  # Generates Pegasus metadata files for the ROM directory
  updatePegasusMetadata = pkgs.writeShellScriptBin "update-pegasus-metadata" ''
    set -euo pipefail
    if [ "$(id -u)" -ne 0 ]; then
      exec sudo "$0" "$@"
    fi

    ${pkgs.python3}/bin/python3 ${./scripts/update-pegasus-metadata.py} \
      --rom-dir "${romDir}" \
      --eden-bin "${binDir}/eden" \
      --eden-home-script "${binDir}/switch-home-menu" \
      --eden-gui-script "${binDir}/eden-settings" \
      --set-controllers-bin "${binDir}/set-switch-controllers"

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

  # greetd autologin session: Gamescope + Pegasus
  session = pkgs.writeShellScript "nintendo-switch-session" ''
    export PEGASUS_FE_BIN="${pegasusLocked}/bin/pegasus-fe"
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

  # Deny power management to the kiosk user, whichever client requests it.
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function (action, subject) {
      if (subject.user != "nintendo-switch") {
        return polkit.Result.NOT_HANDLED;
      }

      var login1Actions = ["power-off", "reboot", "halt", "suspend", "hibernate", "set-reboot"];
      for (var i = 0; i < login1Actions.length; i++) {
        if (action.id.indexOf("org.freedesktop.login1." + login1Actions[i]) == 0) {
          return polkit.Result.NO;
        }
      }

      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          /^(poweroff|reboot|halt|kexec|suspend|hibernate)\.target$/.test(String(action.lookup("unit")))) {
        return polkit.Result.NO;
      }

      return polkit.Result.NOT_HANDLED;
    });
  '';

  # GPU acceleration
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

  # Audio: Eden plays to game-audio, which Sunshine streams and the mirror service copies to HDMI.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;

    # Virtual default sink, prioritised over the ALSA HDMI sinks
    extraConfig.pipewire."90-game-audio" = {
      "context.objects" = [
        {
          factory = "adapter";
          args = {
            "factory.name" = "support.null-audio-sink";
            "node.name" = "game-audio";
            "node.description" = "Game Audio (Moonlight)";
            "media.class" = "Audio/Sink";
            "audio.position" = "FL,FR";
            "priority.session" = 1500;
            "priority.driver" = 1500;
          };
        }
      ];
    };
  };

  systemd.user.services.game-audio-hdmi-mirror = {
    description = "Mirror game-audio to the HDMI output";
    wantedBy = [ "default.target" ];
    wants = [ "wireplumber.service" ];
    after = [
      "pipewire.service"
      "pipewire-pulse.service"
      "wireplumber.service"
    ];
    partOf = [ "pipewire.service" ];
    unitConfig.ConditionUser = "nintendo-switch";
    serviceConfig = {
      ExecStart = "${gameAudioHdmiMirror}";
      Restart = "always";
      RestartSec = 5;
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
    edenTuned
    edenHome
    edenGui
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

  # Prioritise the gaming session over background services.
  systemd.slices."user-1100".sliceConfig = {
    CPUWeight = 200;
    MemoryHigh = "13G";
  };

  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="drm", KERNEL=="card[0-9]", ATTR{engine/rcs0/preempt_timeout_ms}="10000"
    ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="2dc8", ATTR{power/control}="on"
    ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="5411", ATTR{power/control}="on"
  '';
}
