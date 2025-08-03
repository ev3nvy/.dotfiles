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

    dotfilesUserPath = "${metadata.homeManager.dotfiles}/vscodium/User";

    userPath = ../../../../vscodium/User;
    commonExtensionsPath = "${userPath}/extension-list.jsonc";

    parseExtensionList = path: let
      extensionListJson = jsonc.fromJSONC (builtins.readFile path);
      extensionStringList = extensionListJson.extensions;
      mapStringListToAttrs =
        builtins.map (x: lib.attrsets.getAttrFromPath (lib.strings.splitString "." x) extensionsNix.open-vsx);
    in
      mapStringListToAttrs extensionStringList;

    commonExtensions = parseExtensionList commonExtensionsPath;
  in
    lib.mkIf cfg.enable (lib.mkMerge [
      (lib.mkIf hmEnabled {
        home-manager.users.${metadata.homeManager.username} = {config, ...}: {
          programs.vscode = {
            enable = true;
            package = pkgs.vscodium;

            profiles = let
              folderItems = folder: builtins.readDir folder;

              # NOTE: this ignores symlinks
              filterFiles = folder: lib.filterAttrs (name: value: value == "regular") (folderItems folder);
              filterFolders = folder: lib.filterAttrs (name: value: value == "directory") (folderItems folder);

              parseLanguageSnippets = path: lib.mapAttrs (name: value: lib.importJSON "${path}/${name}") (filterFiles path);

              customExtensions = folder: name: let
                path = "${folder}/${name}/extension-list.jsonc";
              in
                lib.optionals (builtins.pathExists path) (parseExtensionList path);
              customLanguageSnippets = folder: name: let
                path = "${folder}/${name}/snippets";
              in
                lib.optionalAttrs (builtins.pathExists path) (parseLanguageSnippets path);

              profileList = dotfilesFolder: relativeFolder:
                lib.mapAttrs (name: _: {
                  userSettings = let
                    # required for builtins.pathExists
                    relativePath = "${relativeFolder}/${name}/settings.json";
                    path = "${dotfilesFolder}/${name}/settings.json";
                  in
                    lib.mkIf (builtins.pathExists relativePath) (config.lib.file.mkOutOfStoreSymlink path);

                  keybindings = let
                    # required for builtins.pathExists
                    relativePath = "${relativeFolder}/${name}/keybindings.json";
                    path = "${dotfilesFolder}/${name}/keybindings.json";
                  in
                    lib.mkIf (builtins.pathExists relativePath) (config.lib.file.mkOutOfStoreSymlink path);

                  extensions = commonExtensions ++ customExtensions relativeFolder name;

                  languageSnippets = customLanguageSnippets relativeFolder name;
                }) (filterFolders relativeFolder);
            in
              {
                default = {
                  userSettings = config.lib.file.mkOutOfStoreSymlink "${dotfilesUserPath}/settings.json";
                  keybindings = config.lib.file.mkOutOfStoreSymlink "${dotfilesUserPath}/keybindings.json";

                  extensions = commonExtensions;
                };
              }
              // (profileList "${dotfilesUserPath}/profiles" "${userPath}/profiles");
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
