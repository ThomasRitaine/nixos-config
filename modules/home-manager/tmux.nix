{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'mocha'
          set -g @catppuccin_window_status_style 'rounded'
          set -g status-right-length 100
          set -g status-left-length 100
          set -g status-left ""
          set -g status-right "#{E:@catppuccin_status_application}"
          set -ag status-right "#{E:@catppuccin_status_session}"
        '';
      }
      {
        plugin = yank;
        extraConfig = ''
          set -g set-clipboard on
          set -g @override_copy_command 'xclip -i -selection clipboard'
          set -g @yank_selection 'clipboard'
          set -as terminal-features ',*:clipboard'
        '';
      }
      { plugin = sensible; }
    ];
    extraConfig = ''
      # Status bar transparent background
      set -g status-bg default
      set -g status-style bg=default
      # Status bar on top
      set-option -g status-position top
    '';
  };
}
