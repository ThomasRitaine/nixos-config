{ pkgs, lib, ... }:

{
  home.file = {
    # Force default lockscreen theme
    ".config/hypr/hyprlock/theme.conf" = lib.mkForce {
      source =
        "${pkgs.hyde}/Configs/.config/hypr/hyprlock/Arfan on Clouds.conf";
      mutable = true; # Still allows HyDE menu to change it
      force = true;
    };
  };
}
