# modules/services/navidrome.nix
# Self-hosted music streaming server
{
  config,
  pkgs,
  lib,
  username,
  ...
}:

{
  services.navidrome = {
    enable = true;

    settings = {
      MusicFolder = "/home/${username}/Music";
      Address = "127.0.0.1";
      Port = 4533;
      UIWelcomeMessage = "Welcome to Navidrome!";
      EnableTranscodingConfig = true;
      ScanSchedule = "@every 1h";
      LastFM.Enabled = true;
      EnableSharing = true;
      CoverArtPriority = "cover.*, folder.*, front.*, embedded, external";
      SessionTimeout = "24h";
    };
  };

  systemd.tmpfiles.rules = [
    "d /home/${username}/Music 0755 ${username} users -"
  ];
}
