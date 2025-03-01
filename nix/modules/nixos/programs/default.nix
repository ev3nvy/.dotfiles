{
  metadata,
  namespace,
  ...
}: let
  args = {inherit metadata namespace;};
in
  {
    config,
    lib,
    ...
  }: let
    cfg = config.${namespace}.programs;
  in {
    imports = [
      (import ./vscodium.nix args)
    ];

    options = {
      ${namespace}.programs.enable = lib.mkEnableOption "programs module";
    };

    config = lib.mkIf cfg.enable {
      ${namespace}.programs.vscodium.enable = lib.mkDefault true;

      programs = {
        # I'd like to have vim always available, so I define it here
        vim.enable = true;

        # next few packages are enabled here, due to various home manager limitations

        ## home-manager cannot open firewall ports

        ### firewall is opened by default;
        ### see: https://github.com/NixOS/nixpkgs/blob/0b73e36b1962620a8ac551a37229dd8662dac5c8/nixos/modules/programs/kdeconnect.nix#L12-L13
        kdeconnect.enable = true;

        ### firewall is opened by default;
        ### see: https://github.com/NixOS/nixpkgs/blob/0b73e36b1962620a8ac551a37229dd8662dac5c8/nixos/modules/programs/localsend.nix#L17-L21
        localsend.enable = true;
      };
    };
  }
