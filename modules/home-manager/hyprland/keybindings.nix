{
  hydenix.hm.hyprland.keybindings = {
    extraConfig = ''

      # AZERTY workspace navigation
      $d=[$ws|Navigation]
      bindd = $mainMod, ampersand, $d navigate to workspace 1, workspace, 1
      bindd = $mainMod, eacute, $d navigate to workspace 2, workspace, 2
      bindd = $mainMod, quotedbl, $d navigate to workspace 3, workspace, 3
      bindd = $mainMod, apostrophe, $d navigate to workspace 4, workspace, 4
      bindd = $mainMod, parenleft, $d navigate to workspace 5, workspace, 5
      bindd = $mainMod, minus, $d navigate to workspace 6, workspace, 6
      bindd = $mainMod, egrave, $d navigate to workspace 7, workspace, 7
      bindd = $mainMod, underscore, $d navigate to workspace 8, workspace, 8
      bindd = $mainMod, ccedilla, $d navigate to workspace 9, workspace, 9
      bindd = $mainMod, agrave, $d navigate to workspace 10, workspace, 10

      # AZERTY move window to workspace
      $d=[$ws|Move window to workspace]
      bindd = $mainMod SHIFT, ampersand, $d move to workspace 1, movetoworkspace, 1
      bindd = $mainMod SHIFT, eacute, $d move to workspace 2, movetoworkspace, 2
      bindd = $mainMod SHIFT, quotedbl, $d move to workspace 3, movetoworkspace, 3
      bindd = $mainMod SHIFT, apostrophe, $d move to workspace 4, movetoworkspace, 4
      bindd = $mainMod SHIFT, parenleft, $d move to workspace 5, movetoworkspace, 5
      bindd = $mainMod SHIFT, minus, $d move to workspace 6, movetoworkspace, 6
      bindd = $mainMod SHIFT, egrave, $d move to workspace 7, movetoworkspace, 7
      bindd = $mainMod SHIFT, underscore, $d move to workspace 8, movetoworkspace, 8
      bindd = $mainMod SHIFT, ccedilla, $d move to workspace 9, movetoworkspace, 9
      bindd = $mainMod SHIFT, agrave, $d move to workspace 10, movetoworkspace, 10

      # Unbind old number-based workspace navigation
      unbind = $mainMod, 1
      unbind = $mainMod, 2
      unbind = $mainMod, 3
      unbind = $mainMod, 4
      unbind = $mainMod, 5
      unbind = $mainMod, 6
      unbind = $mainMod, 7
      unbind = $mainMod, 8
      unbind = $mainMod, 9
      unbind = $mainMod, 0

      # Unbind old number-based move to workspace
      unbind = $mainMod SHIFT, 1
      unbind = $mainMod SHIFT, 2
      unbind = $mainMod SHIFT, 3
      unbind = $mainMod SHIFT, 4
      unbind = $mainMod SHIFT, 5
      unbind = $mainMod SHIFT, 6
      unbind = $mainMod SHIFT, 7
      unbind = $mainMod SHIFT, 8
      unbind = $mainMod SHIFT, 9
      unbind = $mainMod SHIFT, 0

      # Unbind old silent move to workspace
      unbind = $mainMod Alt, 1
      unbind = $mainMod Alt, 2
      unbind = $mainMod Alt, 3
      unbind = $mainMod Alt, 4
      unbind = $mainMod Alt, 5
      unbind = $mainMod Alt, 6
      unbind = $mainMod Alt, 7
      unbind = $mainMod Alt, 8
      unbind = $mainMod Alt, 9
      unbind = $mainMod Alt, 0

      # Fullscreen keybinding on Super+F
      $d=[$wm]
      unbind = Shift, F11
      bindd = $mainMod, F, $d toggle fullscreen, fullscreen

      # Keybindings hint on Super+: and unbind previous
      $d=[$l|Rofi menus]
      bindd = $mainMod, colon, $d keybindings hint, exec, pkill -x rofi || $scrPath/keybinds_hint.sh c
      unbind = $mainMod, slash

      # Toggle between last opened workspace
      $d=[$ws|Navigation]
      unbind = $mainMod, TAB
      bindd = $mainMod, TAB, $d toggle last workspace, workspace, previous
      bindd = $mainMod SHIFT, TAB, $d window switcher, exec, pkill -x rofi || $rofi-launch w

      $d=[$l|Apps]
      # Firefox private window on Super Shift B
      bindd = $mainMod Shift, B, $d web browser (private) , exec, firefox --private-window
      # Bitwarden on Super M
      bindd = $mainMod, M, $d password manager, exec, bitwarden
    '';
  };
}
