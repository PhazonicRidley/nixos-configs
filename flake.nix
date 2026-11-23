{
  description = "Unified NixOS/Darwin configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko.url = "github:nix-community/disko";

    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/main";
    };

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

    # Darwin
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-darwin,
      vscode-server,
      sops-nix,
      nixos-raspberrypi,
      ...
    }@inputs:
    let
      domains = {
        com = "phazonicridley.com";
        xyz = "phazonicridley.xyz";
      };

      # Helper for standalone home-manager
      mkHome =
        {
          system,
          username ? "phazonic",
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          extraSpecialArgs = { inherit inputs username; };
          modules = [ ./home ];
        };
    in
    {
      nixosConfigurations = {
        MurphyCurse = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/murphy-curse
            inputs.nix-flatpak.nixosModules.nix-flatpak
          ];
        };

        RoboServer = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
            wanIface = "enp39s0";
            gamingVlanInfo = {
              iface = "gayming";
              net = "192.168.69.0/24";
            };
            inherit domains;
          };
          modules = [
            ./hosts/robo-server
            vscode-server.nixosModules.default
            sops-nix.nixosModules.sops
          ];
        };

        MilesPrower = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/milesprower
            sops-nix.nixosModules.sops
          ];
        };

        Aria = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs domains;
          };
          modules = [
            ./hosts/aria
            sops-nix.nixosModules.sops
          ];
        };

        # The system and home-manager use our unstable nixpkgs. The kernel and
        # firmware still come from nixos-raspberrypi's own pinned nixpkgs
        # (not followed on purpose) so they hit its binary cache instead of
        # rebuilding the kernel on every nixpkgs bump. See hosts/jamespi.
        JamesPi = nixos-raspberrypi.lib.nixosSystem {
          inherit nixpkgs;
          specialArgs = {
            inherit inputs domains;
          };
          modules = [
            {
              # RPi 3 only exposes `base`. Bluetooth reuses the board-agnostic
              # module (same file the rpi4/rpi5/rpi02 entries point at).
              # No usb-gadget-ethernet: the 3B+ micro-USB port is power-only.
              imports = with nixos-raspberrypi.nixosModules; [
                raspberry-pi-3.base
                raspberry-pi-4.bluetooth
              ];
            }
            ./hosts/jamespi
          ];
        };

      };

      darwinConfigurations = {
        Xiao = nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs;
            user = "phazonic";
          };
          modules = [ ./hosts/xiao ];
        };

        WorkComputah = nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit inputs;
            user = "madeline.schneider";
          };
          modules = [ ./hosts/work-computah ];
        };
      };

      # Standalone home-manager for arbitrary machines
      homeConfigurations = {
        "phazonic@linux" = mkHome { system = "x86_64-linux"; };
        "phazonic@darwin" = mkHome { system = "aarch64-darwin"; };
        "phazonic@linux-arm" = mkHome { system = "aarch64-linux"; };
      };
    };
}
