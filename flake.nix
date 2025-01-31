{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pre-commit-hooks-nix.follows = "";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
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
  } @ inputs: let
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      ev3nvy-desktop = nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs = {inherit inputs system;};
        modules = [
          inputs.lanzaboote.nixosModules.lanzaboote
          ./nix/systems/ev3nvy-desktop
          inputs.home-manager.nixosModules.default
        ];
      };
    };

    packages.${system} = let
      pkgs = nixpkgs.legacyPackages.${system};
    in
      with pkgs; rec {
        codium = vscode-with-extensions.override (prev: {
          vscode = vscodium;
          vscodeExtensions = with vscode-extensions;
            prev.vscodeExtensions
            or []
            ++ [
              biomejs.biome
              jnoortheen.nix-ide
              kamadorueda.alejandra
              mkhl.direnv
            ];
        });
        codium-dev = pkgs.writeShellScriptBin "codium-dev" ''
          set -e
          dir="''${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles-codium"
          ${pkgs.coreutils}/bin/mkdir -p "$dir/User"
          cat >"$dir/User/settings.json" <<EOF
          {
              "files.associations": {
                  "justfile": "makefile",
                  ".env": "dotenv",
              },
              "[json]": {
                  "editor.defaultFormatter": "biomejs.biome",
                  "editor.formatOnSave": true,
                  "editor.tabSize": 4,
              },
              "[jsonc]": {
                  "editor.defaultFormatter": "biomejs.biome",
                  "editor.formatOnSave": true,
                  "editor.tabSize": 4,
              },
              "[nix]": {
                  "editor.defaultFormatter": "kamadorueda.alejandra",
                  "editor.formatOnSave": true,
              },
              "biome.enabled": true,
              "nix.enableLanguageServer": true,
          }
          EOF
          exec ${codium}/bin/codium --user-data-dir "$dir" "$@"
        '';
      };

    devShell.${system} = self.devShells.${system}.default;
    devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
      buildInputs = let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        [
          inputs.alejandra.defaultPackage.${system}
          inputs.nil.packages.${system}.default
          pkgs.biome
          pkgs.just
          (pkgs.writeShellScriptBin "nixos_switch" "nixos-rebuild switch --flake .")
          (pkgs.writeShellScriptBin "nixos_upgrade" "nix flake update")
          (pkgs.writeShellScriptBin "nixos_upgrade_switch" "nixos-rebuild switch --recreate-lock-file --flake .")
          (pkgs.writeShellScriptBin "nixos_clean" "nix-collect-garbage --delete-old")
          (pkgs.writeShellScriptBin "nixos_remove_generations" "nix-env --delete-generations --profile /nix/var/nix/profiles/system 2d")
        ]
        ++ nixpkgs.lib.optionals (nixpkgs.lib.meta.availableOn pkgs.stdenv.hostPlatform pkgs.vscodium) [
          self.packages.${system}.codium-dev
        ];
    };
  };
}
