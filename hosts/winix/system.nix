{ ... }:

{
  imports = [ ../../modules/nixos/docker.nix ];

  environment.systemPackages = [ ];

  programs.fish.enable = true;

  hydenix.gaming.enable = false;

  console.keyMap = "fr";
  services.xserver.xkb.layout = "fr";
}
