{
  config,
  pkgs,
  inputs,
  username,
  homeDirectory,
  metadata,
  ...
}: {
  imports = [
    ../../programs/unfree.nix
  ];

  home = {
    inherit username homeDirectory;

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "24.05"; # Please read the comment before changing.
  };

  home.packages = with pkgs; [
    discord
    # (discord.override {
    #   withOpenASAR = true;
    #   withVencord = true;
    # })
    gh
    keepassxc
    inputs.alejandra.defaultPackage.${pkgs.system}
    inputs.nil.packages.${pkgs.system}.default
    nerd-fonts.jetbrains-mono
  ];

  services = {
    syncthing.enable = true;
  };

  home.file = {
    ".config/keepassxc/keepassxc.ini".source = config.lib.file.mkOutOfStoreSymlink "${metadata.homeManager.dotfiles}/keepassxc/keepassxc.ini";
  };

  programs = {
    # TODO: look into custom themes (mainly MaterialDarker).
    #
    # REFERENCES:
    # Uses older TextMate .tmTheme files (see https://github.com/sharkdp/bat/issues/759 for more
    # info).
    # - this repo (https://github.com/SublimeText/material-theme/blob/134916bde95a275f56fa1808586baeaf0be28ab9/schemes/Material-Theme-Darker.tmTheme)
    #   seems to contain most recent material theme for sublime text, it also includes
    #   .sublime-theme files, which could possibly be converted using this (https://github.com/trishume/syntect/issues/244#issuecomment-2480905939)
    # - this repo (https://github.com/JarvisPrestidge/vscode-material-theme) has some *.tmTheme
    #   files, but it's severely outdated and missing DarkerVesion
    # - there is also this repo that contains this json file (https://github.com/shikijs/textmate-grammars-themes/blob/b94652a9e18f89d2ed339ed6a3b88c7d480015c1/packages/tm-themes/themes/material-theme-darker.json)
    #   and references the theme here (https://github.com/shikijs/textmate-grammars-themes/blob/b94652a9e18f89d2ed339ed6a3b88c7d480015c1/packages/tm-themes/index.js#L317-L328)
    # - iterm2 version of this theme can be found here (https://github.com/mbadolato/iTerm2-Color-Schemes/blob/db227d159adc265818f2e898da0f70ef8d7b580e/schemes/MaterialDarker.itermcolors)
    #   which is used by Ghostty, there exists this script (https://gist.github.com/maxim/2903788),
    #   that converts .tmTheme to .itermcolors file (writing code that does inverse may not be too
    #   difficult?)
    bat.enable = true;
    btop.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    eza.enable = true;
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
    mpv.enable = true;
    nix-index.enable = true;
    zen-browser.enable = true;

    home-manager.enable = true;
  };
}
