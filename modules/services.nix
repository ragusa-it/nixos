# modules/services.nix
# System services: SSD maintenance, swap, mDNS, profile sync
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ═══════════════════════════════════════════════════════════════
  # SSD MAINTENANCE
  # ═══════════════════════════════════════════════════════════════
  # Weekly TRIM for SSDs (improves longevity and performance)
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  # ═══════════════════════════════════════════════════════════════
  # ZRAM SWAP
  # ═══════════════════════════════════════════════════════════════
  # Compressed swap in RAM - better than no swap, faster than disk
  zramSwap = {
    enable = true;
    algorithm = "zstd"; # Best compression ratio
    memoryPercent = 50; # Use up to 50% of RAM for compressed swap
  };

  # ═══════════════════════════════════════════════════════════════
  # MDNS / AVAHI
  # ═══════════════════════════════════════════════════════════════
  # mDNS for local network discovery (.local domains)
  services.avahi = {
    enable = true;
    nssmdns4 = true; # Enable .local resolution
    openFirewall = true; # Allow mDNS through firewall

    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  # ═══════════════════════════════════════════════════════════════
  # PROFILE SYNC DAEMON
  # ═══════════════════════════════════════════════════════════════
  # Sync browser profiles to RAM for faster performance
  # Works with Firefox/Zen Browser profiles
  services.psd = {
    enable = true;
  };

  # User needs to configure ~/.config/psd/psd.conf after first run
  # Default will auto-detect Firefox profiles

  # ═══════════════════════════════════════════════════════════════
  # ADDITIONAL SYSTEM OPTIMIZATIONS
  # ═══════════════════════════════════════════════════════════════

  # Enable firmware updates
  services.fwupd.enable = true;

  # Thermald for Intel CPUs (AMD uses different thermal management)
  # Uncomment if on Intel:
  # services.thermald.enable = true;

  # Early OOM killer - prevents system freeze on memory exhaustion
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5; # Start killing at 5% free memory
    freeSwapThreshold = 10; # Also consider swap
    enableNotifications = true;
  };

  # ═══════════════════════════════════════════════════════════════
  # LOCATE DATABASE
  # ═══════════════════════════════════════════════════════════════
  # Fast file search with plocate
  services.locate = {
    enable = true;
    package = pkgs.plocate;
    interval = "daily";
  };
}
