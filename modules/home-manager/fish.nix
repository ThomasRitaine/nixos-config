{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # Disable greeting
      set -g fish_greeting

      if not set -q TMUX
        fastfetch
      end
    '';

    shellAliases = {
      l = "ls -lAFh";
      dc = "docker compose";
      md = "mkdir -p";
    };

    shellAbbrs = { };
  };
}
