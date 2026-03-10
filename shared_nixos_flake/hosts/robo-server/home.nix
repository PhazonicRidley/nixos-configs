# RoboServer home-manager configuration
# Server with development tools
{ inputs, pkgs, ... }:

{
  imports = [
    ../../home
  ];

  # Basic VSCode (no desktop extensions)
  programs.vscode.enable = true;

  # Server-specific development packages
  home.packages = with pkgs; [
    vim
    python314
    uv

    # Compiler toolchain
    llvmPackages_20.libcxxClang
    llvmPackages_20.clang-tools
    python314Packages.cmake
    python314Packages.ninja
  ];
}
