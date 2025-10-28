{
  metadata,
  namespace,
  ...
}:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.${namespace}.system.locale;
in
{
  options = {
    ${namespace}.system.locale.enable = lib.mkEnableOption "locale module";
  };

  config = lib.mkIf cfg.enable {
    time.timeZone = "Europe/Ljubljana";

    i18n.defaultLocale = "en_GB.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "sl_SI.UTF-8";
      LC_IDENTIFICATION = "sl_SI.UTF-8";
      LC_MEASUREMENT = "sl_SI.UTF-8";
      LC_MONETARY = "sl_SI.UTF-8";
      LC_NAME = "sl_SI.UTF-8";
      LC_NUMERIC = "sl_SI.UTF-8";
      LC_PAPER = "sl_SI.UTF-8";
      LC_TELEPHONE = "sl_SI.UTF-8";
      LC_TIME = "sl_SI.UTF-8";
    };

    services.xserver.xkb = {
      layout = "gb";
      variant = "";
    };
    console.keyMap = "uk";
  };
}
