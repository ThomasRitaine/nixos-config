{ config, inputs, ... }:

{
  config = {
    age.secrets = {
      thomas-password.file = ../../secrets/servers/vps-8karm/thomas-password.age;
      root-password.file = ../../secrets/servers/vps-8karm/root-password.age;
      app-manager-password.file = ../../secrets/servers/vps-8karm/app-manager-password.age;
    };

    users.mutableUsers = false;
    users.users = {
      root = {
        isNormalUser = false;
        hashedPasswordFile = config.age.secrets.root-password.path;
      };
      thomas = {
        isNormalUser = true;
        description = "Thomas";
        home = "/home/thomas";
        extraGroups = [ "wheel" "docker" ];
        hashedPasswordFile = config.age.secrets.thomas-password.path;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFDBWxSC0X5OEFoc+DK8ZmWrDERNQwGzUNG8261IedI Thomas Ritaine"
        ];
      };
      "app-manager" = {
        isNormalUser = true;
        description = "App Manager";
        home = "/home/app-manager";
        extraGroups = [ "docker" ];
        hashedPasswordFile = config.age.secrets.app-manager-password.path;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGhhJyyQRqM+Bq7vBrzwrZIr1hnEbmfrzYXU5kXHIMCm app-manager"
        ];
      };
    };

    home-manager = let
      homeBaseConfig = {
        home.stateVersion = "24.11";
        programs.home-manager.enable = true;
      };

      myGitThomasModule = import ../../modules/home-manager/git-thomas.nix {
        email = "thomas.ritaine@outlook.com";
      };

      commonImports = [
        ../../modules/home-manager/fish.nix
        ../../modules/home-manager/comma.nix
        ../../modules/home-manager/distro-icon.nix
        ../../modules/home-manager/starship.nix
        ../../modules/home-manager/zoxide.nix
        ../../modules/home-manager/fzf.nix
        ../../modules/home-manager/neovim/base.nix
        ../../modules/home-manager/tmux.nix
        ../../modules/home-manager/utils.nix
        homeBaseConfig
      ];
    in {
      extraSpecialArgs = { inherit inputs; };

      users = {
        root = { pkgs, ... }: { imports = commonImports; };

        thomas = { pkgs, ... }: {
          imports = commonImports ++ [ myGitThomasModule ];
        };

        "app-manager" = { pkgs, ... }: {
          imports = commonImports;
        };
      };
    };
  };
}
