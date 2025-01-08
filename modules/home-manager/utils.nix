{ pkgs, ... }: {
  home.packages = [
    pkgs.tree
    pkgs.onefetch
    pkgs.fastfetch
  ];
}

