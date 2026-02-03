# modules/gpu-amd.nix
# AMD GPU configuration: drivers, Vulkan, VA-API hardware acceleration, CoreCtrl
{
  config,
  pkgs,
  lib,
  username,
  ...
}:

{
  # ═══════════════════════════════════════════════════════════════
  # AMD GPU DRIVERS
  # ═══════════════════════════════════════════════════════════════
  # Enable OpenGL/Vulkan
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # For Steam and 32-bit games

    extraPackages = with pkgs; [
      # VA-API for hardware video acceleration
      libva-vdpau-driver # Renamed from vaapiVdpau
      libvdpau-va-gl

      # OpenCL support (optional, for compute workloads)
      rocmPackages.clr.icd
    ];

    extraPackages32 = with pkgs.driversi686Linux; [
      # 32-bit VA-API support for older games
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  # RADV (Mesa Vulkan driver) is enabled by default and is the best choice for gaming
  # No need for AMD_VULKAN_ICD environment variable anymore

  # ═══════════════════════════════════════════════════════════════
  # CORECTRL
  # ═══════════════════════════════════════════════════════════════
  # Fan curves, overclocking, and GPU monitoring
  programs.corectrl.enable = true;

  # AMD GPU overdrive/overclocking support
  hardware.amdgpu.overdrive.enable = true;

  # Add user to corectrl group for full access without password
  users.users.${username}.extraGroups = [ "corectrl" ];

  # NOTE: Kernel params (amdgpu.ppfeaturemask) are in configuration.nix

  # ═══════════════════════════════════════════════════════════════
  # GPU PACKAGES
  # ═══════════════════════════════════════════════════════════════
  environment.systemPackages = with pkgs; [
    # ─── Monitoring ───
    radeontop # AMD GPU monitoring (like nvidia-smi)
    nvtopPackages.amd # Modern GPU monitor with AMD support

    # ─── Vulkan Tools ───
    vulkan-tools # vulkaninfo, etc.
    vulkan-loader

    # ─── Video Acceleration ───
    libva-utils # vainfo - verify VA-API
    vdpauinfo # Verify VDPAU
  ];
}
