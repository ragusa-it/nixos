# modules/services/maintenance.nix
# System maintenance and optimization services
{
  config,
  pkgs,
  lib,
  ...
}:

{
  services.psd.enable = true;
  services.fwupd.enable = true;

  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 10;
    enableNotifications = true;
  };

  services.locate = {
    enable = true;
    package = pkgs.plocate;
    interval = "daily";
  };
}
