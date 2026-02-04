# modules/services/avahi.nix
# mDNS for local network discovery
{
  config,
  pkgs,
  lib,
  ...
}:

{
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;

    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
}
