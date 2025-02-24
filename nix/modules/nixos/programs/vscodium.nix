{
  metadata,
  namespace,
  ...
}: {
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.${namespace}.programs.vscodium;

  jsonc = import ../../../lib/jsonc-with-trailing-commas.nix {inherit lib;};
in {
  options = {
    ${namespace}.programs.vscodium.enable = lib.mkEnableOption "VSCodium module";
  };

  config = let
    hmEnabled = metadata.homeManager.enabled;

    extensionsNix = inputs.nix-vscode-extensions.extensions.${pkgs.system};

    commonUserSettingsPath = ../../../../vscodium/User/settings.json;
    commonKeybindingsPath = ../../../../vscodium/User/keybindings.json;
    commonExtensionsPath = ../../../../vscodium/User/extension-list.jsonc;

    profileUserSettingsPath = name: ../../../../vscodium/User/profiles/${name}/settings.partial.jsonc;
    profileExtensionsPath = name: ../../../../vscodium/User/profiles/${name}/extension-list.jsonc;

    parseExtensionList = path: let
      extensionListJson = jsonc.fromJSONC (builtins.readFile path);
      extensionStringList = extensionListJson.extensions;
      mapStringListToAttrs =
        builtins.map (x: lib.attrsets.getAttrFromPath (lib.strings.splitString "." x) extensionsNix.open-vsx);
    in
      mapStringListToAttrs extensionStringList;

    commonUserSettings = jsonc.fromJSONCWithTrailingCommas (builtins.readFile commonUserSettingsPath);
    commonKeybindings = jsonc.fromJSONCWithTrailingCommas (builtins.readFile commonKeybindingsPath);
    commonExtensions = parseExtensionList commonExtensionsPath;
  in
    # TODO: investigate if we can read the `.dotfiles/vscodium/User/profiles` dir and do all of
    #       this automagically
    lib.mkIf cfg.enable (lib.mkMerge [
      (lib.mkIf hmEnabled {
        home-manager.users.${metadata.homeManager.username}.programs.vscode = {
          enable = true;
          package = pkgs.vscodium;

          profiles = {
            default = {
              userSettings = commonUserSettings;
              keybindings = commonKeybindings;
              extensions = commonExtensions;

              enableUpdateCheck = false;
              enableExtensionUpdateCheck = false;
            };
            bash = {
              userSettings = commonUserSettings;
              keybindings = commonKeybindings;

              extensions = commonExtensions ++ parseExtensionList (profileExtensionsPath "bash");

              languageSnippets = {
                shellscript = lib.importJSON ../../../../vscodium/User/profiles/bash/snippets/shellscript.json;
              };
            };
            nix = {
              userSettings =
                commonUserSettings
                // (jsonc.fromJSONCWithTrailingCommas
                  (builtins.readFile (profileUserSettingsPath "nix")))
                .settings;
              keybindings = commonKeybindings;

              extensions = commonExtensions ++ parseExtensionList (profileExtensionsPath "nix");
            };
            notes = {
              userSettings =
                commonUserSettings
                // (jsonc.fromJSONCWithTrailingCommas
                  (builtins.readFile (profileUserSettingsPath "notes")))
                .settings;
              keybindings = commonKeybindings;

              extensions = commonExtensions ++ parseExtensionList (profileExtensionsPath "notes");

              languageSnippets = {
                markdown = lib.importJSON ../../../../vscodium/User/profiles/notes/snippets/markdown.json;
              };
            };
            python = {
              userSettings =
                commonUserSettings
                // (jsonc.fromJSONCWithTrailingCommas
                  (builtins.readFile (profileUserSettingsPath "python")))
                .settings;
              keybindings = commonKeybindings;

              extensions = commonExtensions ++ parseExtensionList (profileExtensionsPath "python");
            };
            rust = {
              userSettings =
                commonUserSettings
                // (jsonc.fromJSONCWithTrailingCommas
                  (builtins.readFile (profileUserSettingsPath "rust")))
                .settings;
              keybindings = commonKeybindings;

              extensions = commonExtensions ++ parseExtensionList (profileExtensionsPath "rust");
            };
            web = {
              userSettings =
                commonUserSettings
                // (jsonc.fromJSONCWithTrailingCommas
                  (builtins.readFile (profileUserSettingsPath "web")))
                .settings;
              keybindings = commonKeybindings;

              extensions = commonExtensions ++ parseExtensionList (profileExtensionsPath "web");
            };
          };
        };
      })
      # TODO: improve this
      (lib.mkIf (!hmEnabled) {
        environment.systemPackages = [
          (pkgs.vscode-with-extensions.override {
            vscode = pkgs.vscodium;
            vscodeExtensions = commonExtensions;
          })
        ];
      })
    ]);
}
