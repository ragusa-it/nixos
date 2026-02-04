# modules/services/printing.nix
# CUPS printing service
{
  config,
  pkgs,
  lib,
  ...
}:

{
  services.printing.enable = true;
}
