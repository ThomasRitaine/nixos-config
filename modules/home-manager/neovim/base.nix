{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
  };

  # Open man pages with nvim
  home.sessionVariables = { MANPAGER = "nvim +Man!"; };
}
