{ ... }:
{
  programs.git = {
    enable = true;
  };
  home.file.".gitconfig".source = ../../git/.gitconfig;
}
