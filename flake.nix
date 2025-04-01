{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    disko,
    ...
  } @ inputs: {
    nixosConfigurations = {
      vps-8karm = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/vps-8karm/configuration.nix
          inputs.home-manager.nixosModules.default
          {
            home-manager.sharedModules = [inputs.nixvim.homeManagerModules.nixvim];
          }
        ];
      };
      vps-orarm = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/vps-orarm/configuration.nix
          disko.nixosModules.disko
          inputs.home-manager.nixosModules.default
          {
            home-manager.sharedModules = [inputs.nixvim.homeManagerModules.nixvim];
          }
        ];
      };
    };

    homeConfigurations = {
      laptop-ec = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {system = "x86_64-linux";};
        extraSpecialArgs = {inherit inputs;};
        modules = [
          ./hosts/laptop-ec/home.nix
          inputs.nixvim.homeManagerModules.nixvim
        ];
      };
    };
  };
}
