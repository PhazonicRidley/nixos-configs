# MurphyCurse home-manager configuration
# Desktop workstation with KDE Plasma
{ inputs, pkgs, ... }:

let
  optnixLib = inputs.optnix.mkLib pkgs;
in
{
  imports = [
    ../../home
    ../../modules/home-manager/plasma.nix
    ../../modules/home-manager/vscode.nix
    inputs.optnix.homeModules.optnix
    inputs.plasma-manager.homeModules.plasma-manager
  ];

  # Optnix configuration
  programs.optnix = {
    enable = true;
    settings.scopes = {
      hm = {
        description = "home-manager options for all systems";
        options-list-file = optnixLib.hm.mkOptionsListFromHMSource {
          home-manager = inputs.home-manager;
        };
      };
    };
  };

  # Nushell (murphy-curse uses nushell as default)
  programs.nushell.enable = true;
  programs.starship.enableNushellIntegration = true;

  # Desktop applications
  programs.discord.enable = true;
  programs.lutris.enable = true;

  # Machine-specific VSCode nixd options
  programs.vscode.profiles."phazonic".userSettings."nix.serverSettings" = {
    nixd = {
      formatting.command = [ "nixfmt" ];
      options = {
        nixos.expr = ''(builtins.getFlake (builtins.getEnv "NIXOS_CONFIG")).nixosConfigurations.MurphyCurse.options'';
        home-manager.expr = ''(builtins.getFlake (builtins.getEnv "NIXOS_CONFIG")).homeConfigurations."phazonic@linux".options'';
        nixpkgs.expr = "${inputs.nixpkgs}";
      };
    };
  };

  # Desktop packages
  home.packages = with pkgs; [
    kdePackages.kate
    signal-desktop
    telegram-desktop
    chromium
    google-chrome
    element-desktop
    iputils
    dnsutils
    papirus-icon-theme
  ];

  # Dynamic NIXOS_CONFIG pointing to the flake
  home.sessionVariables.NIXOS_CONFIG = toString inputs.self;
}
