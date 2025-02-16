{
  metadata,
  namespace,
  ...
}: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.${namespace}.cli.jq;
in {
  options = {
    ${namespace}.cli.jq.enable = lib.mkEnableOption "jq module";
  };

  config = let
    hmEnabled = metadata.homeManager.enabled;
  in
    lib.mkIf cfg.enable (lib.mkMerge [
      (lib.mkIf hmEnabled {
        home-manager.users.${metadata.homeManager.username}.programs.jq.enable = true;
      })
      (lib.mkIf (!hmEnabled) {
        environment.systemPackages = [pkgs.jq];
      })
    ]);
}
