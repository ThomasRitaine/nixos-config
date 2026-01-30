{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hydenix.url = "github:richen604/hydenix";

    nixos-hardware.url = "github:nixos/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, disko, nixgl, agenix, ... }@inputs:
    let
      mkOracleHost = hostname: nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/oracle-vps/configuration.nix
          disko.nixosModules.disko
          inputs.home-manager.nixosModules.default
          {
            networking.hostName = hostname;
            hostFlakeName = hostname;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
    in
    {
    nixosConfigurations = {
      vps-8karm = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/vps-8karm/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      phoenix86 = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/phoenix86/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      winix = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/winix/configuration.nix
        ];
      };
      # Oracle instances
      orarm = mkOracleHost "orarm";
      pharaoh = mkOracleHost "pharaoh";
      koola = mkOracleHost "koola";
    };

    homeConfigurations = {
      laptop-ec = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [ nixgl.overlay ];
        };
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./hosts/laptop-ec/home.nix ];
      };
    };
  };
}
