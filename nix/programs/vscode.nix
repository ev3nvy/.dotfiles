{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    # TODO: figure out a way to make this work (json files have comments and trailing commas)
    # userSettings = lib.importJSON ../../vscodium/User/settings.json;
    # keybindings = lib.importJSON ../../vscodium/User/keybindings.json;

    # TODO: parse extensions from recommendations: grep -o '^[^/]*' .vscode/extensions.json | jq '.recommendations'
    # extensions = with pkgs.vscode-extensions; recommended-extensions;
  };

  home.file = {
    # TODO: use `languageSnippets`/`globalSnippets` instead
    ".config/VSCodium/User/snippets".source = ../../vscodium/User/snippets;
    ".config/VSCodium/User/keybindings.json".source = ../../vscodium/User/keybindings.json;
    ".config/VSCodium/User/settings.json".source = ../../vscodium/User/settings.json;
  };
}
