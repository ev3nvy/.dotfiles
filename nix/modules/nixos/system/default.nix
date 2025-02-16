{
  metadata,
  namespace,
  ...
}: let
  args = {inherit metadata namespace;};
in
  {
    config,
    lib,
    ...
  }: let
    cfg = config.${namespace}.system;
  in {
    imports = [
      (import ./shell.nix args)
    ];

    options = {
      ${namespace}.system.enable = lib.mkEnableOption "system module";
    };

    config.${namespace}.system = lib.mkIf cfg.enable {
      shell.enable = lib.mkDefault true;
    };
  }
