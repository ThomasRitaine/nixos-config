{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    withPython3 = false;
    withRuby = false;
  };

  # Open man pages with nvim
  home.sessionVariables = {
    MANPAGER = "nvim +Man!";
  };
}
