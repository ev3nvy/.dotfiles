{modulesNamespace}: {
  config,
  lib,
  ...
}: let
  hmCfg = config.${modulesNamespace}.metadata.homeManager;
in {
  options = {
    ${modulesNamespace} = {
      name = modulesNamespace;
      metadata = {
        homeManager = {
          enabled = lib.mkOption {
            example = true;
            description = "Whether Home Manager is enabled for the current system.";
            type = lib.types.bool;
          };
          username = lib.mkOption {
            example = "sheldon";
            description = "The user's username.";
            type = lib.types.str;
          };
          # https://github.com/nix-community/home-manager/issues/2085#issuecomment-2022239332
          dotfiles = lib.mkOption rec {
            example = default;
            description = "Location of the dotfiles working copy";
            type = lib.types.nullOr lib.types.path;
            apply = toString;
            default =
              if hmCfg.enabled
              then "${config.home-manager.users."${hmCfg.username}".${modulesNamespace}.config.home.homeDirectory}/.dotfiles"
              else null;
          };
        };
      };
    };
  };

  imports = let
    args = {
      inherit (config.${modulesNamespace}) metadata;
      namespace = modulesNamespace;
    };
  in [
    (import ./cli args)
    (import ./programs args)
    (import ./services args)
    (import ./system args)
    (import ./tools args)
  ];
}
