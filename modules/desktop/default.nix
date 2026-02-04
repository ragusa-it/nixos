# modules/desktop/default.nix
{
  imports = [
    ./niri.nix
    ./portals.nix
    ./theming.nix
    ./apps.nix
  ];
}
