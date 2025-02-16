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
  cfg = config.${namespace}.tools.git;
in {
  options = {
    ${namespace}.tools.git.enable = lib.mkEnableOption "git module";
  };

  config = let
    hmEnabled = metadata.homeManager.enabled;
  in
    lib.mkIf cfg.enable (lib.mkMerge [
      (lib.mkIf hmEnabled {
        home-manager.users.${metadata.homeManager.username} = {
          programs.git.enable = true;
          home.file.".gitconfig".source = ../../../../git/.gitconfig;
        };
      })
      (lib.mkIf (!hmEnabled) {
        programs.git.enable = true;
        environment.etc."gitconfig".source = lib.mkForce ../../../../git/.gitconfig;
      })
    ]);
}
