{ pkgs, ... }: {

  home.packages = with pkgs; [
    nixgl.nixGLIntel
    (pkgs.writeShellScriptBin "wezterm" ''
      exec ${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel ${pkgs.wezterm}/bin/wezterm "$@"
    '')
  ];

  home.file.".config/wezterm/wezterm.lua".source = ./wezterm.lua;
  home.file.".config/wezterm/lua".source = ./lua;

  # Add a desktop entry for the application launcher
  xdg.desktopEntries.wezterm = {
    name = "WezTerm";
    genericName = "Terminal Emulator";
    comment = "A GPU-accelerated cross-platform terminal emulator";
    exec =
      "${pkgs.nixgl.nixGLIntel}/bin/nixGLIntel ${pkgs.wezterm}/bin/wezterm start --cwd .";
    icon = "org.wezfurlong.wezterm";
    categories = [ "System" "TerminalEmulator" "Utility" ];
    terminal = false;
  };
}
