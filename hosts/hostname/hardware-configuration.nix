# This is a placeholder hardware-configuration.nix file.
# 
# IMPORTANT: Replace this file with your actual hardware-configuration.nix
# generated during NixOS installation, typically found at:
#   /etc/nixos/hardware-configuration.nix
#
# To generate a new hardware configuration, run:
#   sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
#
# This placeholder will NOT work for actual system builds.

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Example boot configuration (replace with your actual hardware)
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Example filesystem configuration (replace with your actual mounts)
  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/YOUR-ROOT-UUID";
  #   fsType = "ext4";
  # };
  # 
  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/YOUR-BOOT-UUID";
  #   fsType = "vfat";
  # };
  # 
  # swapDevices = [
  #   { device = "/dev/disk/by-uuid/YOUR-SWAP-UUID"; }
  # ];

  # CPU microcode updates for AMD
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
