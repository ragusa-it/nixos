# modules/gaming/wine.nix
# Wine, launchers, and controller support
{
  config,
  pkgs,
  lib,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    wineWowPackages.stagingFull
    winetricks
    protontricks
    faugus-launcher
    lutris
    heroic
  ];

  services.udev.packages = with pkgs; [
    game-devices-udev-rules
  ];
}
