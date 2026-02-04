# modules/hardware/default.nix
{
  imports = [
    ./storage.nix
    ./audio.nix
    ./gpu-amd.nix
    ./power.nix
  ];
}
