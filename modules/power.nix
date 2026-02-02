# modules/power.nix
# Power management for desktop: CPU governor control, power profiles
{ config, pkgs, lib, ... }:

{
  # ═══════════════════════════════════════════════════════════════
  # POWER PROFILES DAEMON
  # ═══════════════════════════════════════════════════════════════
  # Provides power-saver, balanced, and performance profiles
  # Can be switched via CLI or desktop integration
  services.power-profiles-daemon.enable = true;

  # ═══════════════════════════════════════════════════════════════
  # CPU FREQUENCY SCALING
  # ═══════════════════════════════════════════════════════════════
  # Use schedutil for modern AMD CPUs (responds to load dynamically)
  powerManagement.cpuFreqGovernor = "schedutil";

  # ═══════════════════════════════════════════════════════════════
  # PACKAGES
  # ═══════════════════════════════════════════════════════════════
  environment.systemPackages = with pkgs; [
    power-profiles-daemon # Already enabled as service, CLI tool for control
  ];

  # ═══════════════════════════════════════════════════════════════
  # KERNEL PARAMETERS FOR POWER EFFICIENCY
  # ═══════════════════════════════════════════════════════════════
  # These help reduce power draw on idle desktop systems
  boot.kernelParams = [
    # Enable AMD P-State driver for modern Ryzen CPUs
    "amd_pstate=active"
  ];
}
