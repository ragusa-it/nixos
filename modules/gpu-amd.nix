# modules/gpu-amd.nix
# AMD GPU configuration: drivers, Vulkan, VA-API hardware acceleration, CoreCtrl
{ config, pkgs, lib, ... }:

{
  # Enable OpenGL/Vulkan
  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # For Steam and 32-bit games

    extraPackages = with pkgs; [
      # VA-API for hardware video acceleration
      vaapiVdpau
      libvdpau-va-gl

      # AMD-specific
      amdvlk              # AMD's official Vulkan driver (alternative to RADV)
      rocmPackages.clr.icd  # OpenCL support
    ];

    extraPackages32 = with pkgs.driversi686Linux; [
      # 32-bit VA-API support for older games
      vaapiVdpau
      libvdpau-va-gl
      amdvlk
    ];
  };

  # Use RADV (Mesa) as default Vulkan driver - generally better for gaming
  # AMDVLK is available as fallback via VK_ICD_FILENAMES
  environment.variables = {
    AMD_VULKAN_ICD = "RADV";  # Use RADV by default
  };

  # CoreCtrl for fan curves, overclocking, and GPU monitoring
  programs.corectrl = {
    enable = true;
    gpuOverclock.enable = true;  # Enable overclocking capabilities
  };

  # Add user to corectrl group for full access without password
  users.users.pinj.extraGroups = [ "corectrl" ];

  # Kernel parameters for AMD GPU
  boot.kernelParams = [
    # Enable all power management features
    "amdgpu.ppfeaturemask=0xffffffff"
  ];

  # GPU monitoring tools
  environment.systemPackages = with pkgs; [
    # Monitoring
    radeontop           # AMD GPU monitoring (like nvidia-smi)
    nvtopPackages.amd   # Modern GPU monitor with AMD support

    # Vulkan tools
    vulkan-tools        # vulkaninfo, etc.
    vulkan-loader

    # Video acceleration verification
    libva-utils         # vainfo - verify VA-API
    vdpauinfo           # Verify VDPAU
  ];
}
