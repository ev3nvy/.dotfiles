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
      (import ./audio.nix args)
      (import ./shell.nix args)
    ];

    options = {
      ${namespace}.system.enable = lib.mkEnableOption "system module";
    };

    config.${namespace}.system = lib.mkIf cfg.enable {
      audio.enable = lib.mkDefault true;
      shell.enable = lib.mkDefault true;
    };
  }
