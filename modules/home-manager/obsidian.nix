# Separate from base home config for systems that want POSIX compatibility by default
{ ... }:

{
  programs.obsidian = {
    enable = true;
    cli.enable = true;
  };

}
