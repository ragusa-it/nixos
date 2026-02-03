# configuration.nix
# Main NixOS configuration - imports modular components
{
  config,
  pkgs,
  inputs,
  lib,
  username,
  ...
}:

{
  imports = [
    # Hardware
    ./hardware-configuration.nix

    # Modular configuration
    ./modules/desktop.nix # Portal, polkit, launcher, lock, wallpaper
    ./modules/gpu-amd.nix # AMD graphics, Vulkan, VA-API
    ./modules/audio.nix # Bluetooth, audio controls
    ./modules/gaming.nix # Steam, Gamemode, Lutris, etc.
    ./modules/apps.nix # User applications
    ./modules/dev.nix # Docker, dev tools
    ./modules/theming.nix # Fonts, themes, cursors
    ./modules/virtualization.nix # QEMU, KVM, virt-manager
    ./modules/power.nix # Power management, CPU governors
    ./modules/shell.nix # Fish shell configuration
    ./modules/services.nix # System services (fstrim, zram, avahi, psd)
    ./modules/navidrome.nix # Music streaming server
  ];

  # ═══════════════════════════════════════════════════════════════
  # BOOT
  # ═══════════════════════════════════════════════════════════════

  # ─── Bootloader: Limine with Secure Boot ───
  boot.loader.systemd-boot.enable = false; # Disabled - using Limine
  boot.loader.limine.enable = true;
  boot.loader.limine.secureBoot.enable = false;
  boot.loader.efi.canTouchEfiVariables = true;

  # ─── Kernel ───
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-x86_64-v3;

  # Kernel parameters (consolidated from modules)
  boot.kernelParams = [
    "amd_pstate=active" # Modern Ryzen power management (from power.nix)
    "amdgpu.ppfeaturemask=0xffffffff" # Full AMD GPU power features (from gpu-amd.nix)
  ];

  # ─── Scheduler ───
  # sched-ext scheduler for gaming performance
  services.scx.enable = true;
  services.scx.scheduler = "scx_lavd"; # Low-latency scheduler, good for gaming

  # ═══════════════════════════════════════════════════════════════
  # NETWORKING
  # ═══════════════════════════════════════════════════════════════
  networking.hostName = "nix";
  networking.networkmanager.enable = true;

  # ═══════════════════════════════════════════════════════════════
  # LOCALIZATION
  # ═══════════════════════════════════════════════════════════════
  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  console.keyMap = "de-latin1-nodeadkeys";

  # ═══════════════════════════════════════════════════════════════
  # DISPLAY & INPUT
  # ═══════════════════════════════════════════════════════════════
  services.xserver.enable = true;
  services.displayManager.ly.enable = true;
  services.displayManager.defaultSession = "niri";

  services.xserver.xkb = {
    layout = "de";
    variant = "nodeadkeys";
  };

  # ═══════════════════════════════════════════════════════════════
  # AUDIO (PipeWire)
  # ═══════════════════════════════════════════════════════════════
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true; # For pro audio apps
  };

  # ═══════════════════════════════════════════════════════════════
  # BLUETOOTH
  # ═══════════════════════════════════════════════════════════════
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        Experimental = true;
        KernelExperimental = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  # ═══════════════════════════════════════════════════════════════
  # PRINTING
  # ═══════════════════════════════════════════════════════════════
  services.printing.enable = true;

  # ═══════════════════════════════════════════════════════════════
  # USER
  # ═══════════════════════════════════════════════════════════════
  users.users.${username} = {
    isNormalUser = true;
    description = "Melvin Ragusa";
    extraGroups = [
      "wheel" # Sudo access
      "networkmanager" # Network configuration
      # Additional groups are added by modules:
      # - docker (dev.nix)
      # - gamemode (gaming.nix)
      # - corectrl (gpu-amd.nix)
    ];
    shell = pkgs.fish; # Fish shell (migrated from Arch)
  };

  # ═══════════════════════════════════════════════════════════════
  # PROGRAMS
  # ═══════════════════════════════════════════════════════════════
  programs.zsh.enable = true; # Keep zsh available as fallback
  programs.yazi.enable = true;
  programs.firefox.enable = true;
  programs.niri.enable = true;

  # ═══════════════════════════════════════════════════════════════
  # NIX SETTINGS
  # ═══════════════════════════════════════════════════════════════
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Optimize storage
    auto-optimise-store = true;

    # Trust users for substituters
    trusted-users = [
      "root"
      "@wheel"
    ];
  };

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nixpkgs.config.allowUnfree = true;

  # ═══════════════════════════════════════════════════════════════
  # SYSTEM PACKAGES (Base essentials)
  # ═══════════════════════════════════════════════════════════════
  # NOTE: GUI apps and fast-updating tools are managed via `nix profile`
  # Run `update-apps` to update them, `list-apps` to see installed
  environment.systemPackages = with pkgs; [
    # Core utilities
    micro
    wget
    curl

    # Secure Boot management
    sbctl

    # Nix tools
    nil # Nix LSP
    nixd

    # Wayland
    xwayland-satellite
    grim
    slurp

    # File management
    nautilus

    # Flake inputs (desktop shell)
    inputs.noctalia.packages.${pkgs.system}.default

    # Terminal
    ghostty

    # Package managers
    pnpm
  ];

  # ═══════════════════════════════════════════════════════════════
  # SERVICES
  # ═══════════════════════════════════════════════════════════════
  services.openssh.enable = true;
  services.tailscale.enable = true;

  # ═══════════════════════════════════════════════════════════════
  # SYSTEM
  # ═══════════════════════════════════════════════════════════════
  system.stateVersion = "26.05";
}
