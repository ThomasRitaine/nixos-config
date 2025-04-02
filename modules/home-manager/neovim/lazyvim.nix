{ pkgs, config, flakePath, }: {
  imports = [ ./base.nix ];

  home.file."${config.home.homeDirectory}/.config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink
    "${flakePath}/modules/home-manager/neovim/config";

  home.packages = with pkgs; [ fd ];
}
