{ config, pkgs, ... }:

{
  imports = [

    # Nvim
    (import ../../modules/home-manager/neovim/lazyvim.nix {
      inherit pkgs config;
      flakePath = "/home/thomas/nixos-config";
    })

    # Git
    (import ../../modules/home-manager/git-thomas.nix {
      email = "thomas.ritaine@outlook.com";
      sshSigningKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFDBWxSC0X5OEFoc+DK8ZmWrDERNQwGzUNG8261IedI Thomas Ritaine";
    })

    # Lazygit
    (import ../../modules/home-manager/lazygit/lazygit.nix { inherit pkgs; })

    ../../modules/home-manager/bitwarden.nix
    ../../modules/home-manager/distro-icon.nix
    ../../modules/home-manager/fish.nix
    ../../modules/home-manager/fzf.nix
    ../../modules/home-manager/python.nix
    ../../modules/home-manager/rustdesk.nix
    ../../modules/home-manager/starship.nix
    ../../modules/home-manager/utils.nix
    ../../modules/home-manager/zoxide.nix
    ../../modules/home-manager/hyprland
  ];

  home.packages = [ ];

  hydenix.hm = {
    enable = true;

    editors.enable = false;
    git.enable = false;

    terminals.kitty.configText = ''
      confirm_os_window_close 0
      font_size 12.0
      window_padding_width 0

      # Use non mono font to display nerd icons with right size
      font_family CaskaydiaCove Nerd Font
    '';

    shell = {
      fish.enable = false;
      starship.enable = false;
    };

    theme = {
      enable = true;
      active = "Catppuccin Mocha";
      themes = [
        "Grukai"
        "Pixel Dream"
        "Ice Age"
        "Dracula"
        "Synth Wave"
        "Catppuccin Mocha"
        "Tokyo Night"
        "Obsidian-Purple"
        "BlueSky"
        "Mac OS"
        "Vanta Black"
        "Monokai"
      ];
    };
  };
}
