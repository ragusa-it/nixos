# modules/desktop/niri.nix
# Window manager and display configuration
{
  config,
  pkgs,
  lib,
  ...
}:

{
  services.xserver.enable = true;
  services.displayManager.ly.enable = true;
  services.displayManager.defaultSession = "niri";

  services.xserver.xkb = {
    layout = "de";
    variant = "nodeadkeys";
  };

  programs.niri.enable = true;
}
