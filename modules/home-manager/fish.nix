{ lib, ... }:

{
  programs.fish = {

    interactiveShellInit = lib.mkAfter ''
      set -gx EDITOR nvim
    '';

    shellAliases = { dc = "docker compose"; };
  };
}
