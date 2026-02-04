# modules/services/default.nix
{
  imports = [
    ./avahi.nix
    ./printing.nix
    ./maintenance.nix
    ./navidrome.nix
  ];
}
