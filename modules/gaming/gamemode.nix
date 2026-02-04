# modules/gaming/gamemode.nix
# Gaming performance optimizations
{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        renice = 10;
        softrealtime = "auto";
        inhibit_screensaver = 1;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };
    };
  };

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 524288;
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
  };

  environment.systemPackages = with pkgs; [
    gamemode
    gamescope
  ];
}
