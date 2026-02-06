# modules/core/boot.nix
# Bootloader, kernel, and boot-time configuration
{
  config,
  pkgs,
  lib,
  ...
}:

{
  boot.loader.systemd-boot.enable = false;
  boot.loader.limine = {
    enable = true;
    style.wallpapers = [ ../../wallpaper/nix.png ];
    maxGenerations = 5;
  };
  boot.loader.limine.secureBoot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-server;

  boot.kernelParams = [
    "amd_pstate=active"
    "amdgpu.ppfeaturemask=0xffffffff"
    "quiet"
    "splash"
    "loglevel=3"
    "rd.udev.log_level=3"
    "systemd.show_status=auto"
    "vt.global_cursor_default=0"
  ];

  boot.consoleLogLevel = 3;
  boot.resumeDevice = "/dev/mapper/cryptswap";

  boot.initrd.systemd.enable = true;
  boot.plymouth = {
    enable = true;
    theme = "nixos-bgrt";
    themePackages = [ pkgs.nixos-bgrt-plymouth ];
  };

  services.scx.enable = true;
  services.scx.scheduler = "scx_lavd";
}
