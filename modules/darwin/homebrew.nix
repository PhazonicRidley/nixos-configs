# Shared nix-homebrew configuration for Darwin systems
{
  inputs,
  user,
  config,
  ...
}:

{

  imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

  config.homebrew.taps = [ "homebrew/cask" "homebrew/core" ];

  config.nix-homebrew = {
    enable = true;
    enableRosetta = false;
    user = user;
    autoMigrate = true;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
    mutableTaps = true;
  };
}
