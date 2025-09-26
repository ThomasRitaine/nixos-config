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
    sshSigningKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfzcGogOrC1eyrQnEpwkQaPBM2fz2MyFXMjq8G8ywuC Thomas Ritaine EXT DIGIT A4 SSH Key";
  };

  myKubernetesModule =
    import ../../modules/home-manager/kubernetes.nix { inherit pkgs lib; };
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
    ../../modules/home-manager/wezterm/wezterm.nix
    ../../modules/home-manager/bitwarden.nix
    ../../modules/home-manager/dev-env.nix
  ];

  home.packages = with pkgs; [ cloudflared ];

  home.file = { };

  home.sessionVariables = { };
}
