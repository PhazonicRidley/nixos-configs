# WorkComputah - Work computer configuration I have for macbook pro
{
  inputs,
  pkgs,
  ...
}:
let
  primaryUser = "madeline.schneider";
in
{
  imports = [
    ../../modules/darwin/base.nix
    inputs.home-manager.darwinModules.home-manager
  ];

  darwinBase = {
    enable = true;
    inherit primaryUser;
    hostPlatform = "aarch64-darwin";

    additionalBrews = [
      "colima"
      "docker"
      "docker-compose"
      "qemu"
      "lima-additional-guestagents"
    ];

    additionalCasks = [
      "saleae-logic"
      "obsidian"
      "utm"
    ];

  };

  # Hostname
  networking.hostName = "WorkComputah";

  # User. programs.zsh.enable puts this zsh on PATH and in /etc/shells.
  programs.zsh.enable = true;
  users.users."madeline.schneider" = {
    home = "/Users/madeline.schneider";
    shell = pkgs.zsh;
  };

  # Home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users."${primaryUser}" = import ./home.nix;
    extraSpecialArgs = {
      inherit inputs;
      username = primaryUser;
    };
    sharedModules = [
      inputs.mac-app-util.homeManagerModules.default
    ];
  };

  # Nix cache settings
  nix.settings = {
    substituters = [
      "https://artifact-s3-gateway.int.n7k.io/n7k-nix-cache?priority=20"
      "https://cache.nixos.org?priority=40"
    ];
    trusted-public-keys = [
      "nix-cache.infra.n7k.io-0:WyML6bRQeGqxs/1iSoQrlMuooDlxG15rgjuo7Elmpf4="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    trusted-users = [
      "root"
      "@admin"
      "madeline.schneider"
    ];
  };
}
