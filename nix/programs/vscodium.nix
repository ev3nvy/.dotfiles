{
  lib,
  pkgs,
  config,
  inputs,
  ...
}: let
  cfg = config.programs.vscodium;

  extensionsNix = pkgs.vscode-extensions;
  extensionsNixFlake = inputs.nix-vscode-extensions.extensions.${pkgs.system};

  # TODO: use profiles once implemented (https://github.com/nix-community/home-manager/issues/3822)
  # TODO: this is also defined in ".vscode/extensions.json"; move to single file and read from there
  generalExtensions =
    (with extensionsNix; [
      albymor.increment-selection
      editorconfig.editorconfig
      equinusocio.vsc-material-theme
      mkhl.direnv
      pkief.material-icon-theme
      ritwickdey.liveserver
      usernamehw.errorlens
      waderyan.gitblame
    ])
    ++ (with extensionsNixFlake.open-vsx; [
      earshinov.simple-alignment
      phil294.git-log--graph
      reduckted.vscode-gitweblinks
      wakatime.vscode-wakatime
    ]);
  bashExtensions = with extensionsNix; [
    timonwong.shellcheck
  ];
  clangExtensions =
    (with extensionsNix; [
      llvm-vs-code-extensions.vscode-clangd
      xaver.clang-format
    ])
    ++ (with extensionsNixFlake.open-vsx; [
      notskm.clang-tidy
    ]);
  cssExtensions = with extensionsNixFlake.open-vsx; [
    pranaygp.vscode-css-peek
  ];
  excalidrawExtensions = with extensionsNixFlake.open-vsx; [
    pomdtr.excalidraw-editor
  ];
  flatbuffersExtensions = with extensionsNixFlake.open-vsx; [
    floxay.vscode-flatbuffers
  ];
  javascriptExtensions = with extensionsNixFlake.open-vsx; [
    biomejs.biome
  ];
  nixExtensions = with extensionsNix; [
    jnoortheen.nix-ide
    kamadorueda.alejandra
  ];
  pythonExtensions =
    (with extensionsNix; [
      charliermarsh.ruff
      ms-python.debugpy
      ms-python.python
    ])
    ++ (with extensionsNixFlake.open-vsx; [
      ms-python.mypy-type-checker
    ]);
  rustExtensions = with extensionsNix;
    [
      rust-lang.rust-analyzer
      serayuzgur.crates
    ]
    ++ tomlExtensions;
  tomlExtensions = with extensionsNix; [
    tamasfe.even-better-toml
  ];
in {
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
        # TODO: figure out a way to make this work (json files have comments and trailing commas)
        # userSettings = lib.importJSON ../../vscodium/User/settings.json;
        # keybindings = lib.importJSON ../../vscodium/User/keybindings.json;

        # TODO: parse extensions from recommendations: grep -o '^[^/]*' .vscode/extensions.json | jq '.recommendations'
        extensions = generalExtensions;
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

    home.file = {
      # TODO: use `languageSnippets`/`globalSnippets` instead
      ".config/VSCodium/User/snippets".source = ../../vscodium/User/snippets;
      ".config/VSCodium/User/keybindings.json".source = ../../vscodium/User/keybindings.json;
      ".config/VSCodium/User/settings.json".source = ../../vscodium/User/settings.json;
    };
  };
}
