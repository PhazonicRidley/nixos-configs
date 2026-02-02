{
  inputs,
  pkgs,
  nixOptions,
  ...
}:
let
  optnixLib = inputs.optnix.mkLib pkgs;
in
{

  imports = [
    inputs.optnix.homeModules.optnix
    inputs.plasma-manager.homeModules.plasma-manager
    ./vscode.nix
    ./plasma.nix
  ];

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

  nixpkgs.config = {
    allowUnfree = true;
  };

  nix.extraOptions = nixOptions;

  # TODO: Move to a common folder
  # nix.extraOptions = let
  #   experimentalFeatures = builtins.concatStringsSep " " [
  #     "flakes"
  #     "nix-command"
  #   ];
  # in ''
  #     experimental-features = ${experimentalFeatures}
  #     warn-dirty = false
  # '';

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "phazonic";
  home.homeDirectory = "/home/phazonic";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # Shell configuration
  programs = {
    zsh = {
      enable = true;
      plugins = [
        {
          name = "zsh-autosuggestions";
          src = pkgs.zsh-autosuggestions;
        }
        {
          name = "fast-syntax-highlighting";
          src = pkgs.zsh-fast-syntax-highlighting;
        }
      ];
    };

    nushell.enable = true;

    starship = {
      enable = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
    };
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.

  programs = {
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      initLua = ''
        vim.opt.clipboard = "unnamedplus"

        vim.opt.number = true
      '';
    };

    fastfetch = {
      enable = true;
      settings = {
        modules = [
          "title"
          "separator"
          "os"
          "host"
          "kernel"
          "uptime"
          "packages"
          "shell"
          "de"
          "wm"
          "wmtheme"
          "theme"
          "icons"
          "font"
          "cursor"
          "terminal"
          "cpu"
          {
            type = "gpu";
            format = "{1} {2} @ {3}";
          }
          "memory"
          "swap"
          "disk"
          "localip"
          "locale"
        ];
      };
    };
    hyfetch = {
      enable = true;
      settings = {
        preset = "transgender";
        mode = "rgb";
        light_dark = "dark";
        lightness = 0.65;
        color_align = {
          mode = "horizontal";
        };
        backend = "fastfetch";
        pride_month_disable = false;
      };
    };

    git = {
      enable = true;

      settings = {
        user = {
          name = "PhazonicRidley";
          email = "ma13hew@gmail.com";
        };
        init.defaultBranch = "main";
        core.editor = "vim";
        pull.rebase = false;
      };

      ignores = [
        ".DS_Store"
        "*.log"
        "node_modules/"
        "*.env"
        "*.tmp"
        "__pycache__"
      ];
    };

    discord.enable = true;
    lutris.enable = true;

    tmux = {
      enable = true;
      mouse = true;

      extraConfig = ''
          	# Modern clipboard integration via OSC 52
          	set -g set-clipboard on
          
          	# Vi-style keys for copy mode
          	setw -g mode-keys vi
        	'';
    };

  };

  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    kdePackages.kate
    nushell
    signal-desktop
    telegram-desktop
    chromium
    iputils
    dnsutils
    htop
    nixd
    nixfmt
    bat
    papirus-icon-theme
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/phazonic/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "vim";
    NIXOS_CONFIG = "/home/phazonic/nixos-configs/murphy-curse";
  };

  # Shell Aliases
  home.shellAliases = {
    ll = "ls -l";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
