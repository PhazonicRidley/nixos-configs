# Xiao - MacBook Pro home-manager configuration
{
  pkgs,
  ...
}:

{
  imports = [
    ../../home
    ../../modules/home-manager/nushell.nix
    ../../modules/home-manager/kitty.nix
    ../../modules/home-manager/vscode.nix
    ../../modules/home-manager/obsidian.nix
  ];

  # Shell aliases for Homebrew LLVM
  home.shellAliases = {
  };

  # Extra packages for the shared python3 environment (see ../../home)
  python3Packages =
    ps: with ps; [
      pyserial
      cmake
      pip
    ];

  # Enable fontconfig for user fonts
  fonts.fontconfig.enable = true;
}
