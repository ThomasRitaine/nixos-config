{
  hydenix.hm.hyprland.keybindings = {
    extraConfig = ''
      bindd = $mainMod, colon, $d keybindings hint, exec, pkill -x rofi || $scrPath/keybinds_hint.sh c
      unbind = $mainMod, slash
    '';
  };

  home.file.".config/hypr/userprefs.conf" = {
    force = true;
    text = ''
      input {
        kb_layout = fr

        touchpad {
          natural_scroll = true
        }
      }

      # Switch workspaces with AZERTY keys
      bind = $mainMod, ampersand, workspace, 1
      bind = $mainMod, eacute, workspace, 2
      bind = $mainMod, quotedbl, workspace, 3
      bind = $mainMod, apostrophe, workspace, 4
      bind = $mainMod, parenleft, workspace, 5
      bind = $mainMod, minus, workspace, 6
      bind = $mainMod, egrave, workspace, 7
      bind = $mainMod, underscore, workspace, 8
      bind = $mainMod, ccedilla, workspace, 9
      bind = $mainMod, agrave, workspace, 10

      # Move windows to workspaces
      bind = $mainMod SHIFT, ampersand, movetoworkspace, 1
      bind = $mainMod SHIFT, eacute, movetoworkspace, 2
      bind = $mainMod SHIFT, quotedbl, movetoworkspace, 3
      bind = $mainMod SHIFT, apostrophe, movetoworkspace, 4
      bind = $mainMod SHIFT, parenleft, movetoworkspace, 5
      bind = $mainMod SHIFT, minus, movetoworkspace, 6
      bind = $mainMod SHIFT, egrave, movetoworkspace, 7
      bind = $mainMod SHIFT, underscore, movetoworkspace, 8
      bind = $mainMod SHIFT, ccedilla, movetoworkspace, 9
      bind = $mainMod SHIFT, agrave, movetoworkspace, 10
    '';
  };
}
