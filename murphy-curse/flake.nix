{
  description = "A less basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-cli.url = "github:nix-community/nixos-cli";

    optnix.url = "sourcehut:~watersucks/optnix";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    #flake-parts.url = "github:hercules-ci/flake-parts";
  };

  # outputs =
  #   {
  #     self,
  #     flake-parts,
  #     nixpkgs,
  #     home-manager,
  #     nixos-cli,
  #     ...
  #   }@inputs:
  #   flake-parts.lib.mkFlake { inherit inputs; } {
  #     systems = [
  #       "x86_64-linux"
  #       "aarch64-linux"
  #       "aarch64-darwin"
  #     ];

  #     perSystem =
  #       { system, ... }:
  #       {
  #         _module.args = {
  #           inherit self inputs;

  #           pkgs = import nixpkgs {
  #             inherit system;
  #             config = {
  #               allowUnfree = true;
  #             };
  #           };

  #           nixosConfigurations."MurphyCurse" = nixpkgs.lib.nixosSystem {
  #             specialArgs = { inherit inputs system; };
  #             modules = [
  #               ./nixos/configuration.nix
  #               nixos-cli.nixosModules.nixos-cli
  #               inputs.optnix.nixosModules.optnix
  #             ];
  #           };

  #           # Only used for standalone hm setups
  #           homeConfigurations."phazonic" = home-manager.lib.homeManagerConfiguration {
  #             pkgs = nixpkgs.legacyPackages.${system}; # Home-manager requires 'pkgs' instance
  #             extraSpecialArgs = { inherit inputs; };
  #             modules = [
  #               ./home-manager/home.nix
  #             ];
  #           };

  #         };
  #       };
  #   };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixos-cli,
      ...
    }@inputs:
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
          nixos-cli.nixosModules.nixos-cli
          inputs.optnix.nixosModules.optnix
        ];
      };

      # Only used for standalone hm setups
      homeConfigurations."phazonic" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system}; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./home-manager/home.nix
        ];
      };

    };
}
