{pkgs, config}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
  };

  home.file."${config.home.homeDirectory}/.config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/modules/home-manager/neovim/config";

  home.packages = with pkgs; [
    fd
  ];
}
