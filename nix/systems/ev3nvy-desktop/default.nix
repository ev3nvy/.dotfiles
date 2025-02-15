# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  lib,
  pkgs,
  username,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../shared/host.nix
    ../../modules/nixos/system/nvidia.nix
    ../../modules/nixos/programs
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  # Enable networking
  networking.networkmanager.enable = true;

  # https://github.com/systemd/systemd/issues/33412
  systemd.units."dev-tpmrm0.device".enable = false;

  networking.useDHCP = lib.mkForce false;
  networking.interfaces."enp24s0".ipv4.addresses = [
    {
      address = "192.168.1.2";
      prefixLength = 24;
    }
  ];
  networking.defaultGateway = "192.168.1.254";
  networking.nameservers = [
    "1.1.1.1" # cloudflare dns
    "8.8.8.8" # google dns as backup
  ];

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = ["networkmanager" "wheel"];
  };

  services.pcscd.enable = true;

  programs = {
    # https://nixos.wiki/wiki/Fish
    bash = {
      interactiveShellInit = ''
        if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
        fi
      '';
    };
    firefox.enable = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
