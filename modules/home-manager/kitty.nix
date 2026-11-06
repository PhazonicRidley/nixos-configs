# Kitty terminal, managed by home-manager.
# https://sw.kovidgoyal.net/kitty/conf/
{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.kitty = {
    enable = true;

    # JetBrainsMono Nerd Font Mono is the single-width Nerd Font. Darwin hosts
    # also install this package via nix-darwin fonts.packages so Core Text can
    # see it; home-manager's font package covers fontconfig on Linux.
    font = {
      name = "JetBrainsMono Nerd Font Mono";
      package = pkgs.nerd-fonts.jetbrains-mono;
      size = 12;
    };

    # home-manager always injects no-rc and sources the integration from the
    # shell rc. That is the integration that still runs inside tmux and after
    # `exec zsh`; kitty's automatic injection does not.
    # https://sw.kovidgoyal.net/kitty/shell-integration/
    shellIntegration = {
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };

    settings = {
      # Terminal.app profile "Clear Dark" (Default Window Settings and Startup
      # Window Settings). Decoded from com.apple.Terminal.plist. That profile's
      # background alpha is 0.95 and it blurs the desktop; opacity here is 90%
      # and the blur is not copied. Kitty has no separate bold-text color
      # (TextBoldColor is #f0f0f0 there) and the profile has no cursor color.
      foreground = "#e6e6e6";
      background = "#212734";
      background_opacity = "0.9";
      selection_background = "#334e5e";
      color0 = "#35424c";
      color1 = "#b45648";
      color2 = "#6caa71";
      color3 = "#c4ac62";
      color4 = "#6d96b4";
      color5 = "#bd7bcd";
      color6 = "#7ccbcd";
      color7 = "#dee5eb";
      color8 = "#465c6d";
      color9 = "#df6c5a";
      color10 = "#79be7e";
      color11 = "#e5c872";
      color12 = "#67b5ed";
      color13 = "#d389e5";
      color14 = "#84dde0";
      color15 = "#e5eff5";

      # OSC 52 writes from tmux/vim reach the system clipboard, including over
      # a plain SSH pty. Reads still prompt: an unattended read would let any
      # remote program scrape the clipboard.
      # https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.clipboard_control
      clipboard_control = "write-clipboard write-primary read-clipboard-ask read-primary-ask";
      # macOS has no primary selection, so a mouse selection should land on
      # the clipboard too.
      copy_on_select = "clipboard";

      # Kitty bundles Symbols Nerd Font and prefers it for private-use icons
      # when a patched font is also installed. Without this, the patched font
      # can clip those glyphs.
      # https://sw.kovidgoyal.net/kitty/faq/#kitty-is-not-able-to-use-my-favorite-font
      symbol_map = "U+e000-U+e00a,U+e0a0-U+e0a2,U+e0a3,U+e0b0-U+e0b3,U+e0b4-U+e0c8,U+e0ca,U+e0cc-U+e0d7,U+e200-U+e2a9,U+e300-U+e3e3,U+e5fa-U+e6b7,U+e700-U+e8ef,U+ea60-U+ec1e,U+ed00-U+efce,U+f000-U+f2ff,U+f300-U+f381,U+f400-U+f533,U+f0001-U+f1af0 Symbols Nerd Font Mono";
    };

    enableGitIntegration = true;
  };

  # Linux kitty looks fonts up through fontconfig. Darwin uses Core Text and
  # the system fonts.packages install.
  fonts.fontconfig.enable = true;

  # `kitten ssh` copies the kitty terminfo and enables the same shell
  # integration on the remote host. OSC 52 copy works over plain ssh too;
  # the kitten is what makes prompt marks and the terminfo database show up.
  # https://sw.kovidgoyal.net/kitty/kittens/ssh/
  home.shellAliases.kssh = "kitten ssh";

  xdg.configFile."kitty/ssh.conf".text = ''
    # Same shell integration as kitty.conf. `inherited` is the kitten default;
    # pinned here so a remote login does not silently drop it.
    shell_integration inherited
  '';

  # Nushell is not one of kitty's injected shells (bash, zsh, fish). It emits
  # the sequences kitty consumes, and those flags default on in current
  # Nushell. Set them here so a config that replaces $env.config keeps them.
  # Reedline turns on the kitty keyboard protocol itself when TERM=xterm-kitty.
  # https://www.nushell.sh/book/configuration.html
  programs.nushell.settings = lib.mkIf config.programs.nushell.enable {
    shell_integration.osc2 = true; # window and tab title
    shell_integration.osc7 = true; # cwd, used by new windows and the ssh kitten
    shell_integration.osc133 = true; # prompt marks: jump to prompt, browse output
  };

  programs.nushell.shellAliases = lib.mkIf config.programs.nushell.enable {
    kssh = "kitten ssh";
  };

  # tmux already has `set-clipboard on`. This advertises OSC 52 for kitty even
  # when the remote terminfo has no Ms capability.
  programs.tmux.extraConfig = lib.mkAfter ''
    set -as terminal-features ",xterm-kitty:clipboard"
  '';

  # `vim` is neovim here. OSC 52 is what carries a yank to the local clipboard
  # through kitty, including from a remote host. A paste still raises kitty's
  # clipboard-read prompt.
  programs.neovim.initLua = lib.mkAfter ''
    vim.g.clipboard = {
      name = "OSC 52",
      copy = {
        ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
        ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
      },
      paste = {
        ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
        ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
      },
    }
  '';
}
