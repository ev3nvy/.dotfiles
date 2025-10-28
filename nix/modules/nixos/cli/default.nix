{
  metadata,
  namespace,
  ...
}:
let
  args = { inherit metadata namespace; };
in
{
  config,
  lib,
  ...
}:
let
  cfg = config.${namespace}.cli;
in
{
  imports = [
    (import ./jq.nix args)
  ];

  options = {
    ${namespace}.cli.enable = lib.mkEnableOption "cli module";
  };

  config.${namespace}.cli = lib.mkIf cfg.enable {
    jq.enable = lib.mkDefault true;
  };
}
