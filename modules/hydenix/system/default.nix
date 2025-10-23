{ ... }:

{
  imports = [
    # ./example.nix - add your modules here
  ];

  environment.systemPackages = [
    # pkgs.vscode - hydenix's vscode version
    # pkgs.userPkgs.vscode - your personal nixpkgs version
  ];

  programs.fish.enable = true;

  hydenix.gaming.enable = false;

  console.keyMap = "fr";
  services.xserver.xkb.layout = "fr";
}
