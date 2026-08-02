{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.noctalia.homeModules.default
    ./plugins.nix
  ];

  deb.packages = [
    "network-manager"
    "bluez"
    "upower"
    "power-profiles-daemon"
    "brightnessctl"
    "ddcutil"
    "pipewire"
    "wireplumber"
  ];

  programs.noctalia-shell = {
    enable = true;
    settings = { };
  };

  home.packages = with pkgs; [
    nerd-fonts.caskaydia-cove
  ];
  fonts.fontconfig.enable = true;
}
