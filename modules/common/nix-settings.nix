# Shared Nix settings for all systems (NixOS and Darwin)
{ ... }:

{
  nix.extraOptions =
    let
      experimentalFeatures = builtins.concatStringsSep " " [
        "flakes"
        "nix-command"
      ];
    in
    ''
      experimental-features = ${experimentalFeatures}
      warn-dirty = false
    '';
}
