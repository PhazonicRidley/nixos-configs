# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  nix.extraOptions = let
    experimentalFeatures = builtins.concatStringsSep " " [
      "flakes"
      "nix-command"
    ];
  in ''
      experimental-features = ${experimentalFeatures}
      warn-dirty = false
  '';

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];
  
  home-manager = {
    extraSpecialArgs = { inherit inputs nix; };
    users = {
      phazonic = import ../home-manager/home.nix;
    };
  };


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "murphy-curse"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.phazonic = {
    isNormalUser = true;
    description = "Madeline Schneider";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];

    shell = pkgs.zsh;

    openssh.authorizedKeys.keys = [
  	"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDlWOd2WgZqVrbSn+1aNJszcFLyLLDAoimjBhfjhI7IkLeztUw5Bq21lUCgX6NbSpwQpXcsu5BGVLdpUn5rctsheBG7sNnf8PUAsKC3eEosBq1Z/If/uFVKe+KIIHDbALYWtONS51DRM2nLQ/FuKcx0MTVB7Fwwtp82otRWfWD7CjDD9Eq1O+wvhWYDdlC66KK+6j2SJNDYh4D4CHm2PlAQjoRyFiPaylmXTPZV8M8LXcnir6s8wI/DH2EuDJu8a0UOYudUHnzfi+xhysSLoS21/ZP3aLc3yHFbSUTBtwRi27c6LyagO/24Q8RV6tB2PyMnklJC3qCkphmHJ39+CBDCIcgx6WjmV6NTVLuWWJ/qsf0NUW4chcRd1LaQoFgiFroaIRfgajCZqF4boshK9x8NsPoaIFg/f0YqyxEWZj7q6MEJ2O2Nyx92WHIeBWhahTQQPGM6/2P8CwAEcbtOKKEUX4E7+1Q4+3SZXT1zjbNA0zDf+ebhsiVSgXq83oFJauE= phazonic@Madelines-Laptop.local" 
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
   wget
   curl
   neovim
   git
   tcpdump

   home-manager
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
   networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
