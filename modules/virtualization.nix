# modules/virtualization.nix
# Virtual machine support: QEMU, KVM, libvirt, virt-manager
{ config, pkgs, lib, ... }:

{
  # ═══════════════════════════════════════════════════════════════
  # LIBVIRT & QEMU
  # ═══════════════════════════════════════════════════════════════
  virtualisation.libvirtd = {
    enable = true;

    # QEMU configuration
    qemu = {
      package = pkgs.qemu_kvm;

      # Enable UEFI support for VMs
      ovmf = {
        enable = true;
        packages = [ pkgs.OVMFFull.fd ];
      };

      # Enable TPM emulation for Windows 11
      swtpm.enable = true;

      # Run QEMU as non-root for better security
      runAsRoot = false;
    };
  };

  # ═══════════════════════════════════════════════════════════════
  # SPICE SUPPORT (for better VM display/clipboard/USB)
  # ═══════════════════════════════════════════════════════════════
  virtualisation.spiceUSBRedirection.enable = true;

  # ═══════════════════════════════════════════════════════════════
  # NETWORKING FOR VMS
  # ═══════════════════════════════════════════════════════════════
  # Enable default NAT network (virbr0)
  networking.firewall.trustedInterfaces = [ "virbr0" ];

  # ═══════════════════════════════════════════════════════════════
  # PACKAGES
  # ═══════════════════════════════════════════════════════════════
  environment.systemPackages = with pkgs; [
    virt-manager        # GUI for managing VMs
    virt-viewer         # Viewer for VM displays (SPICE/VNC)
    virtiofsd           # Fast file sharing between host and VM
    qemu-utils          # QEMU utilities (qemu-img, etc.)
    spice-gtk           # SPICE client libraries
  ];

  # ═══════════════════════════════════════════════════════════════
  # USER PERMISSIONS
  # ═══════════════════════════════════════════════════════════════
  users.users.pinj.extraGroups = [ "libvirtd" ];

  # ═══════════════════════════════════════════════════════════════
  # DCONF SETTINGS FOR VIRT-MANAGER
  # ═══════════════════════════════════════════════════════════════
  # Auto-connect to the system QEMU/KVM
  programs.virt-manager.enable = true;
}
