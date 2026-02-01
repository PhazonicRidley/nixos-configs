{
  description = "My configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Darwin exclusive inputs
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # Manage taps and casks via nix-darwin
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      ...
    }:
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Madelines-MacBook-Pro
      # Necessary for using flakes on this system.

      darwinConfigurations."Xiao" = nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit self;
          inherit (nixpkgs) lib;
          inherit (inputs) nix-homebrew homebrew-core homebrew-cask;
          inherit home-manager;
        };

        modules = [
          darwin/hosts/Xiao/configuration.nix
          darwin/modules/homebrew.nix
          darwin/modules/home-manager.nix
        ];
      };
    };
}
