{ pkgs, ... }:

{
  # Identification tags (shows in boot menu)
  system.nixos.tags = [ "gaming" "zen" ];

  # --------------------------------------------------------------------------
  # KERNEL - Zen for gaming performance
  # --------------------------------------------------------------------------
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # --------------------------------------------------------------------------
  # STEAM
  # --------------------------------------------------------------------------
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # --------------------------------------------------------------------------
  # GAMEMODE - Auto performance optimizations
  # --------------------------------------------------------------------------
  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        renice = 10;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };
    };
  };

  # --------------------------------------------------------------------------
  # CORECTRL - AMD GPU Control
  # --------------------------------------------------------------------------
  programs.corectrl = {
    enable = true;
    gpuOverclock = {
      enable = true;
      ppfeaturemask = "0xffffffff";
    };
  };

  # IMPORTANT: Replace <username> with actual username
  users.users.<username>.extraGroups = [ "corectrl" "gamemode" ];

  # --------------------------------------------------------------------------
  # GAMING PACKAGES
  # --------------------------------------------------------------------------
  # IMPORTANT: Replace <username> with actual username
  users.users.<username>.packages = with pkgs; [
    # -- Performance Overlays --
    mangohud        # FPS counter, GPU stats
    goverlay        # MangoHud GUI config

    # -- Game Launchers --
    lutris          # Multi-platform launcher
    heroic          # Epic/GOG launcher
    bottles         # Wine prefix manager

    # -- Proton/Wine --
    protonup-qt     # Proton-GE installer
    winetricks
    protontricks

    # -- Utilities --
    gamescope       # Micro-compositor for gaming
    corectrl        # AMD GPU control GUI

    # -- Optional Game Clients --
    # prismlauncher # Minecraft
    # retroarch     # Emulation
  ];

  # --------------------------------------------------------------------------
  # KERNEL PARAMETERS - Gaming optimizations
  # --------------------------------------------------------------------------
  boot.kernel.sysctl = {
    # Reduce swappiness for gaming
    "vm.swappiness" = 10;
    # Increase max map count (needed for some games)
    "vm.max_map_count" = 2147483642;
  };

  # Additional kernel params for gaming (appends to common.nix params)
  boot.kernelParams = [
    "amd_pstate=active"       # Inherited from common, but explicit for clarity
    "mitigations=off"         # Optional: Disable CPU mitigations for ~5% perf gain
                              # Remove this line if security is a concern
  ];
}
