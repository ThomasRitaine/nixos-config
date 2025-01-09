{ config, pkgs, ... }:

{
  programs.nixvim = {
    enable = true;

    defaultEditor = true;
    viAlias = true;

    colorschemes.catppuccin.enable = true;
    plugins.lualine.enable = true;
  };
}

