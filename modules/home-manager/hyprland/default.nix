{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      exec-once = [
        "noctalia-shell"
      ];
      input = {
        kb_layout = "fr";
        touchpad = {
          natural_scroll = true;
        };
      };
      gesture = [
        "3, horizontal, workspace"
      ];
      misc = {
        disable_watchdog_warning = true;
      };
    };
  };

  imports = [
    ./keybindings.nix
    ./monitors.nix
    ./theme.nix
    ./userprefs.nix
    ./screen-sharing.nix
  ];
}
