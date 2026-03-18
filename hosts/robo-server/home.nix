# RoboServer home-manager configuration
# Server with development tools
{ pkgs, ... }:

{
  imports = [
    ../../home
  ];

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
