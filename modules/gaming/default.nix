# modules/gaming/default.nix
{
  imports = [
    ./steam.nix
    ./gamemode.nix
    ./wine.nix
  ];
}
