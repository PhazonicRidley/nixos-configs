# RoboServer home-manager configuration
# Server with development tools
{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ../../home
  ];

  # Extra packages for the shared python3 environment (see ../../home)
  python3Packages = ps: with ps; [
    cmake
    ninja
  ];

  # Server-specific development packages
  home.packages = with pkgs; [
    vim
    uv
    openssl

    # Compiler toolchain
    llvmPackages_20.libcxxClang
    llvmPackages_20.clang-tools
  ];
}
