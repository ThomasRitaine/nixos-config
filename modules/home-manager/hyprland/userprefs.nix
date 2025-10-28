{
  home.file.".config/hypr/userprefs.conf" = {
    text = ''
      input {
        kb_layout = fr
        touchpad {
          natural_scroll = true
        }
      }

      # Start applications on login
      exec-once = [workspace 1 silent] kitty
      exec-once = [workspace 2 silent] firefox
      exec-once = [workspace 3 silent] bitwarden
    '';
  };
}
