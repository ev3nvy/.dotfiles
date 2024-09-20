{pkgs, ...}: {
  imports = [
    ../programs/git.nix
    ../programs/vscode.nix
  ];

  home.packages = with pkgs; [
    jq
  ];
}
