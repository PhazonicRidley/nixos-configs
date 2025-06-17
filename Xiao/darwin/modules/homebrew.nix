inputs@{lib, nix-homebrew, homebrew-core, homebrew-cask, ...}:
{
  imports = [nix-homebrew.darwinModules.nix-homebrew];

  nix-homebrew = {
    # Install Homebrew under the default prefix
    enable = true;

    # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
    enableRosetta = lib.mkDefault true;

    # User owning the Homebrew prefix
    user = "phazonic";
    
    autoMigrate = true;

    # Optional: Declarative tap management
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
    };

    # Optional: Enable fully-declarative tap management
    #
    # With mutableTaps disabled, taps can no longer be added imperatively with `brew tap`.
    mutableTaps = false;
  };
}

        