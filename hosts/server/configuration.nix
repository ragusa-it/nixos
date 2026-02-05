# configuration.nix
# Server NixOS configuration - headless, no desktop environment
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
    ../../modules/hardware/audio.nix
    ../../modules/hardware/storage.nix
    ../../modules/hardware/power.nix
    ../../modules/dev
    ../../modules/services/maintenance.nix
  ];

  # Server-specific overrides
  # Hostname should be set in hardware-configuration.nix or here
  # networking.hostName = "server";

  # Enable SSH for remote management
  services.openssh.enable = true;

  # Server doesn't need the GPU module (usually headless or different GPU)
  # If server has a GPU, add: ../../modules/hardware/gpu-amd.nix
}
