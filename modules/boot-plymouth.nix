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
  # SYSTEMD IN INITRD (REQUIRED FOR PLYMOUTH + LUKS)
  # ═══════════════════════════════════════════════════════════════

  # Enable systemd-based initramfs instead of legacy stage-1 init.
  # This allows Plymouth to integrate with systemd's password agent,
  # displaying the LUKS encryption password prompt within the boot
  # animation instead of falling back to text mode.
  boot.initrd.systemd.enable = true;

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
