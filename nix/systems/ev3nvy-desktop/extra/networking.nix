_: {
  networking = {
    interfaces."enp24s0" = {
      name = "eth0";
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "192.168.1.2";
          prefixLength = 24;
        }
      ];
    };

    defaultGateway = "192.168.1.254";
    nameservers = [
      # respect router dns settings
      "192.168.1.254"
      # cloudflare dns as backup
      "1.1.1.1"
    ];
  };
}
