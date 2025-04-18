{ pkgs, ... }: {
  home.packages = with pkgs; [ jq tree onefetch fastfetch repomix btop ];
}
