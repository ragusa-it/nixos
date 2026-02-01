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
        renice = -10;  # Negative value = higher priority for games
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

  # NOTE: Profile-specific group membership
  # The user must be in the "corectrl" and "gamemode" groups for these
  # programs to function correctly. These groups are only added when using
  # the gaming profile. If you need consistent group membership across
  # both profiles, add these groups to common.nix instead.
  users.users.pinj.extraGroups = [ "corectrl" "gamemode" ];

  # --------------------------------------------------------------------------
  # GAMING PACKAGES
  # --------------------------------------------------------------------------
  users.users.pinj.packages = with pkgs; [
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
    # Increase max map count for games requiring many memory mappings.
    # This value (2^31 - 6) is the maximum safe value for signed 32-bit integers.
    # Games like Star Citizen, Hogwarts Legacy, and some Unity/Unreal titles
    # may crash without this setting due to high mmap requirements.
    "vm.max_map_count" = 2147483642;
  };
}
