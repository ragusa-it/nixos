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
    wine
    winetricks
    protontricks
  ];

  services.udev.packages = with pkgs; [
    game-devices-udev-rules
  ];
}
