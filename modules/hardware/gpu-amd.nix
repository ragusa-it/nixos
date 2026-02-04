# modules/hardware/gpu-amd.nix
# AMD GPU drivers, Vulkan, and video acceleration
{
  config,
  pkgs,
  lib,
  ...
}:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;

    extraPackages = with pkgs; [
      libva-vdpau-driver
      libvdpau-va-gl
      rocmPackages.clr.icd
    ];

    extraPackages32 = with pkgs.driversi686Linux; [
      libva-vdpau-driver
      libvdpau-va-gl
    ];
  };

  programs.corectrl.enable = true;
  hardware.amdgpu.overdrive.enable = true;

  environment.systemPackages = with pkgs; [
    radeontop
    nvtopPackages.amd
    vulkan-tools
    vulkan-loader
    libva-utils
    vdpauinfo
  ];
}
