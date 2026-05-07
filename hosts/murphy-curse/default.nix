# MurphyCurse - Desktop workstation with NVIDIA and KDE Plasma
{
  inputs,
  pkgs,
  options,
  ...
}:

let
  optnixLib = inputs.optnix.mkLib pkgs;
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/desktop-plasma.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/avahi.nix
    inputs.nixos-cli.nixosModules.nixos-cli
    inputs.optnix.nixosModules.optnix
  ];

  # Hostname
  networking.hostName = "MurphyCurse";

  # Use latest kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "usbcore.autosuspend=-1" ];

  # User configuration
  users.defaultUserShell = pkgs.nushell;
  users.users.phazonic = {
    isNormalUser = true;
    description = "Madeline Schneider";
    shell = pkgs.nushell;
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "dialout"
    ];
    packages = [ pkgs.nushell ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDlWOd2WgZqVrbSn+1aNJszcFLyLLDAoimjBhfjhI7IkLeztUw5Bq21lUCgX6NbSpwQpXcsu5BGVLdpUn5rctsheBG7sNnf8PUAsKC3eEosBq1Z/If/uFVKe+KIIHDbALYWtONS51DRM2nLQ/FuKcx0MTVB7Fwwtp82otRWfWD7CjDD9Eq1O+wvhWYDdlC66KK+6j2SJNDYh4D4CHm2PlAQjoRyFiPaylmXTPZV8M8LXcnir6s8wI/DH2EuDJu8a0UOYudUHnzfi+xhysSLoS21/ZP3aLc3yHFbSUTBtwRi27c6LyagO/24Q8RV6tB2PyMnklJC3qCkphmHJ39+CBDCIcgx6WjmV6NTVLuWWJ/qsf0NUW4chcRd1LaQoFgiFroaIRfgajCZqF4boshK9x8NsPoaIFg/f0YqyxEWZj7q6MEJ2O2Nyx92WHIeBWhahTQQPGM6/2P8CwAEcbtOKKEUX4E7+1Q4+3SZXT1zjbNA0zDf+ebhsiVSgXq83oFJauE= phazonic@Madelines-Laptop.local"
    ];
  };

  # Serial device support
  networking.modemmanager.enable = true;
  services.brltty.enable = false;
  services.udev.extraRules = ''
    KERNEL=="ttyUSB[0-9]*", MODE="0666"
    KERNEL=="ttyACM[0-9]*", MODE="0666"
  '';

  # NixOS CLI
  services.nixos-cli = {
    enable = true;
    config = { };
  };

  # optnix configuration
  programs.optnix = {
    enable = true;
    settings = {
      scopes = {
        murphy-curse = {
          options-list-file = optnixLib.mkOptionsList { inherit options; };
          evaluator = "nix eval ${inputs.self}#nixosConfigurations.MurphyCurse.config.{{ .Option }}";
        };
      };
      default_scope = "murphy-curse";
    };
  };

  # Firefox
  programs.firefox.enable = true;

  # Additional system packages
  environment.systemPackages = with pkgs; [
    curl
    neovim
    git
    ntfs3g
    nixd
    nixfmt
  ];

  # Additional nix-ld libraries
  programs.nix-ld.libraries = with pkgs; [
    libxml2
  ];

  # Flatpak
  services.flatpak.enable = true;

  # RGB
  services.hardware.openrgb = {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
    motherboard = "amd";
    server.port = 6742;
  };

  # Firewall
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Home-manager user config
  home-manager.users.phazonic = import ./home.nix;
  home-manager.extraSpecialArgs = {
    inherit inputs;
    username = "phazonic";
  };

  system.stateVersion = "25.11";
}
