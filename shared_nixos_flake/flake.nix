{
  description = "Unified NixOS/Darwin configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NixOS tools
    nixos-cli.url = "github:nix-community/nixos-cli";
    optnix.url = "sourcehut:~watersucks/optnix";

    # Desktop (MurphyCurse)
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # Darwin (Xiao)
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = { url = "github:homebrew/homebrew-core"; flake = false; };
    homebrew-cask = { url = "github:homebrew/homebrew-cask"; flake = false; };
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = { nixpkgs, home-manager, nix-darwin, ... }@inputs: let
    # Helper for standalone home-manager
    mkHome = { system, username ? "phazonic" }: home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${system};
      extraSpecialArgs = { inherit inputs username; };
      modules = [ ./home ];
    };
  in {
    nixosConfigurations = {
      MurphyCurse = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/murphy-curse ];
      };

      RoboServer = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          domains = {
            com = "phazonicridley.com";
            xyz = "phazonicridley.xyz";
          };
        };
        modules = [ ./hosts/robo-server ];
      };
    };

    darwinConfigurations.Xiao = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit inputs; };
      modules = [ ./hosts/xiao ];
    };

    # Standalone home-manager for arbitrary machines
    homeConfigurations = {
      "phazonic@linux" = mkHome { system = "x86_64-linux"; };
      "phazonic@darwin" = mkHome { system = "aarch64-darwin"; };
      "phazonic@linux-arm" = mkHome { system = "aarch64-linux"; };
    };
  };
}
