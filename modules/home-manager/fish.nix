{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      # Disable greeting
      set -g fish_greeting

      # Auto attach tmux session on interactive shell
      status is-interactive; and not set -q TMUX; and tmux a
    '';

    shellAliases = {
      l = "ls -lAFh";
      dc = "docker compose";
      md = "mkdir -p";
      c = "clear";
    };

    shellAbbrs = { };
  };
}
