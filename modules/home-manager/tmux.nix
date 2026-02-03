{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;

    # Keep your preferred prefix
    shortcut = "b";

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'mocha'
          set -g @catppuccin_window_status_style 'rounded'
          set -g status-right-length 100
          set -g status-left-length 100

          # Remove unnecessary status boxes
          set -g status-left ""
          set -g status-right "#{E:@catppuccin_status_application}"
          set -ag status-right "#{E:@catppuccin_status_session}"

          # Disable windows auto-renaming
          set -g @catppuccin_window_default_text " #W"
          set -g @catppuccin_window_current_text " #W"
          set -g @catppuccin_window_text " #W"
        '';
      }
      {
        plugin = fingers;
        extraConfig = ''
          set -g @fingers-key F
          set -g @fingers-keyboard-layout 'azerty'
          set -g @fingers-hint-style 'fg=red,bold'
          set -g @fingers-highlight-style 'fg=green,bold'
        '';
      }
      {
        plugin = yank;
        extraConfig = ''
          # Enable system clipboard (OSC 52)
          set -g set-clipboard on

          # Stay in copy mode after yanking (optional, often preferred)
          set -g @yank_action 'copy-pipe'
        '';
      }
      {
        # Save/Restore sessions
        plugin = resurrect;
        extraConfig = ''
          # Restore Neovim sessions if Session.vim exists
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        # Auto-save/Auto-restore
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15' # Save every 15 minutes
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

      # Allow the remote tmux to send clipboard sequences to your local terminal
      set -g allow-passthrough on

      # --- Inner vs Outer Logic ---
      bind-key b send-prefix

      # --- Quick Reload ---
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

      # --- Fix colors with Kity ---
      set-option -ga terminal-overrides ",xterm-256color:Tc"

      # --- Keybind hints ---
      bind-key y display-popup -w 100% -h 70% -E 'comm -23 <(tmux list-keys | sort) <(tmux -L test -f /dev/null list-keys | sort) | cut -c-"$(tput cols)" | fzf -e -i --prompt="tmux hotkeys: " --info=inline --layout=reverse --scroll-off=5 --tiebreak=index --header "prefix=yes-prefix root=no-prefix" > /dev/null'

      # --- VISUAL MODE CONFIG ---
      bind v copy-mode
      unbind [
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # --- Custom Keybinds ---
      unbind %
      bind - split-window -h -c "#{pane_current_path}"
      unbind '"'
      bind _ split-window -v -c "#{pane_current_path}"
      # Keep new windows in the current path
      unbind c
      bind t new-window -c "#{pane_current_path}"
      unbind w
      bind w kill-window
      # Cycle through windows
      unbind n
      bind Tab next-window
      unbind p
      bind BTab previous-window
    '';
  };
}

