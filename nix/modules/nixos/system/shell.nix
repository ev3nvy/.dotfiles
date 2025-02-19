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
  cfg = config.${namespace}.system.shell;
in {
  options = {
    ${namespace}.system.shell.enable = lib.mkEnableOption "shell module";
  };

  config = lib.mkIf cfg.enable {
    programs = {
      fish.enable = true;

      # https://nixos.wiki/wiki/Fish#Setting_fish_as_your_shell
      bash.interactiveShellInit = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
        fi
      '';
    };

    home-manager = lib.mkIf metadata.homeManager.enabled {
      users.${metadata.homeManager.username}.programs.fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting # Disable greeting
        '';
      };
    };
  };
}
