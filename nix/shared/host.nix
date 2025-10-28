{
  lib,
  inputs,
  ...
}:
{
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  nix.nixPath = lib.mkForce [
    "nixpkgs=${inputs.nixpkgs}"
    "home-manager=${inputs.home-manager}"
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.channel.enable = false;
}
