# modules/core/networking.nix
# Network configuration and services
{
  config,
  pkgs,
  lib,
  ...
}:

{
  networking.hostName = "nix";
  networking.networkmanager.enable = true;

  services.openssh.enable = true;
  services.tailscale.enable = true;
}
