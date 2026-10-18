{ pkgs, ... }:

{
  # Virtual 1080p60 EDID on HDMI-A-1:
  # - Unplugged: forces HDMI-A-1 "connected" so gamescope & Sunshine KMS work headlessly.
  # - Plugged in: drives standard 1080p60 CEA timings out of the physical HDMI port to the monitor.
  hardware.display = {
    edid.modelines."fake-1080p" = "148.50  1920 2008 2052 2200  1080 1084 1089 1125  +hsync +vsync";
    outputs."HDMI-A-1" = {
      edid = "fake-1080p.bin";
      mode = "1920x1080@60e"; # 'e' forces connector enabled; matches modeline resolution & refresh
    };
  };

  # Sunshine: captures the screen and streams it to Moonlight
  services.sunshine = {
    enable = true;
    autoStart = true; # explicit default: binds to graphical-session.target
    capSysAdmin = true; # needed for KMS screen capture
    openFirewall = false;
    settings = {
      capture = "kms";
      encoder = "vaapi"; # encode on the Iris Xe, not the CPU
      adapter_name = "/dev/dri/renderD128";
      gamepad = "xone"; # Xbox One virtual pad (not grabbed by joycond)
      back_button_timeout = 1000; # hold Select (-) for 1s to emulate the Home button
    };
  };

  # Required for autoStart under greetd + gamescope:
  systemd.user.services.sunshine.unitConfig.ConditionUser = "nintendo-switch";
  systemd.user.targets.graphical-session.wantedBy = [ "default.target" ];

  # Lets Moonlight's touch, keyboard and gamepad act as real inputs
  hardware.uinput.enable = true;
  users.users.nintendo-switch.extraGroups = [ "uinput" ];

  # Swap A<->B and X<->Y ONLY on "Sunshine X-Box One (virtual) pad" so Moonlight's
  # Switch-style on-screen layout matches the physical 8BitDo Pro 3 buttons:
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="Sunshine X-Box One (virtual) pad", TAG+="systemd", ENV{SYSTEMD_WANTS}="sunshine-pad-remap@$kernel.service"
  '';

  systemd.services."sunshine-pad-remap@" = {
    description = "Swap A/B and X/Y buttons strictly for Sunshine virtual gamepad (%I)";
    serviceConfig = {
      Type = "simple";
      # Lock raw device to root-only (0600) so SDL3/Eden cannot open it for rumble ioctls
      # and Pegasus/Eden don't see duplicate controllers:
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

  # Open Sunshine's ports on Tailscale only, not on your home network
  networking.firewall.interfaces."tailscale0" = {
    allowedTCPPorts = [
      47984 # HTTPS API (app list, PIN verification, launch)
      47989 # HTTP API (discovery, handshake)
      47990 # Web UI (admin setup, PIN entry)
      48010 # RTSP stream handshake
    ];
    allowedUDPPorts = [
      47998 # Video
      47999 # Control/Input
      48000 # Audio
      48010 # RTSP stream handshake fallback
    ];
  };
}
