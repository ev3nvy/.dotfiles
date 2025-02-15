{lib, ...}: {
  options = {
    customModule.metadata.homeManagerUsername = lib.mkOption {
      type = lib.types.str;
      example = "sheldon";
      description = "The user's username.";
    };
  };
}
