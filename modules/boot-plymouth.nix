# modules/boot-plymouth.nix
# Plymouth boot splash with NixOS branding
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ═══════════════════════════════════════════════════════════════
  # PLYMOUTH BOOT SPLASH
  # ═══════════════════════════════════════════════════════════════

  boot.plymouth = {
    enable = true;
    theme = "nixos-bgrt";
    themePackages = [ pkgs.nixos-bgrt-plymouth ];
  };

  # ═══════════════════════════════════════════════════════════════
  # SILENT BOOT KERNEL PARAMETERS
  # ═══════════════════════════════════════════════════════════════

  boot.kernelParams = [
    # Plymouth boot splash
    "quiet"
    "splash"

    # Reduce console log verbosity
    "loglevel=3"
    "rd.udev.log_level=3"

    # Hide systemd status messages
    "systemd.show_status=auto"

    # Hide blinking cursor
    "vt.global_cursor_default=0"
  ];

  # ═══════════════════════════════════════════════════════════════
  # CONSOLE SETTINGS
  # ═══════════════════════════════════════════════════════════════

  # Keep console blank during boot
  boot.consoleLogLevel = 3;
}
