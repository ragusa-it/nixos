# configuration.nix
# Laptop NixOS configuration - desktop environment, no gaming
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
    ../../modules/dev
    ../../modules/services/maintenance.nix
    ../../modules/services/printing.nix
    ../../modules/services/avahi.nix
  ];

  # Laptop-specific configuration
  # Hostname should be set in hardware-configuration.nix or here
  # networking.hostName = "laptop";

  # Laptop-specific power management tweaks can go here
  # The power module already enables power-profiles-daemon
}
