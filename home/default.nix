# Shared home-manager base configuration
# Common settings for all machines (Linux and Darwin)
# Can be used standalone: nix run home-manager -- switch --flake .#phazonic@linux
{
  pkgs,
  username ? "phazonic",
  ...
}:

{
  nixpkgs.config.allowUnfree = true;

  home = {
    inherit username;
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
    stateVersion = "25.05";

    sessionVariables = {
      EDITOR = "vim";
    };

    shellAliases = {
      ll = "ls -l";
      code = "code --profile ${username}";
    };
  };

  programs = {
    home-manager.enable = true;

    # Shell configuration
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

    bash.enable = true;

    starship = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      settings = {
        shell = {
          disabled = false;
          format = "[$indicator]($style) ";
          bash_indicator = "🐚";
          zsh_indicator = "⚡";
        };
        nix_shell = {
          disabled = false;
          heuristic = true;
        };
      };
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };

    # Basic Neovim configuration
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      initLua = ''
        vim.opt.clipboard = "unnamedplus"
        vim.opt.number = true
        vim.opt.tabstop = 2
        vim.opt.shiftwidth = 2
        vim.opt.expandtab = true
      '';
    };

    # Git
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

    # Fastfetch
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

    # Hyfetch
    hyfetch = {
      enable = true;
      settings = {
        preset = "transgender";
        mode = "rgb";
        light_dark = "dark";
        lightness = 0.65;
        color_align.mode = "horizontal";
        backend = "fastfetch";
        pride_month_disable = false;
      };
    };

    # Tmux
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

    # Common utilities
    htop.enable = true;
    bat.enable = true;
  };
}
