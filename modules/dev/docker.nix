# modules/dev/docker.nix
# Docker container runtime
{
  config,
  pkgs,
  lib,
  ...
}:

{
  virtualisation.docker = {
    enable = true;

    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--all" ];
    };
  };

  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker
  ];
}
