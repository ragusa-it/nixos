# configuration.nix
# Main NixOS configuration - imports modular components
{ config, pkgs, inputs, lib, ... }:

{
  imports = [
    # Hardware
    ./hardware-configuration.nix

    # Modular configuration
    ./modules/desktop.nix     # Portal, polkit, launcher, lock, wallpaper
    ./modules/gpu-amd.nix     # AMD graphics, Vulkan, VA-API
    ./modules/audio.nix       # Bluetooth, audio controls
    ./modules/gaming.nix      # Steam, Gamemode, Lutris, etc.
    ./modules/apps.nix        # User applications
    ./modules/dev.nix         # Docker, dev tools
    ./modules/theming.nix     # Fonts, themes, cursors
    ./modules/virtualization.nix  # QEMU, KVM, virt-manager
    ./modules/power.nix       # Power management, CPU governors
    ./modules/shell.nix       # Fish shell configuration
    ./modules/services.nix    # System services (fstrim, zram, avahi, psd)
    ./modules/navidrome.nix   # Music streaming server
  ];

  # ═══════════════════════════════════════════════════════════════
  # BOOT
  # ═══════════════════════════════════════════════════════════════
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ═══════════════════════════════════════════════════════════════
  # NETWORKING
  # ═══════════════════════════════════════════════════════════════
  networking.hostName = "atlas";
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
    jack.enable = true;  # For pro audio apps
  };

  # ═══════════════════════════════════════════════════════════════
  # BLUETOOTH
  # ═══════════════════════════════════════════════════════════════
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # ═══════════════════════════════════════════════════════════════
  # PRINTING
  # ═══════════════════════════════════════════════════════════════
  services.printing.enable = true;

  # ═══════════════════════════════════════════════════════════════
  # USER
  # ═══════════════════════════════════════════════════════════════
  users.users.pinj = {
    isNormalUser = true;
    description = "Melvin Ragusa";
    extraGroups = [
      "wheel"           # Sudo access
      "networkmanager"  # Network configuration
      # Additional groups are added by modules:
      # - docker (dev.nix)
      # - gamemode (gaming.nix)
      # - corectrl (gpu-amd.nix)
    ];
    shell = pkgs.fish;  # Fish shell (migrated from Arch)
  };

  # ═══════════════════════════════════════════════════════════════
  # PROGRAMS
  # ═══════════════════════════════════════════════════════════════
  programs.zsh.enable = true;  # Keep zsh available as fallback
  programs.yazi.enable = true;
  programs.firefox.enable = true;
  programs.niri.enable = true;

  # ═══════════════════════════════════════════════════════════════
  # NIX SETTINGS
  # ═══════════════════════════════════════════════════════════════
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];

    # Optimize storage
    auto-optimise-store = true;

    # Trust users for substituters
    trusted-users = [ "root" "@wheel" ];
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
  environment.systemPackages = with pkgs; [
    # Core utilities
    fastfetch
    micro
    wget
    curl

    # Nix tools
    nil               # Nix LSP

    # Wayland
    xwayland-satellite
    grim
    slurp

    # File management
    nautilus

    # Editors
    zed-editor

    # Flake inputs
    inputs.noctalia.packages.${pkgs.system}.default
    inputs.zen-browser.packages.${pkgs.system}.default
    inputs.ghostty.packages.${pkgs.system}.default
    inputs.opencode.packages.${pkgs.system}.default

    # AI coding
    claude-code

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
  system.stateVersion = "25.11";
}
