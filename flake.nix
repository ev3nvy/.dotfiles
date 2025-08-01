{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # pin to specific commit because most changes probably don't apply to my hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware/d1bfa8f6ccfb5c383e1eba609c1eb67ca24ed153";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        pre-commit-hooks-nix.follows = "";
        rust-overlay.follows = "rust-overlay";
      };
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO: use nixpkgs version once it is added (pr: https://github.com/NixOS/nixpkgs/pull/363992,
    #       tracking issue: https://github.com/NixOS/nixpkgs/issues/327982)
    #
    # key points for why this hasn't happened yet:
    # - https://github.com/NixOS/nixpkgs/issues/327982#issuecomment-2901415494
    # - https://github.com/NixOS/nixpkgs/issues/327982#issuecomment-2903811147
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    alejandra = {
      url = "github:kamadorueda/alejandra/3.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
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
      dotfiles,
      modules ? [],
      modulesNamespace ? "customModule",
      useLanzaboote ? false,
      includeHomeManager ? true,
      # TODO: I'd like to test out different DEs/WMs so maybe I should declare them as an enum and
      #       then have a `activeDe = "plasma6"`; also look into specializatons:
      #       https://www.reddit.com/r/NixOS/comments/1fwrary/comment/lqhnon9
      usePlasmaManager ? true,
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
          inherit username homeDirectory hostname modulesNamespace;
        };
        modules =
          [
            ./nix/systems/${hostname}
            {
              networking.hostName = hostname;

              ${modulesNamespace}.metadata = {
                homeManager.enabled = includeHomeManager;
                plasmaManager.enabled = usePlasmaManager;
              };
            }
            (import ./nix/modules/nixos {inherit modulesNamespace;})
          ]
          ++ (
            if useLanzaboote
            then [
              inputs.lanzaboote.nixosModules.lanzaboote
              ./nix/modules/nixos/system/lanzaboote.nix
            ]
            else []
          )
          ++ (
            if includeHomeManager
            then [
              inputs.home-manager.nixosModules.home-manager
              ({config, ...}: {
                ${modulesNamespace}.metadata.homeManager = {
                  inherit username dotfiles;
                };

                home-manager = {
                  # TODO: look into what these do
                  # useUserPackages = true;
                  # useGlobalPkgs = false;
                  extraSpecialArgs = {
                    inherit inputs;
                    inherit username homeDirectory;
                    inherit (config.${modulesNamespace}) metadata;
                  };
                  sharedModules =
                    [
                      inputs.nix-index-database.homeModules.nix-index
                      inputs.zen-browser.homeModules.beta
                    ]
                    ++ (
                      if usePlasmaManager
                      then [
                        inputs.plasma-manager.homeManagerModules.plasma-manager
                        ./nix/modules/nixos/system/plasma.nix
                      ]
                      else []
                    );
                  users."${username}" = import ./nix/systems/${hostname}/home.nix;
                };
              })
            ]
            else []
          )
          ++ modules;
      };
  in {
    nixosConfigurations = {
      ev3nvy-desktop = let
        username = "ev3nvy";
        homeDirectory = "/home/${username}";
      in
        createNixosConfiguration {
          inherit username homeDirectory;

          system = "x86_64-linux";
          hostname = "ev3nvy-desktop";
          dotfiles = "${homeDirectory}/.dotfiles";
          useLanzaboote = true;
          usePlasmaManager = false;
        };
      shadow-moses = let
        username = "ev3nvy";
        homeDirectory = "/home/${username}";
      in
        createNixosConfiguration {
          inherit username homeDirectory;

          system = "x86_64-linux";
          hostname = "shadow-moses";
          dotfiles = "${homeDirectory}/.dotfiles";
          # I actually own a "Lenovo Yoga Slim 7 Pro 16ACH6" not an Ideapad, but the way mine is
          # specced fits (a version of) this model
          modules = [
            inputs.nixos-hardware.nixosModules.lenovo-ideapad-16ach6
            ({
              config,
              lib,
              ...
            }: {
              nixpkgs.config.allowUnfreePredicate = pkg:
                builtins.elem (lib.getName pkg) [
                  "nvidia-settings"
                  "nvidia-x11"
                ];
            })
          ];
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
              (pkgs.writeShellScriptBin "nixos_switch" "nixos-rebuild switch --show-trace --flake .")
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

    formatter = nixpkgs.lib.genAttrs supportedSystems (system: inputs.alejandra.defaultPackage.${system});
  };
}
