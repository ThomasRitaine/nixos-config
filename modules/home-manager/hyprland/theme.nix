{
  pkgs,
  ...
}:

{
  wayland.windowManager.hyprland.settings = {
    general = {
      gaps_in = 3;
      gaps_out = 8;
      border_size = 2;
      "col.active_border" = "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
      "col.inactive_border" = "rgba(b4befecc) rgba(6c7086cc) 45deg";
      layout = "dwindle";
      resize_on_border = true;
    };

    decoration = {
      rounding = 10;

      blur = {
        enabled = true;
        size = 6;
        passes = 3;
        new_optimizations = true;
        ignore_opacity = true;
        xray = false;
      };
    };

    animations = {
      enabled = true;
      bezier = [
        "linear, 0, 0, 1, 1"
        "md3_standard, 0.2, 0, 0, 1"
        "md3_decel, 0.05, 0.7, 0.1, 1"
        "md3_accel, 0.3, 0, 0.8, 0.15"
        "overshot, 0.05, 0.9, 0.1, 1.1"
        "crazyshot, 0.1, 1.5, 0.76, 0.92"
        "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
        "fluent_decel, 0.1, 1, 0, 1"
        "easeInOutCirc, 0.85, 0, 0.15, 1"
        "easeOutCirc, 0, 0.55, 0.45, 1"
        "easeOutExpo, 0.16, 1, 0.3, 1"
      ];
      animation = [
        "windows, 1, 3, md3_decel, popin 60%"
        "border, 1, 10, default"
        "fade, 1, 2.5, md3_decel"
        "workspaces, 1, 3.5, easeOutExpo, slide"
        "specialWorkspace, 1, 3, md3_decel, slidevert"
      ];
    };

    env = [
      "XCURSOR_THEME,Bibata-Modern-Ice"
      "XCURSOR_SIZE,24"
    ];
  };

  home.pointerCursor = {
    name = "Bibata-Modern-Ice";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };
}
