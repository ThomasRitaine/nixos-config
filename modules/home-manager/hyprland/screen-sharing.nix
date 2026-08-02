{ pkgs, ... }:
{
  # --- Strict Portal Configuration ---
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "hyprland" ];
        # Fallback to GTK for file saving/opening dialogs
        "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
      };
    };
  };

  # --- Systemd Wrapper ---
  systemd.user.services.xdg-desktop-portal-hyprland = {
    Unit = {
      Description = "Portal service (Hyprland implementation)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      # Hardcodes the execution path for Debian's systemd
      ExecStart = "${pkgs.xdg-desktop-portal-hyprland}/libexec/xdg-desktop-portal-hyprland";
      Slice = "session.slice";
      Type = "dbus";
      BusName = "org.freedesktop.impl.portal.desktop.hyprland";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [
        "xdg-desktop-portal.service"
        "hyprland-session.target"
      ];
    };
  };
}
