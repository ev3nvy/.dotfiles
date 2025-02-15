{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (config.customModule) metadata;
in {
  options = {
    shell.enable = lib.mkEnableOption "Enable shell module.";
  };

  config = lib.mkIf config.shell.enable {
    programs = {
      fish.enable = true;

      # https://nixos.wiki/wiki/Fish
      bash.interactiveShellInit = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
        fi
      '';
    };

    home-manager.users.${metadata.homeManagerUsername} = {
      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          set fish_greeting # Disable greeting
        '';
      };
    };
  };
}
