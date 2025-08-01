{modulesNamespace}: {
  config,
  lib,
  ...
}: {
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
            type = lib.types.nullOr lib.types.str;
          };
          # https://github.com/nix-community/home-manager/issues/2085#issuecomment-2022239332
          dotfiles = lib.mkOption {
            example = "/home/sheldon/.dotfiles";
            description = "Location of the dotfiles working copy";
            type = lib.types.nullOr lib.types.str;
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
