{ lib, pkgs, config, ... }:
let
  flakePath = "/home/thomas/nix-config";

  myNeovimModule = import ../../modules/home-manager/neovim/lazyvim.nix {
    inherit pkgs config;
    flakePath = flakePath;
  };

  myLazygitModule =
    import ../../modules/home-manager/lazygit/lazygit.nix { inherit pkgs; };

  myUpdateFlakeModule = import ../../modules/home-manager/update-flake.nix {
    inherit pkgs;
    updateType = "home-manager";
    hostFlakeName = "laptop-ec";
    flakePath = flakePath;
  };

  myGitThomasModule = import ../../modules/home-manager/git-thomas.nix {
    email = "thomas.ritaine@ext.ec.europa.eu";
  };

  myKubernetesModule =
    import ../../modules/home-manager/kubernetes.nix { inherit pkgs lib; };

  myWeztermModule = import ../../modules/home-manager/wezterm/wezterm.nix;
in {
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

  home.username = "thomas";
  home.homeDirectory = "/home/thomas";

  imports = [
    ../../modules/home-manager/profiles/common.nix

    # Laptop-specific modules
    myNeovimModule
    myLazygitModule
    myUpdateFlakeModule
    myGitThomasModule
    myKubernetesModule
    myWeztermModule
    ../../modules/home-manager/dev-env.nix
  ];

  home.packages = with pkgs; [ bitwarden-desktop ];

  home.file = { };

  home.sessionVariables = {
    SSH_AUTH_SOCK = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
  };
}
