# modules/hardware/power.nix
# Power management and CPU governor
{
  config,
  pkgs,
  lib,
  ...
}:

{
  services.power-profiles-daemon.enable = true;
  powerManagement.cpuFreqGovernor = "schedutil";

  environment.systemPackages = with pkgs; [
    power-profiles-daemon
  ];
}
