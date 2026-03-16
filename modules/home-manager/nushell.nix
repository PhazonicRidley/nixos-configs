# Nushell home-manager configuration
# Separate from base home config for systems that want POSIX compatibility by default
{ ... }:

{
  programs.nushell = {
    enable = true;
    # plugins = [ pkgs.nushellPlugins.net ];  # Currently broken in nixpkgs
  };

  programs.starship.enableNushellIntegration = true;
}
