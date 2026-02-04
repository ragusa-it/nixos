# modules/core/default.nix
{
  imports = [
    ./boot.nix
    ./system.nix
    ./networking.nix
    ./users.nix
    ./localization.nix
  ];
}
