{
  hydenix.hm = {
    enable = true;

    editors.enable = false;
    git.enable = false;

    terminals.kitty.configText = ''
      confirm_os_window_close 0
      font_size 12.0
      window_padding_width 0
      term xterm-256color

      # Use non mono font to display nerd icons with right size
      font_family CaskaydiaCove Nerd Font

      # Send Ctrl+W for Ctrl+Backspace to delete word backward
      map ctrl+backspace send_text all \x17
    '';
  };
}
