{
  lib,
  config,
  ...
}: {
  imports = [
    ./shell.nix
  ];

  options = {
    customModule.system.enable = lib.mkEnableOption "Enable system module";
  };

  config = lib.mkIf config.customModule.system.enable {
    shell.enable = lib.mkDefault true;
  };
}
