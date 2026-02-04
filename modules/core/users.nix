# modules/core/users.nix
# User accounts and shell configuration
{
  config,
  pkgs,
  lib,
  username,
  ...
}:

{
  users.users.${username} = {
    isNormalUser = true;
    description = "Melvin Ragusa";
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
      "gamemode"
      "corectrl"
    ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
  programs.zsh.enable = true;
}
