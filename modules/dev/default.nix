# modules/dev/default.nix
{
  imports = [
    ./docker.nix
    ./shell.nix
    ./tools.nix
  ];
}
