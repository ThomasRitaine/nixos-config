{ config, pkgs, ... }:

{
  imports = [

    # Nvim
    (import ../../home-manager/neovim/lazyvim.nix {
      inherit pkgs config;
      flakePath = "/home/thomas/nixos-config";
    })

    # Git
    (import ../../home-manager/git-thomas.nix {
      email = "thomas.ritaine@outlook.com";
      sshSigningKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFDBWxSC0X5OEFoc+DK8ZmWrDERNQwGzUNG8261IedI Thomas Ritaine";
    })

    # Lazygit
    (import ../../home-manager/lazygit/lazygit.nix { inherit pkgs; })

    ../../home-manager/bitwarden.nix
    ../../home-manager/fzf.nix
    ../../home-manager/python.nix
    ../../home-manager/utils.nix
    ../../home-manager/zoxide.nix

    ./hyprland.nix
  ];

  home.packages = [ ];

  hydenix.hm = {
    enable = true;

    editors.enable = false;
    git.enable = false;

    terminals.kitty.configText = "confirm_os_window_close 0";

    theme = {
      enable = true;
      active = "Catppuccin Mocha";
      themes = [
        "AncientAlients"
        "Dracula"
        "Grukai"
        "Ice Age"
        "Pixel Dream"
        "Synth Wave"
        "Catppuccin Mocha"
        "Catppuccin Latte"
        "Decay Green"
        "Rosé Pine"
        "Tokyo Night"
        "Gruvbox Retro"
      ];
    };
  };
}
