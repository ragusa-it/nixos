# configuration.nix
# Main NixOS configuration entry point
{
  config,
  pkgs,
  inputs,
  lib,
  username,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./modules
    ./modules/limine-custom-labels.nix
  ];
}
