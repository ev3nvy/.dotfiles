{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  cfg = config.programs.vscodium;

  jsonc = import ../lib/jsonc-with-trailing-commas.nix { inherit lib; };

  extensionsNix = inputs.nix-vscode-extensions.extensions.${pkgs.system};

  # TODO: use profiles once implemented (https://github.com/nix-community/home-manager/issues/3822)
  # TODO: this is also defined in ".vscode/extensions.json"; move to single file and read from there
  generalExtensions = with extensionsNix.open-vsx; [
    albymor.increment-selection
    earshinov.simple-alignment
    editorconfig.editorconfig
    mkhl.direnv
    phil294.git-log--graph
    pkief.material-icon-theme
    reduckted.vscode-gitweblinks
    ritwickdey.liveserver
    t3dotgg.vsc-material-theme-but-i-wont-sue-you
    usernamehw.errorlens
    waderyan.gitblame
    wakatime.vscode-wakatime

    extensionsNix.vscode-marketplace.danprince.vsnetrw
  ];
  bashExtensions = with extensionsNix.open-vsx; [
    timonwong.shellcheck
  ];
  clangExtensions = with extensionsNix.open-vsx; [
    llvm-vs-code-extensions.vscode-clangd
    notskm.clang-tidy
    xaver.clang-format
  ];
  cssExtensions = with extensionsNix.open-vsx; [
    pranaygp.vscode-css-peek
  ];
  excalidrawExtensions = with extensionsNix.open-vsx; [
    pomdtr.excalidraw-editor
  ];
  flatbuffersExtensions = with extensionsNix.open-vsx; [
    floxay.vscode-flatbuffers
  ];
  javascriptExtensions = with extensionsNix.open-vsx; [
    biomejs.biome
  ];
  nixExtensions = with extensionsNix.open-vsx; [
    jnoortheen.nix-ide
  ];
  pythonExtensions = with extensionsNix.open-vsx; [
    charliermarsh.ruff
    ms-python.debugpy
    ms-python.mypy-type-checker
    ms-python.python
  ];
  rustExtensions =
    with extensionsNix.open-vsx;
    [
      barbosshack.crates-io
      rust-lang.rust-analyzer
    ]
    ++ tomlExtensions;
  tomlExtensions = with extensionsNix.open-vsx; [
    tamasfe.even-better-toml
  ];
in
{
  options.programs.vscodium = {
    enable = lib.mkEnableOption "VSCodium with my settings and extensions";

    extensions = {
      bash.enable = lib.mkEnableOption "bash specific extensions";
      clang.enable = lib.mkEnableOption "Clang specific extensions";
      css.enable = lib.mkEnableOption "CSS specific extensions";
      excalidraw.enable = lib.mkEnableOption "Excalidraw specific extensions";
      flatbuffers.enable = lib.mkEnableOption "Flatbuffers specific extensions";
      javascript.enable = lib.mkEnableOption "JavaScript specific extensions";
      nix.enable = lib.mkEnableOption "Nix specific extensions";
      python.enable = lib.mkEnableOption "Python specific extensions";
      rust.enable = lib.mkEnableOption "Rust specific extensions";
      toml.enable = lib.mkEnableOption "TOML specific extensions";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = lib.mkMerge [
      {
        enable = true;
        package = pkgs.vscodium;

        userSettings = jsonc.fromJSONCWithTrailingCommas (
          builtins.readFile ../../vscodium/User/settings.json
        );
        keybindings = jsonc.fromJSONCWithTrailingCommas (
          builtins.readFile ../../vscodium/User/keybindings.json
        );

        # TODO: parse extensions from recommendations: grep -o '^[^/]*' .vscode/extensions.json | jq '.recommendations'
        extensions = generalExtensions;

        languageSnippets = {
          markdown = lib.importJSON ../../vscodium/User/snippets/markdown.json;
          shellscript = lib.importJSON ../../vscodium/User/snippets/shellscript.json;
        };
      }
      (lib.mkIf cfg.extensions.bash.enable {
        extensions = bashExtensions;
      })
      (lib.mkIf cfg.extensions.clang.enable {
        extensions = clangExtensions;
      })
      (lib.mkIf cfg.extensions.css.enable {
        extensions = cssExtensions;
      })
      (lib.mkIf cfg.extensions.excalidraw.enable {
        extensions = excalidrawExtensions;
      })
      (lib.mkIf cfg.extensions.flatbuffers.enable {
        extensions = flatbuffersExtensions;
      })
      (lib.mkIf cfg.extensions.javascript.enable {
        extensions = javascriptExtensions;
      })
      (lib.mkIf cfg.extensions.nix.enable {
        extensions = nixExtensions;
      })
      (lib.mkIf cfg.extensions.python.enable {
        extensions = pythonExtensions;
      })
      (lib.mkIf cfg.extensions.rust.enable {
        extensions = rustExtensions;
      })
      (lib.mkIf cfg.extensions.toml.enable {
        extensions = tomlExtensions;
      })
    ];
  };
}
