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

    commonUserSettings = jsonc.fromJSONCWithTrailingCommas (builtins.readFile commonUserSettingsPath);
    commonKeybindings = jsonc.fromJSONCWithTrailingCommas (builtins.readFile commonKeybindingsPath);
    commonExtensions =
      builtins.map
      (x:
        lib.attrsets.getAttrFromPath
        (lib.strings.splitString "." x)
        extensionsNix.open-vsx)
      (jsonc.fromJSONC (builtins.readFile commonExtensionsPath)).extensions;
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
