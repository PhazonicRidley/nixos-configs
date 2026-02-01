{
  description = "A less basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager = {
	url = "github:nix-community/home-manager";
	inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: 
  let
	system = "x86_64-linux";
	
	pkgs = import nixpkgs {
		inherit system;
		config = {
			allowUnfree = true;
		};
	};
  in 
  {
	nixosConfigurations."MurphyCurse" = nixpkgs.lib.nixosSystem {
		specialArgs = { inherit inputs system; };
		modules = [
			./nixos/configuration.nix
		];
	};
	
	homeConfigurations."phazonic" = home-manager.lib.homeManagerConfiguration {
       		pkgs = nixpkgs.legacyPackages.${system}; # Home-manager requires 'pkgs' instance
        	extraSpecialArgs = {inherit inputs;};
        	modules = [./home-manager/home.nix];
      	};

  };
}
