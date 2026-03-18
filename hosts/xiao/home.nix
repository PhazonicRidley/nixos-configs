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
  ];

  # Shell aliases for Homebrew LLVM
  home.shellAliases = {
    clang-21 = "/opt/homebrew/opt/llvm@21/bin/clang";
    "clang++-21" = "/opt/homebrew/opt/llvm@21/bin/clang++";
    brew-clangd = "/opt/homebrew/opt/llvm@21/bin/clangd";
  };

  # Xiao-specific packages
  home.packages = with pkgs; [
    # Python with embedded dev packages
    (python313.withPackages (
      ps: with ps; [
        pyserial
        cmake
        pip
      ]
    ))
    python313Packages.pyocd
    stm32loader
    conan

    # Build tools
    gcc
  ];

  # Enable fontconfig for user fonts
  fonts.fontconfig.enable = true;
}
