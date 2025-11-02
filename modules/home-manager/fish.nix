{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # Disable greeting
      set -g fish_greeting

      fastfetch --logo-type kitty-icat
    '';

    shellAliases = {
      l = "ls -lAFh";
      dc = "docker compose";
      md = "mkdir -p";
    };

    shellAbbrs = { };
  };
}
