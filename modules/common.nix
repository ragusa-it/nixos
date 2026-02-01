{ config, pkgs, inputs, system, hostname, username, ... }:

{
  # --------------------------------------------------------------------------
  # BOOT
  # --------------------------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # --------------------------------------------------------------------------
  # SYSTEM
  # --------------------------------------------------------------------------
  networking.hostName = hostname;
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  # German keyboard layout (nodeadkeys variant)
  console.keyMap = "de-latin1-nodeadkeys";
  services.xserver.xkb = {
    layout = "de";
    variant = "nodeadkeys";
  };

  networking.networkmanager.enable = true;

  # Memory compression (reduces swap usage)
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  # Firmware updates
  services.fwupd.enable = true;

  # Power profiles daemon (for laptop/power management)
  services.power-profiles-daemon.enable = true;

  # --------------------------------------------------------------------------
  # AMD GPU - RDNA 4 (RX 9060 XT) + Zen 3 CPU (5700G)
  # --------------------------------------------------------------------------
  
  # RDNA 4 requires navi44 firmware blobs (included in redistributable firmware)
  hardware.enableRedistributableFirmware = true;
  
  # Use the modern amdgpu NixOS module (cleaner than manual initrd config)
  hardware.amdgpu.initrd.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # Required for Steam/Wine
    extraPackages = with pkgs; [
      rocmPackages.clr.icd     # OpenCL support for RDNA 4
    ];
    # NOTE: AMDVLK intentionally omitted
    # Some games auto-select AMDVLK over RADV, causing performance issues
    # RADV (Mesa) is the default and performs better for gaming
  };

  # Wayland session variables for proper app integration
  environment.sessionVariables = {
    # RADV is already the default Vulkan driver
    # This variable is optional but makes it explicit
    AMD_VULKAN_ICD = "RADV";
    QT_QPA_PLATFORM = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";  # Electron apps (VS Code, Discord, etc.)
  };

  # --------------------------------------------------------------------------
  # CPU - Zen 3 Optimizations (Ryzen 7 5700G)
  # --------------------------------------------------------------------------
  boot.kernelParams = [
    "amd_pstate=active"  # Better power/performance scaling on Zen 3
  ];

  # --------------------------------------------------------------------------
  # MOTHERBOARD - MSI B550 Tomahawk Sensors
  # --------------------------------------------------------------------------
  boot.kernelModules = [ "nct6775" ];  # B550 hardware monitoring

  # --------------------------------------------------------------------------
  # MANGOWC + NOCTALIA
  # --------------------------------------------------------------------------
  programs.mango.enable = true;

  # Required for screen sharing, file dialogs
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Enable seatd for session management
  services.seatd.enable = true;

  # Use greetd to automatically start a MangoWC session on login
  # Note: 'mango' binary is provided by programs.mango.enable above
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "mango";
      user = username;
    };
  };

  # --------------------------------------------------------------------------
  # USER ACCOUNT
  # --------------------------------------------------------------------------
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "seat" ];
    # IMPORTANT: Generate a password hash with: mkpasswd -m sha-512
    # Save it to the path below (ensure permissions are 600)
    hashedPasswordFile = "/etc/nixos/secrets/${username}/password.hash";
    packages = with pkgs; [
      # -- Noctalia Shell --
      inputs.quickshell.packages.${system}.default
      inputs.noctalia.packages.${system}.default
      brightnessctl
      cliphist
      wlsunset

      # -- MangoWC Ecosystem --
      foot            # Terminal
      wmenu           # Launcher
      wl-clipboard    # Clipboard
      grim            # Screenshot
      slurp           # Region selection
      swaybg          # Wallpaper

      # -- Applications --
      firefox
    ];
  };

  # --------------------------------------------------------------------------
  # SYSTEM PACKAGES
  # --------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    htop
    git
    unzip
    file
    
    # GPU verification tools
    clinfo          # Verify OpenCL: clinfo
    vulkan-tools    # Verify Vulkan: vulkaninfo
    pciutils        # lspci for hardware info
  ];

  # --------------------------------------------------------------------------
  # FONTS
  # --------------------------------------------------------------------------
  fonts.packages = with pkgs; [
    # Nerd fonts: current syntax for nixos-unstable and NixOS >= 24.05
    # For older nixpkgs (before this change), use:
    #   (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    nerd-fonts.jetbrains-mono
    
    # Other fonts
    inter
    roboto
  ];

  # --------------------------------------------------------------------------
  # AUDIO (PipeWire)
  # --------------------------------------------------------------------------
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    
    # Low-latency configuration for gaming
    lowLatency = {
      enable = true;
      quantum = 64;      # Buffer size (lower = less latency)
      rate = 48000;      # Sample rate
    };
  };

  # Disable PulseAudio (conflicts with PipeWire)
  hardware.pulseaudio.enable = false;

  # RealtimeKit for PipeWire
  security.rtkit.enable = true;

  # --------------------------------------------------------------------------
  # MISC
  # --------------------------------------------------------------------------
  # Allow unfree packages (needed for Steam, some drivers)
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # IMPORTANT: Set to the NixOS version of your install media
  # Check with: nixos-version
  # Do NOT change this after initial install
  system.stateVersion = "24.11";
}
