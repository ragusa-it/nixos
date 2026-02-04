# modules/default.nix
# Auto-import all module categories
{
  imports = [
    ./core
    ./hardware
    ./desktop
    ./services
    ./dev
    ./gaming
  ];
}
