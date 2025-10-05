{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should manage.
  home.username = "phazonic";
  # nixpkgs.config.allowUnfree = true;
  programs = {
    zsh = {
      enable = true;
      plugins = [
        {
          name = "zsh-autosuggestions";
          src = pkgs.fetchFromGitHub {
                owner = "zsh-users";
                repo = "zsh-autosuggestions";
                rev = "v0.4.0";
                sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
          };
        }
        {
          name = "zsh-syntax-highlighting";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-syntax-highlighting";
            rev = "5eb677bb0fa9a3e60f0eff031dc13926e093df92";
            sha256 = "1x33gk7hhp07jqq7yjvrsp2vmdbxmadlv3335ixx29bc6h8106r9";
          };
        }
      ];
      shellAliases = {
        clang-20 = "/opt/homebrew/Cellar/llvm@20/20.1.7/bin/clang";
        "clang++-17" = "/opt/homebrew/Cellar/llvm@20/20.1.7/bin/clang++";
        clangd-brew = "/opt/homebrew/Cellar/llvm@20/20.1.7/bin/clangd";
      };
    };
    
    nushell = {
      enable = true;
      plugins = [pkgs.nushellPlugins.net];

      shellAliases = {
        clang-20 = "/opt/homebrew/Cellar/llvm/20.1.7/bin/clang";
        "clang++-20" = "/opt/homebrew/Cellar/llvm/20.1.7/bin/clang++";
        brew-clangd = "/opt/homebrew/Cellar/llvm/20.1.7/bin/clangd";
      };
    };

    starship = {
      enable = true;
      enableZshIntegration = false;
      enableNushellIntegration = true;
    };

    vscode = {
	    enable = true;
    };

    firefox = {
	    enable = true;
    };

    htop.enable = true;
    bat.enable = true;
    git = {
      enable = true;
      userName = "PhazonicRidley";
      userEmail = "ma13hew@gmail.com";
    };
  };

 
  # Environment variables (optional)
  home.sessionVariables = {
    EDITOR = "vim";
    BROWSER = "firefox";
    NIXPKGS_ALLOW_UNFREE = 1; # No idea why this needs to be done, should use nix darwin's pkg settings
  };

  home.packages = [
    (pkgs.python313.withPackages (ps: with ps; [
	pyserial
	cmake
	pip
    ]))
    pkgs.conan
    pkgs.python313Packages.pyocd
    # pkgs.python313Packages.pyserial
    pkgs.stm32loader
    #pkgs.cmake
    pkgs.gcc
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nushellPlugins.net
    pkgs.act

    pkgs.vim
    pkgs.neovim
    pkgs.fastfetch
    pkgs.bat
  ];

  fonts.fontconfig.enable = true;

  # This value determines the Home Manager release that your configuration is compatible with.
  # Update this value when you want to opt in to new features or breaking changes.
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  
}
