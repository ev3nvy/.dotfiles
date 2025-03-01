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

    userPath = ../../../../vscodium/User;
    commonUserSettingsPath = "${userPath}/settings.json";
    commonKeybindingsPath = "${userPath}/keybindings.json";
    commonExtensionsPath = "${userPath}/extension-list.jsonc";

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
    lib.mkIf cfg.enable (lib.mkMerge [
      (lib.mkIf hmEnabled {
        home-manager.users.${metadata.homeManager.username}.programs.vscode = {
          enable = true;
          package = pkgs.vscodium;

          profiles = let
            profilesFolder = "${userPath}/profiles";

            profileList = folder: let
              folderItems = folder: builtins.readDir folder;

              # NOTE: this ignores symlinks
              filterFiles = folder: lib.filterAttrs (name: value: value == "regular") (folderItems folder);
              filterFolders = folder: lib.filterAttrs (name: value: value == "directory") (folderItems folder);

              profileUserSettingsPath = folder: name: "${folder}/${name}/settings.partial.jsonc";
              profileKeybindingsPath = folder: name: "${folder}/${name}/keybindings.partial.jsonc";
              profileExtensionsPath = folder: name: "${folder}/${name}/extension-list.jsonc";
              profileLanguageSnippetsPath = folder: name: "${folder}/${name}/snippets";

              parseCustomUserSettings = path: (jsonc.fromJSONC (builtins.readFile path)).settings;
              parseCustomKeybindings = path: (jsonc.fromJSONC (builtins.readFile path)).keybindings;
              parseLanguageSnippets = path: lib.mapAttrs (name: value: lib.importJSON "${path}/${name}") (filterFiles path);

              customUserSettings = folder: name: let
                path = profileUserSettingsPath folder name;
              in
                lib.optionalAttrs (builtins.pathExists path) (parseCustomUserSettings path);
              customKeybindings = folder: name: let
                path = profileKeybindingsPath folder name;
              in
                lib.optionals (builtins.pathExists path) (parseCustomKeybindings path);
              customExtensions = folder: name: let
                path = profileExtensionsPath folder name;
              in
                lib.optionals (builtins.pathExists path) (parseExtensionList path);
              customLanguageSnippets = folder: name: let
                path = profileLanguageSnippetsPath folder name;
              in
                lib.optionalAttrs (builtins.pathExists path) (parseLanguageSnippets path);

              profileList = folder:
                lib.mapAttrs (name: value: {
                  userSettings = commonUserSettings // customUserSettings folder name;
                  keybindings = commonKeybindings ++ customKeybindings folder name;

                  extensions = commonExtensions ++ customExtensions folder name;

                  languageSnippets = customLanguageSnippets folder name;
                }) (filterFolders folder);
            in
              profileList folder;
          in
            {
              default = {
                userSettings = commonUserSettings;
                keybindings = commonKeybindings;

                extensions = commonExtensions;

                enableUpdateCheck = false;
                enableExtensionUpdateCheck = false;
              };
            }
            // (profileList profilesFolder);
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
