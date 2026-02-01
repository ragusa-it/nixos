{ config, pkgs, inputs, system, ... }:

{
  # --------------------------------------------------------------------------
  # BOOT
  # --------------------------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # --------------------------------------------------------------------------
  # SYSTEM
  # --------------------------------------------------------------------------
  # IMPORTANT: Replace with actual values
  networking.hostName = "<hostname>";
  time.timeZone = "<timezone>";
  i18n.defaultLocale = "<locale>";

  networking.networkmanager.enable = true;

  # --------------------------------------------------------------------------
  # AMD GPU - RDNA 4 (RX 9060 XT) + Zen 3 CPU (5700G)
  # --------------------------------------------------------------------------
  
  # CRITICAL: RDNA 4 requires navi44 firmware blobs
  hardware.enableAllFirmware = true;
  
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

  # RADV is already the default Vulkan driver
  # This variable is optional but makes it explicit
  environment.variables.AMD_VULKAN_ICD = "RADV";

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

  # --------------------------------------------------------------------------
  # USER ACCOUNT
  # --------------------------------------------------------------------------
  # IMPORTANT: Replace <username> with actual username
  users.users.<username> = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "seat" ];
    # Set initial password or use hashedPassword
    initialPassword = "changeme";
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
    # Nerd fonts - syntax changed in nixpkgs after 24.05
    # If using older nixpkgs: (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    # Current nixpkgs-unstable uses individual packages:
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
  system.stateVersion = "25.05";
}
