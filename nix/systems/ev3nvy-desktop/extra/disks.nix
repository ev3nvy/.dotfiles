{username, ...}: {
  fileSystems."/run/media/${username}/Other" = {
    device = "/dev/disk/by-uuid/88006F63006F576A";
    # required, otherwise disk is mounted as read-only
    fsType = "ntfs-3g";
    options = [
      # From https://nixos.org/manual/nixos/stable/index.html#ch-file-systems:
      # > System startup will fail if any of the filesystems fails to mount, dropping you to the
      # > emergency shell. You can make a mount asynchronous and non-critical by adding
      # > `options = [ "nofail" ];`.
      "nofail"
      # allows mounting this NTFS drive in R/W mode (use `id` to get `uid`);
      # see https://nixos.wiki/wiki/NTFS
      "rw"
      "uid=1000"
      # proper permissions (don't make everything executable);
      # see https://github.com/NixOS/nixpkgs/issues/55807#issuecomment-463959647
      "dmask=007"
      "fmask=117"
    ];
  };
}
