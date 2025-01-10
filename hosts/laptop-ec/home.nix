{ lib, pkgs, ... }:
let
  myZshModule = import ../../modules/home-manager/zsh.nix {
    inherit pkgs;
  };

  myDistroIconModule = import ../../modules/home-manager/distro-icon.nix {
    inherit pkgs;
  };

  myStarshipModule = import ../../modules/home-manager/starship.nix {
    inherit lib;
  };

  myZoxideModule = import ../../modules/home-manager/zoxide.nix {
    inherit pkgs;
  };

  myNixvimModule = import ../../modules/home-manager/nixvim/nixvim.nix {
    inherit pkgs lib;
  };

  myFzfModule = import ../../modules/home-manager/fzf.nix;

  myLazygitModule = import ../../modules/home-manager/lazygit/lazygit.nix {
    inherit pkgs;
  };

  myUpdateFlakeModule = import ../../modules/home-manager/update-flake.nix {
    inherit pkgs;
    updateType = "home-manager";
    hostFlakeName = "laptop-ec";
    flakePath = "/home/thomas/nix-config";
  };

  myGitThomasModule = import ../../modules/home-manager/git-thomas.nix {
    email = "thomas.ritaine@ext.ec.europa.eu";
  };

  myUtilsModule = import ../../modules/home-manager/utils.nix {
    inherit pkgs;
  };

  myWeztermModule = import ../../modules/home-manager/wezterm/wezterm.nix;

in {
  home.stateVersion = "24.11";
  programs.home-manager.enable = true;

  home.username = "thomas";
  home.homeDirectory = "/home/thomas";

  imports = [
    myZshModule
    myDistroIconModule
    myStarshipModule
    myZoxideModule
    myNixvimModule
    myFzfModule
    myLazygitModule
    myUpdateFlakeModule
    myGitThomasModule
    myUtilsModule
    myWeztermModule
  ];

  home.packages = [
  ];

  home.file = {
  };

  home.sessionVariables = {
  };
}
