inputs@{ lib, home-manager, ... }:
{
  imports = [ home-manager.darwinModules.home-manager ];

  home-manager = {
    useGlobalPkgs = lib.mkDefault true;
    useUserPackages = lib.mkDefault true;
    users.phazonic = lib.mkDefault ../hosts/Xiao/home.nix;
  };
}
