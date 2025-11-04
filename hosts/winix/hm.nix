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

      # Use non mono font for nerd icons
      symbol_map U+E5FA-U+E6AC,U+E700-U+E7C5,U+F000-U+F2E0,U+E200-U+E2A9,U+F0001-U+F1AF0,U+E300-U+E3E3,U+F400-U+F532,U+2665,U+26A1,U+E0A0-U+E0A2,U+E0B0-U+E0B3,U+E0A3,U+E0B4-U+E0C8,U+E0CA,U+E0CC-U+E0D4,U+23FB-U+23FE,U+2B58,U+F300-U+F32F,U+E000-U+E00A,U+EA60-U+EBEB CaskaydiaCove Nerd Font
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
