{ pkgs, lib, ... }: {
  home.packages = [ pkgs.zsh-vi-mode pkgs.zsh-you-should-use ];

  programs.zsh = {
    enable = true;

    enableCompletion = false;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      l = "ls -lAFh";
      dc = "docker compose";
      k = "kubectl";
    };

    plugins = [
      {
        name = "zsh-autocomplete";
        src = pkgs.fetchFromGitHub {
          # src = "${pkgs.zsh-autocomplete}/share/zsh-autocomplete/";
          owner = "marlonrichert";
          repo = "zsh-autocomplete";
          rev = "2024-09-04";
          sha256 = "0NW0TI//qFpUA2Hdx6NaYdQIIUpRSd0Y4NhwBbdssCs=";
          # sha256 = "1357hygrjwj5vd4cjdvxzrx967f1d2dbqm2rskbz5z1q6jri1hm3";
        };
      }
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
      {
        name = "you-should-use";
        src = "${pkgs.zsh-you-should-use}/share/zsh/plugins/you-should-use/";
      }
    ];

    initContent = lib.mkBefore ''
      ## Options section
      setopt interactive_comments                                     # Enable autocomplete, enable comments in the CLI
      unsetopt completealiases                                        # Fix completion aliases
      setopt correct                                                  # Auto correct mistakes
      setopt extendedglob                                             # Extended globbing. Allows using regular expressions with *
      setopt globdots                                                 # Allow dotfiles to be matched with *, and show in autocomplete list
      setopt nocaseglob                                               # Case insensitive globbing
      setopt rcexpandparam                                            # Array expension with parameters
      setopt nocheckjobs                                              # Don't warn about running processes when exiting
      setopt numericglobsort                                          # Sort filenames numerically when it makes sense

      # autocompletions config
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive tab completion
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"       # Colored completion (different colors for dirs/files/etc)
      zstyle ':completion:*' rehash true                              # automatically find new executables in path
      zstyle ':completion::complete:*' gain-privileges 1
      zstyle -e ':autocomplete:*:*' list-lines 'reply=( $(( LINES / 3 )) )'

      # Cycle/enter autocomplete with tab and shift + tab
      bindkey              '^I' menu-select
      bindkey '^[[Z' reverse-menu-complete

      # Navigate words
      bindkey '^[[1;5D' backward-word                                 # Ctrl + right key
      bindkey '^[[1;5C' forward-word                                  # Ctrl + left key
      bindkey '^H' backward-kill-word                                 # Delete previous word with ctrl+backspace
      bindkey "^[[3;5~" kill-word
    '';
  };
}
