{ pkgs, inputs, lib, ... }:
{ flakePath ? "/etc/nixos", hostFlakeName, additionalUserGroups ? { }
, additionalUserPackages ? { }, extraUserConfigs ? { }, }: {
  users.mutableUsers = false;
  users.users = {
    root = {
      isNormalUser = false;
      hashedPasswordFile = "${flakePath}/secrets/root-password";
    };
    thomas = {
      isNormalUser = true;
      description = "Thomas";
      home = "/home/thomas";
      extraGroups = [ "wheel" "docker" ]
        ++ (additionalUserGroups.thomas or [ ]);
      hashedPasswordFile = "${flakePath}/secrets/thomas-password";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOFDBWxSC0X5OEFoc+DK8ZmWrDERNQwGzUNG8261IedI Personal VPS ssh key for user thomas"
      ];
    };
    "app-manager" = {
      isNormalUser = true;
      description = "App Manager";
      home = "/home/app-manager";
      extraGroups = [ "docker" ] ++ (additionalUserGroups."app-manager" or [ ]);
      hashedPasswordFile = "${flakePath}/secrets/app-manager-password";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGhhJyyQRqM+Bq7vBrzwrZIr1hnEbmfrzYXU5kXHIMCm Personal VPS ssh key for user app-manager"
      ];
    };
  } // (extraUserConfigs);

  home-manager = let
    myUpdateFlakeModule =
      import ../../../modules/home-manager/update-flake.nix {
        inherit pkgs;
        updateType = "nixos";
        inherit hostFlakeName flakePath;
      };

    myGitThomasModule = import ../../../modules/home-manager/git-thomas.nix {
      email = "thomas.ritaine@outlook.com";
    };

    commonImports = [
      ../../../modules/home-manager/profiles/common.nix
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
        home.packages = with pkgs;
          [ awscli2 ] ++ (additionalUserPackages."app-manager" or [ ]);
      };
    };
  };
}
