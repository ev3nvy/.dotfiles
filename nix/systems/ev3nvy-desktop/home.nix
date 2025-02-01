{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../common.nix
    ../../programs/unfree.nix
  ];
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
    (discord.override {
      withOpenASAR = true;
      withVencord = true;
    })
    gh
    keepassxc
    inputs.alejandra.defaultPackage.${pkgs.system}
    inputs.nil.packages.${pkgs.system}.default
    pkgs.nerd-fonts.jetbrains-mono
  ];

  services = {
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 3600;
      pinentryPackage = pkgs.pinentry-qt;
    };
    kdeconnect = {
      enable = true;
      package = pkgs.kdePackages.kdeconnect-kde;
    };
    syncthing.enable = true;
  };

  home.file = {
    ".config/keepassxc/keepassxc.ini".source = ../../../keepassxc/keepassxc.ini;
  };

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    eza.enable = true;
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
    };
    ghostty = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      settings = {
        auto-update = "check";
        theme = "MaterialDarker";
        font-family = "JetBrainsMono Nerd Font";
        font-size = 12;
      };
    };
    gpg.enable = true;
    home-manager.enable = true;
  };
}
