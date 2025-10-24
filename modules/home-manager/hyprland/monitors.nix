{
  hydenix.hm.hyprland.monitors = {
    enable = true;
    overrideConfig = ''
      monitor = HDMI-A-1, 1920x1080@60, 0x0, 1.20
      monitor = eDP-1, 1920x1080@60, 160x900, 1.5

      workspace = HDMI-A-1, 2
      workspace = eDP-1, 1
    '';
  };
}
