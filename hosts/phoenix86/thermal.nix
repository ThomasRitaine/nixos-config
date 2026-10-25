# Thermal and power management for phoenix86 (Dell Inspiron 5402, Tiger Lake).
#
# The firmware enforces a 15 W long-term package power limit through
# intel-rapl-mmio, independently of the ACPI platform profile.
# That limit is intentionally left at its default.
{ pkgs, ... }:
{
  # Exposes /dev/cpu/*/msr for rdmsr in phoenix-telemetry.
  boot.kernelModules = [ "msr" ];

  systemd.services.phoenix-power = {
    description = "Set the ACPI platform profile to performance";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    path = with pkgs; [
      coreutils
      gnugrep
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      f=/sys/firmware/acpi/platform_profile

      # dell_pc may register the profile interface after this unit starts.
      for _ in $(seq 30); do
        if [ -w "$f" ]; then break; fi
        sleep 1
      done

      if grep -qw performance "$f"_choices 2>/dev/null; then
        echo performance > "$f"
      fi
      echo "platform_profile=$(cat "$f" 2>/dev/null || echo missing)"
    '';
  };

  # Logs package temperature, power, throttling, fan and GPU state every 5 s.
  # Usage: journalctl -u phoenix-telemetry -f
  systemd.services.phoenix-telemetry = {
    description = "Thermal, power and throttle telemetry";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    path = with pkgs; [
      coreutils
      gnugrep
      msr-tools
    ];
    serviceConfig = {
      Restart = "always";
      RestartSec = 10;
      Nice = 19;
    };
    script = ''
      rd() { cat "$1" 2>/dev/null || echo NA; }
      num() { case "$1" in "" | *[!0-9]*) return 1 ;; *) return 0 ;; esac; }

      # The GPU, fan and thermal-zone nodes can appear after this unit starts,
      # so detection is retried on every iteration until each one is found.
      find_gpu() {
        for c in /sys/class/drm/card[0-9]; do
          if [ -e "$c/gt_act_freq_mhz" ]; then echo "$c"; return 0; fi
        done
        return 0
      }
      find_smm() {
        for h in /sys/class/hwmon/hwmon*; do
          if [ "$(rd "$h/name")" = dell_smm ]; then echo "$h"; return 0; fi
        done
        return 0
      }
      find_pkg() {
        z=$(grep -lx x86_pkg_temp /sys/class/thermal/thermal_zone*/type 2>/dev/null | head -n1)
        if [ -n "$z" ]; then dirname "$z"; fi
        return 0
      }

      GPU=""
      SMM=""
      PKG=""
      RAPL=/sys/class/powercap/intel-rapl:0/energy_uj
      MMIO=/sys/class/powercap/intel-rapl-mmio:0/constraint_0_power_limit_uw
      THR=/sys/devices/system/cpu/cpu0/thermal_throttle/package_throttle_total_time_ms

      e0=$(rd "$RAPL")
      t0=$(rd "$THR")
      while true; do
        sleep 5
        [ -n "$GPU" ] || GPU=$(find_gpu)
        [ -n "$SMM" ] || SMM=$(find_smm)
        [ -n "$PKG" ] || PKG=$(find_pkg)

        e1=$(rd "$RAPL")
        t1=$(rd "$THR")

        temp=$(rd "$PKG/temp")
        if num "$temp"; then temp=$((temp / 1000)); fi

        # Average package power over the interval, in watts with one decimal.
        w=NA
        if num "$e0" && num "$e1" && [ "$e1" -ge "$e0" ]; then
          d=$(( (e1 - e0) / 500000 ))
          w="$((d / 10)).$((d % 10))"
        fi

        dthr=NA
        if num "$t0" && num "$t1"; then dthr=$((t1 - t0)); fi

        pl1=$(rd "$MMIO")
        if num "$pl1"; then pl1=$((pl1 / 1000000)); fi

        echo "temp_c=$temp pkg_w=$w throttled_ms=$dthr" \
          "fan_rpm=$(rd "$SMM/fan1_input") pwm=$(rd "$SMM/pwm1")" \
          "gpu_act=$(rd "$GPU/gt_act_freq_mhz") gpu_req=$(rd "$GPU/gt_cur_freq_mhz")" \
          "gpu_thr=$(rd "$GPU/gt/gt0/throttle_reason_status") pl4=$(rd "$GPU/gt/gt0/throttle_reason_pl4")" \
          "msr64f=$(rdmsr -p 0 0x64F 2>/dev/null || echo NA) mmio_pl1_w=$pl1" \
          "profile=$(rd /sys/firmware/acpi/platform_profile) load=$(cut -d' ' -f1 /proc/loadavg)"

        e0=$e1
        t0=$t1
      done
    '';
  };
}
