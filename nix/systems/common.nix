_: {
  imports = [
    ../modules/nixos/programs/vscodium.nix
  ];

  programs.vscodium = {
    enable = true;

    extensions = {
      bash.enable = true;
      clang.enable = true;
      css.enable = true;
      excalidraw.enable = true;
      flatbuffers.enable = true;
      javascript.enable = true;
      nix.enable = true;
      python.enable = true;
      rust.enable = true;
      toml.enable = true;
    };
  };
}
