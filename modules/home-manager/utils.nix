{ pkgs, ... }: {
  home.packages = with pkgs; [
    jq
    yq
    tree
    fastfetch
    repomix
    btop
    nodejs_22
    cargo
    gcc
    unzip
    aichat
  ];
}
