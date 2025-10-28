{ ... }:
{
  # TODO: figure out how to cleanly set some settings per-system (e.g. touchpads);
  #       this requires:
  #       1. merging the two configs cleanly
  #       2. detecting if plasma manager is enabled for that system
  # TODO: is enabling plasma in system configuration still required?
  programs.plasma = {
    enable = true;

    # make the config more declarative
    # see:
    # - https://nix-community.github.io/plasma-manager/options.xhtml#opt-programs.plasma.overrideConfig
    # - https://github.com/nix-community/plasma-manager?tab=readme-ov-file#make-your-configuration-more-declarative-with-overrideconfig
    overrideConfig = true;

    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
    };

    input = {
      # name, vid and pid can be fetched from `/proc/bus/input/devices`
      # alternatively you may change the settings, apply them and read from `~/.config/kcminputrc`
      touchpads = [
        {
          enable = true;
          name = "ELAN2841:00 04F3:317C Touchpad";
          vendorId = "04f3";
          productId = "317c";
          naturalScroll = true; # why is this not default for touchpads? >:(
        }
      ];
    };

    # find widget names by ls-ing the `/run/current-system/sw/share/plasma/plasmoids/` directory
    panels = [
      {
        location = "bottom";
        widgets = [
          "org.kde.plasma.kickoff"
          "org.kde.plasma.pager"
          {
            iconTasks = {
              # these desktop files are stored in `/run/current-system/sw/share/applications/` and
              # `~/.nix-profile/share/applications/`
              launchers = [
                "applications:org.kde.dolphin.desktop"
                "applications:firefox.desktop"
                "applications:discord.desktop"
                "applications:com.mitchellh.ghostty.desktop"
              ];
            };
          }
          "org.kde.plasma.marginsseparator"
          "org.kde.plasma.systemmonitor.cpucore"
          "org.kde.plasma.systemmonitor.memory"
          "org.kde.plasma.systemmonitor.diskusage"
          "org.kde.plasma.systemmonitor.diskactivity"
          "org.kde.plasma.systemmonitor.net"
          {
            # TODO: this seems broken (possibly related: https://github.com/nix-community/plasma-manager/issues/504)
            systemTray.items = {
              shown = [
                "org.kde.plasma.clipboard"
                "org.kde.plasma.bluetooth"
                "org.kde.plasma.volume"
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.battery"
              ];
            };
          }
          "org.kde.plasma.digitalclock"
          "org.kde.plasma.showdesktop"
        ];
      }
    ];
  };
}
