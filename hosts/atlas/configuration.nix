# configuration.nix
# Main NixOS configuration entry point for atlas (desktop)
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
    ../../modules/core
    ../../modules/hardware
    ../../modules/desktop
    ../../modules/services
    ../../modules/dev
    ../../modules/gaming
    ../../modules/limine-custom-labels.nix
  ];
}
