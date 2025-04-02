{ pkgs, inputs, ... }:
let flakePath = "/etc/nixos";
in {
  users.mutableUsers = false;
  users.users = {
    root = {
      isNormalUser = false;
      hashedPasswordFile = "/etc/nixos/secrets/root-password";
    };
    thomas = {
      isNormalUser = true;
      description = "Thomas";
      home = "/home/thomas";
      extraGroups = [ "wheel" "docker" ];
      hashedPasswordFile = "/etc/nixos/secrets/thomas-password";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFDBWxSC0X5OEFoc+DK8ZmWrDERNQwGzUNG8261IedI Personal VPS ssh key for user thomas"
      ];
    };
    "app-manager" = {
      isNormalUser = true;
      description = "App Manager";
      home = "/home/app-manager";
      extraGroups = [ "docker" ];
      hashedPasswordFile = "/etc/nixos/secrets/app-manager-password";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGhhJyyQRqM+Bq7vBrzwrZIr1hnEbmfrzYXU5kXHIMCm Personal VPS ssh key for user app-manager"
      ];
    };
  };

  home-manager = let
    myUpdateFlakeModule = import ../../modules/home-manager/update-flake.nix {
      inherit pkgs;
      updateType = "nixos";
      hostFlakeName = "vps-8karm";
      flakePath = flakePath;
    };

    myGitThomasModule = import ../../modules/home-manager/git-thomas.nix {
      email = "thomas.ritaine@outlook.com";
    };

    commonImports = [
      ../../modules/home-manager/profiles/common.nix
      myUpdateFlakeModule
      ./home.nix
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
        home.packages = with pkgs; [ awscli2 ];
      };
    };
  };
}
