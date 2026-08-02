{
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "[workspace 1 silent] env XDG_CURRENT_DESKTOP=GNOME google-chrome-stable --app=https://mail.google.com"
      "[workspace 2 silent] kitty"
      "[workspace 3 silent] env XDG_CURRENT_DESKTOP=GNOME google-chrome-stable"
    ];
  };
}
