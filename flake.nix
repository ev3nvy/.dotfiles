{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    alejandra = {
      url = "github:kamadorueda/alejandra/3.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: {
    nixosConfigurations = {
      ev3nvy-desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          inputs.lanzaboote.nixosModules.lanzaboote
          ./nix/systems/ev3nvy-desktop
          inputs.home-manager.nixosModules.default
        ];
      };
    };

    devShell.x86_64-linux = self.devShells.x86_64-linux.default;
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      buildInputs = [
        inputs.alejandra.defaultPackage.x86_64-linux
        inputs.nil.packages.x86_64-linux.default
        nixpkgs.legacyPackages.x86_64-linux.biome
        nixpkgs.legacyPackages.x86_64-linux.just
      ];
    };
  };
}
