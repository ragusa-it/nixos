# modules/dev/default.nix
{
  imports = [
    ./docker.nix
    ./shell.nix
    ./tools.nix
  ];
  nixpkgs.overlays = [
    (import ../../overlays/firebase-tools.nix)
  ];
}
