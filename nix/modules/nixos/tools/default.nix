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
  cfg = config.${namespace}.tools;
in
{
  imports = [
    (import ./git.nix args)
  ];

  options = {
    ${namespace}.tools.enable = lib.mkEnableOption "tools module";
  };

  config.${namespace}.tools = lib.mkIf cfg.enable {
    git.enable = lib.mkDefault true;
  };
}
