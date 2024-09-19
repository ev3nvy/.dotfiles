{ config, pkgs, lib, ... }:

{
  home.username = "ev3nvy";
  home.homeDirectory = "/home/ev3nvy";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  home.packages = with pkgs; [
    discord
    vscodium
    git
    gh
    keepassxc
  ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "discord"
  ];

  services.syncthing.enable = true;

  home.file = {
    ".gitconfig".source = ../../../git/.gitconfig;
    ".config/keepassxc/keepassxc.ini".source = ../../../keepassxc/keepassxc.ini;
    ".config/VSCodium/User/snippets".source = ../../../vscodium/User/snippets;
    ".config/VSCodium/User/keybindings.json".source = ../../../vscodium/User/keybindings.json;
    ".config/VSCodium/User/settings.json".source = ../../../vscodium/User/settings.json;
  };

  programs.home-manager.enable = true;
}
