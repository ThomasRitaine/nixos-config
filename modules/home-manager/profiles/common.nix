{ ... }: {
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

  imports = [
    ../zsh.nix
    ../distro-icon.nix
    ../starship.nix
    ../zoxide.nix
    ../fzf.nix
    ../neovim/base.nix
    ../utils.nix
    ../kill-process.nix
  ];
}
