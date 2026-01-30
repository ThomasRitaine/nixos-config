{ lib, config, inputs, ... }:

{
  options = {
    hostFlakeName = lib.mkOption {
      type = lib.types.str;
      description = "Name of the host in the flake";
    };
  };

  config = {
    age.secrets = {
      thomas-password.file = ../../../secrets/servers/${config.hostFlakeName}/thomas-password.age;
      root-password.file = ../../../secrets/servers/${config.hostFlakeName}/root-password.age;
      app-manager-password.file = ../../../secrets/servers/${config.hostFlakeName}/app-manager-password.age;
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
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFDBWxSC0X5OEFoc+DK8ZmWrDERNQwGzUNG8261IedI Personal VPS ssh key for user thomas"
        ];
      };
      "app-manager" = {
        isNormalUser = true;
        description = "App Manager";
        home = "/home/app-manager";
        extraGroups = [ "docker" ];
        hashedPasswordFile = config.age.secrets.app-manager-password.path;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGhhJyyQRqM+Bq7vBrzwrZIr1hnEbmfrzYXU5kXHIMCm Personal VPS ssh key for user app-manager"
        ];
      };
    };

    home-manager = let
      homeBaseConfig = {
        home.stateVersion = "24.11";
        programs.home-manager.enable = true;
      };

      myGitThomasModule = import ../../home-manager/git-thomas.nix {
        email = "thomas.ritaine@outlook.com";
      };

      commonImports = [
        ../../home-manager/fish.nix
        ../../home-manager/comma.nix
        ../../home-manager/distro-icon.nix
        ../../home-manager/starship.nix
        ../../home-manager/zoxide.nix
        ../../home-manager/fzf.nix
        ../../home-manager/neovim/base.nix
        ../../home-manager/tmux.nix
        ../../home-manager/utils.nix
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
