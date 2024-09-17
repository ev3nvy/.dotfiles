{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  # Locale settings
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


  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  nix.nixPath = lib.mkForce [
    "nixpkgs=${inputs.nixpkgs}"
    # "home-manager=${inputs.home-manager}"
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.channel.enable = false;

  nixpkgs.config.allowUnfree = true;

  programs.fish.enable = true;
}
