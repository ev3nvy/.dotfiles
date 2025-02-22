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
    cfg = config.${namespace}.services;
  in {
    imports = [
      (import ./rustdesk.nix args)
    ];

    options = {
      ${namespace}.services.enable = lib.mkEnableOption "services module";
    };

    config.${namespace}.services = lib.mkIf cfg.enable {
      rustdesk.enable = lib.mkDefault true;
      rustdesk.gui.enable = lib.mkDefault true;
    };
  }
