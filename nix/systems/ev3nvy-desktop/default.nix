# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../shared/host.nix
    ../../modules/nixos/lanzaboote.nix
    ../../modules/nixos/nvidia.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "ev3nvy-desktop"; # Define your hostname.

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
    ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
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
  users.users.ev3nvy = {
    isNormalUser = true;
    description = "ev3nvy";
    extraGroups = ["networkmanager" "wheel"];
  };

  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    users = {
      "ev3nvy" = import ./home.nix;
    };
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
    # firewall is opened by default;
    # see: https://github.com/NixOS/nixpkgs/blob/799ba5bffed04ced7067a91798353d360788b30d/nixos/modules/programs/localsend.nix#L17-L21
    localsend.enable = true;
  };

  environment.systemPackages = with pkgs; [
    vim
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
