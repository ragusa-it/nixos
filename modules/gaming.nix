# modules/gaming.nix
# Full gaming setup: Steam, Gamemode, Lutris, Heroic, Wine, Proton
{ config, pkgs, lib, ... }:

{
  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;       # Steam Remote Play
    dedicatedServer.openFirewall = true;  # Dedicated servers
    localNetworkGameTransfers.openFirewall = true;  # LAN game transfers

    # Extra compatibility packages for Proton
    extraCompatPackages = with pkgs; [
      proton-ge-bin   # GloriousEggroll's Proton fork - better compatibility
    ];
  };

  # Gamemode - Optimize system for gaming
  programs.gamemode = {
    enable = true;
    enableRenice = true;  # Allow renice for priority boost
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

  # Steam hardware support (controllers, VR, etc.)
  hardware.steam-hardware.enable = true;

  # Gaming packages
  environment.systemPackages = with pkgs; [
    # Game launchers
    lutris              # Multi-platform game launcher
    heroic              # Epic Games & GOG launcher

    # Proton management
    protonup-qt         # GUI to manage Proton-GE versions

    # Wine for non-Steam games
    wineWowPackages.stagingFull  # Latest Wine with all features
    winetricks                    # Wine helper scripts
    protontricks                  # Proton helper scripts (like winetricks for Proton)

    # Misc gaming utilities
    gamemode            # CLI tool to trigger gamemode
    gamescope           # Micro-compositor for games (fixes some issues)
  ];

  # Gaming-related kernel tweaks
  boot.kernel.sysctl = {
    # Increase file watchers for large games
    "fs.inotify.max_user_watches" = 524288;

    # Better memory management for gaming
    "vm.swappiness" = 10;
    "vm.vfs_cache_pressure" = 50;
  };

  # Udev rules for game controllers
  services.udev.packages = with pkgs; [
    game-devices-udev-rules  # Support for various game controllers
  ];

  # Add user to gamemode group
  users.users.pinj.extraGroups = [ "gamemode" ];
}
