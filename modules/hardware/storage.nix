# modules/hardware/storage.nix
# Filesystems, SSD maintenance, and swap
{
  config,
  pkgs,
  lib,
  username,
  ...
}:

{
  fileSystems."/mnt/Intenso-SSD" = {
    device = "/dev/disk/by-uuid/51c56376-8384-4762-a8e9-8151fe91173b";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail"
      "x-gvfs-show"
    ];
  };

  fileSystems."/mnt/Samsung-SSD" = {
    device = "/dev/disk/by-uuid/343ea612-9305-4fb6-9d4c-7a7ca8b0e72c";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail"
      "x-gvfs-show"
    ];
  };

  fileSystems."/mnt/Extern-SSD" = {
    device = "/dev/disk/by-uuid/4e233c88-e91b-480c-b795-6fffc1fbdc69";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail"
      "x-gvfs-show"
    ];
  };

  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
  };
}
