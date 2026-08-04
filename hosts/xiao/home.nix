# Xiao - MacBook Pro home-manager configuration
{
  pkgs,
  ...
}:

{
  imports = [
    ../../home
    ../../modules/home-manager/nushell.nix
    ../../modules/home-manager/vscode.nix
    ../../modules/home-manager/obsidian.nix
  ];

  # Shell aliases for Homebrew LLVM
  home.shellAliases = {
    clang-21 = "/opt/homebrew/opt/llvm@21/bin/clang";
    "clang++-21" = "/opt/homebrew/opt/llvm@21/bin/clang++";
    brew-clangd = "/opt/homebrew/opt/llvm@21/bin/clangd";
  };

  # Extra packages for the shared python3 environment (see ../../home)
  python3Packages = ps: with ps; [
    pyserial
    cmake
    pip
  ];

  # Xiao-specific packages
  home.packages = with pkgs; [
    python313Packages.pyocd
    stm32loader
    conan

    # Build tools
    gcc
  ];

  # Xiao-specific VSCode settings
  programs.vscode.profiles."phazonic".userSettings = {
    "clangd.path" = "/opt/homebrew/opt/llvm@21/bin/clangd";
  };

  # Only exec into nu for /bin/sh login shells; the $0 guard means this
  # is a no-op when bash itself sources .profile (e.g. nix-shell, nix develop).
  programs.bash.profileExtra = ''
    case "$0" in
      sh|-sh|*/sh)
        [ -t 0 ] && exec nu
        ;;
    esac
  '';

  # Enable fontconfig for user fonts
  fonts.fontconfig.enable = true;
}
