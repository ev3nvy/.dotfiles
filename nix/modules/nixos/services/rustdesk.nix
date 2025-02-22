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
  cfg = config.${namespace}.services.rustdesk;
in {
  options = {
    ${namespace}.services.rustdesk = {
      enable = lib.mkEnableOption "rustdesk module";
      gui.enable = lib.mkEnableOption "rustdesk gui";
    };
  };

  config = let
    hmEnabled = metadata.homeManager.enabled;
  in
    lib.mkIf cfg.enable (lib.mkMerge [
      {
        services = {
          rustdesk-server = {
            enable = true;
            openFirewall = true;
            signal.relayHosts = ["127.0.0.1"];
          };

          # this is to allow unattended access (wayland has a remote desktop popup on reboot)
          # see: https://github.com/rustdesk/rustdesk/discussions/10016
          # TODO: switch back to wayland, once I buy a KVM
          displayManager.defaultSession = "plasmax11";
        };
      }
      (lib.mkIf (cfg.gui.enable && hmEnabled) {
        home-manager.users.${metadata.homeManager.username}.home.packages = [pkgs.rustdesk-flutter];
      })
      (lib.mkIf (cfg.gui.enable && !hmEnabled) {
        environment.systemPackages = [pkgs.rustdesk-flutter];
      })
    ]);
}
