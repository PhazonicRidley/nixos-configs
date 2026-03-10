# Shared home-manager base configuration
# Common settings for all machines (Linux and Darwin)
# Can be used standalone: nix run home-manager -- switch --flake .#phazonic@linux
{ pkgs, username ? "phazonic", ... }:

{
  nixpkgs.config.allowUnfree = true;

  home.username = username;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin
    then "/Users/${username}"
    else "/home/${username}";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  # Shell configuration
  programs.zsh = {
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

  programs.bash.enable = true;

  programs.starship = {
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

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  # Editor
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    initLua = ''
      vim.opt.clipboard = "unnamedplus"
      vim.opt.number = true
    '';
  };

  # Git
  programs.git = {
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
  programs.fastfetch = {
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
  programs.hyfetch = {
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
  programs.tmux = {
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
  programs.htop.enable = true;
  programs.bat.enable = true;

  # Common session variables
  home.sessionVariables = {
    EDITOR = "vim";
  };

  home.shellAliases = {
    ll = "ls -l";
  };
}
