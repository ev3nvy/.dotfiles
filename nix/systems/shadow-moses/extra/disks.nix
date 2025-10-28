{ username, ... }:
{
  fileSystems."/run/media/${username}/Data" = {
    device = "/dev/disk/by-uuid/7228EBB428EB758F";
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
      # allow use of chmod/chown on this NTFS drive;
      # see: https://askubuntu.com/a/92866
      # TODO: use `usermapping` instead;
      #       see https://manpages.ubuntu.com/manpages/noble/en/man8/ntfs-3g.8.html#user%20mapping
      "permissions"
      # From https://manpages.ubuntu.com/manpages/noble/en/man8/ntfs-3g.8.html#options:
      # This option prevents files, directories and extended attributes to be created with a name
      # not allowed by windows, because
      # - it contains some not allowed character,
      # - or the last character is a space or a dot,
      # - or the name is reserved.
      "windows_names"
    ];
  };
}
