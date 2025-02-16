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
  cfg = config.${namespace}.system.audio;
in {
  options = {
    ${namespace}.system.audio.enable = lib.mkEnableOption "audio module";
  };

  config = lib.mkIf cfg.enable {
    # Enable sound with pipewire.
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
