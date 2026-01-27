{ pkgs, lib, config, ... }:

{
  options = {
    hostFlakeName = lib.mkOption {
      type = lib.types.str;
      description = "Name of the host in the flake";
    };

    flakePath = lib.mkOption {
      type = lib.types.str;
      default = "/etc/nixos";
      description = "Path to the flake directory";
    };
  };

  config = {
    users.mutableUsers = false;
    users.users = {
      root = {
        isNormalUser = false;
        hashedPasswordFile = "${config.flakePath}/secrets/root-password";
      };
      thomas = {
        isNormalUser = true;
        description = "Thomas";
        home = "/home/thomas";
        extraGroups = [ "wheel" "docker" ];
        hashedPasswordFile = "${config.flakePath}/secrets/thomas-password";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFDBWxSC0X5OEFoc+DK8ZmWrDERNQwGzUNG8261IedI Personal VPS ssh key for user thomas"
        ];
      };
      "app-manager" = {
        isNormalUser = true;
        description = "App Manager";
        home = "/home/app-manager";
        extraGroups = [ "docker" ];
        hashedPasswordFile = "${config.flakePath}/secrets/app-manager-password";
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

      myUpdateFlakeModule = import ../../home-manager/update-flake.nix {
        inherit pkgs;
        updateType = "nixos";
        hostFlakeName = config.hostFlakeName;
        flakePath = config.flakePath;
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
        myUpdateFlakeModule
        homeBaseConfig
      ];
    in {
      users = {
        root = { pkgs, ... }: { imports = commonImports; };

        thomas = { pkgs, ... }: {
          imports = commonImports ++ [ myGitThomasModule ];
        };

        "app-manager" = { pkgs, ... }: {
          imports = commonImports;
          home.packages = with pkgs; [ awscli2 ];
        };
      };
    };
  };
}
