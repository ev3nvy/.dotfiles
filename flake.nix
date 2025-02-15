{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pre-commit-hooks-nix.follows = "";
      inputs.rust-overlay.follows = "rust-overlay";
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
      inputs.rust-overlay.follows = "rust-overlay";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    supportedSystems = ["x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    # https://github.com/redyf/nixdots/blob/72420a5d4ee128eea41cef0c385fb15a43be4077/flake.nix#L63-L116
    createNixosConfiguration = {
      system,
      username,
      homeDirectory,
      hostname,
      modules ? [],
      useLanzaboote ? false,
      includeHomeManager ? true,
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          inherit username homeDirectory hostname;
        };
        modules =
          [
            ./nix/systems/${hostname}
            {networking.hostName = hostname;}
          ]
          ++ (
            if useLanzaboote
            then [
              inputs.lanzaboote.nixosModules.lanzaboote
              ./nix/modules/nixos/lanzaboote.nix
            ]
            else []
          )
          ++ (
            if includeHomeManager
            then [
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager = {
                  # TODO: look into what these do
                  # useUserPackages = true;
                  # useGlobalPkgs = false;
                  extraSpecialArgs = {inherit inputs username homeDirectory;};
                  sharedModules = [inputs.nix-index-database.hmModules.nix-index];
                  users."${username}" = import ./nix/systems/${hostname}/home.nix;
                };
              }
            ]
            else []
          )
          ++ modules;
      };
  in {
    nixosConfigurations = {
      ev3nvy-desktop = createNixosConfiguration {
        system = "x86_64-linux";
        username = "ev3nvy";
        homeDirectory = "/home/ev3nvy";
        hostname = "ev3nvy-desktop";
        useLanzaboote = true;
      };
    };

    packages = forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
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
        }
    );

    devShell = forAllSystems (
      system: {
        # does this make sense?
        system = self.devShells.${system}.default;
      }
    );
    devShells = forAllSystems (
      system: let
        overlays = [(import inputs.rust-overlay)];
        pkgs = import nixpkgs {
          inherit system overlays;
          config.allowUnfreePredicate = pkg:
            builtins.elem (nixpkgs.lib.getName pkg) [
              "clion"
              "davinci-resolve"
            ];
        };
        rustVersion = "latest";
        rust = pkgs.rust-bin.stable.${rustVersion}.default.override {
          extensions = [
            "rust-src"
            "rust-analyzer"
            "clippy"
          ];
        };
      in {
        default = pkgs.mkShell {
          buildInputs =
            [
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
        biome = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.biome
          ];
        };
        cpp = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.jetbrains.clion
          ];
        };
        flatbuffers = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.flatbuffers
          ];
        };
        just = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.just
          ];
        };
        nix = pkgs.mkShell {
          nativeBuildInputs = [
            inputs.alejandra.defaultPackage.${system}
            inputs.nil.packages.${system}.default
          ];
        };
        nodejs-lts-jod = let
          nodejs = pkgs.callPackage "${nixpkgs}/pkgs/development/web/nodejs/v22.nix" {
            inherit (pkgs) python3 openssl;
          };
        in
          pkgs.mkShell {
            inputsFrom = with self.devShells.${system}; [biome];

            buildInputs = [
              nodejs
            ];
          };
        rust = pkgs.mkShell {
          inputsFrom = with self.devShells.${system}; [toml];
          nativeBuildInputs = [
            rust
            pkgs.bacon
            pkgs.cargo-deny
            pkgs.cargo-edit
            pkgs.cargo-expand
            pkgs.cargo-msrv
            pkgs.cargo-update # to manage executables not available in nixpkgs
            pkgs.cargo-watch
            pkgs.cargo-workspaces
            pkgs.cargo-zigbuild
          ];
        };
        toml = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.taplo
          ];
        };
        videoEditing = pkgs.mkShell {
          packages = [
            pkgs.davinci-resolve
            pkgs.handbrake
          ];
        };
      }
    );
  };
}
