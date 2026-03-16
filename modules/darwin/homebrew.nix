# Shared nix-homebrew configuration for Darwin systems
{
  inputs,
  lib,
  config,
  ...
}:

{
  options.homebrew.ownerUser = lib.mkOption {
    type = lib.types.str;
    default = "phazonic";
    description = "User owning the Homebrew prefix";
  };

  imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

  config.nix-homebrew = {
    enable = true;
    enableRosetta = false;
    user = config.homebrew.ownerUser;
    autoMigrate = true;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
    mutableTaps = true;
  };
}
