{ pkgs, ... }:

let
  # EDID captured from the attached Philips 242E1GJ monitor.
  # Forcing it on HDMI-A-1 keeps the connector enabled when nothing is plugged in
  # (headless KMS capture for Gamescope and Sunshine) and exposes the monitor's
  # audio capabilities when it is connected.
  monitorEdid = pkgs.runCommand "edid-monitor" { } ''
    install -Dm444 ${./edid/monitor.bin} $out/lib/firmware/edid/monitor.bin
  '';
in
{
  hardware.display = {
    edid.packages = [ monitorEdid ];
    outputs."HDMI-A-1" = {
      edid = "monitor.bin";
      mode = "1920x1080@60e"; # 'e' forces the connector on
    };
  };

  # Sunshine: captures the screen and streams it to Moonlight
  services.sunshine = {
    enable = true;
    autoStart = true; # binds to graphical-session.target
    capSysAdmin = true; # required for KMS capture
    openFirewall = false;
    settings = {
      audio_sink = "game-audio";
      capture = "kms";
      encoder = "vaapi"; # hardware encoding on the Iris Xe
      adapter_name = "/dev/dri/renderD128";
      gamepad = "xone"; # Xbox One virtual pad (not grabbed by joycond)
      back_button_timeout = 1000; # hold Select (-) for 1 s to emulate the Home button
    };
  };

  # Required for autoStart under greetd + Gamescope
  systemd.user.services.sunshine.unitConfig.ConditionUser = "nintendo-switch";
  systemd.user.targets.graphical-session.wantedBy = [ "default.target" ];

  # Lets Moonlight touch, keyboard and gamepad input act as real devices
  hardware.uinput.enable = true;
  users.users.nintendo-switch.extraGroups = [ "uinput" ];

  # Swap A/B and X/Y on the Sunshine virtual pad only, so Moonlight's
  # Switch-style on-screen layout matches the physical 8BitDo buttons.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="Sunshine X-Box One (virtual) pad", TAG+="systemd", ENV{SYSTEMD_WANTS}="sunshine-pad-remap@$kernel.service"
  '';

  systemd.services."sunshine-pad-remap@" = {
    description = "Swap A/B and X/Y on the Sunshine virtual gamepad (%I)";
    serviceConfig = {
      Type = "simple";
      # Restrict the raw device to root so Eden/SDL neither opens it nor sees a duplicate controller
      ExecStartPre = "${pkgs.coreutils}/bin/chmod 0600 /dev/input/%I";
      ExecStart = ''
        ${pkgs.evsieve}/bin/evsieve \
          --input /dev/input/%I grab \
          --map btn:south btn:east yield \
          --map btn:east btn:south yield \
          --map btn:north btn:west yield \
          --map btn:west btn:north yield \
          --output name="Sunshine Moonlight Switch Pad"
      '';
    };
  };

  # Sunshine ports, reachable over Tailscale only
  networking.firewall.interfaces."tailscale0" = {
    allowedTCPPorts = [
      47984 # HTTPS API
      47989 # HTTP API
      47990 # Web UI
      48010 # RTSP
    ];
    allowedUDPPorts = [
      47998 # Video
      47999 # Control / input
      48000 # Audio
      48010 # RTSP fallback
    ];
  };
}
