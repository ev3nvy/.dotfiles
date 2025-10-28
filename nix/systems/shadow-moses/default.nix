{
  pkgs,
  username,
  modulesNamespace,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./extra
    ../../shared/host.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  # TODO: is this mutually exclusive with plasma-manager?
  services.desktopManager.plasma6.enable = true;

  hardware.bluetooth.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    description = username;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  services.pcscd.enable = true;

  ${modulesNamespace} = {
    cli.enable = true;
    services.enable = true;
    system.enable = true;
    tools.enable = true;
  };

  programs = {
    firefox.enable = true;
    # I make my ssh keys available using keepassxc
    # see: https://discourse.nixos.org/t/how-to-set-up-a-system-wide-ssh-agent-that-would-work-on-all-terminals/14156/11
    ssh.startAgent = true;
  };

  environment.systemPackages = with pkgs; [
    # needs to be installed as a system package
    # see: https://discourse.nixos.org/t/resolved-launching-gparted/35174/7
    gparted
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
