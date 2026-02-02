# modules/navidrome.nix
# Self-hosted music streaming server
{
  config,
  pkgs,
  lib,
  username,
  ...
}:

{
  # ═══════════════════════════════════════════════════════════════
  # NAVIDROME MUSIC SERVER
  # ═══════════════════════════════════════════════════════════════
  services.navidrome = {
    enable = true;

    settings = {
      # Music library location
      MusicFolder = "/home/${username}/Music";

      # Server settings
      # Bind to localhost only - access via Tailscale if needed remotely
      Address = "127.0.0.1";
      Port = 4533;

      # UI settings
      UIWelcomeMessage = "Welcome to Navidrome!";

      # Enable transcoding (requires ffmpeg)
      EnableTranscodingConfig = true;

      # Scan settings
      ScanSchedule = "@every 1h"; # Rescan library every hour

      # Last.fm scrobbling (configure in UI after setup)
      LastFM.Enabled = true;

      # Enable sharing features
      EnableSharing = true;

      # Enable covers from external sources
      CoverArtPriority = "cover.*, folder.*, front.*, embedded, external";

      # Session timeout (24 hours)
      SessionTimeout = "24h";

      # Enable Prometheus metrics (optional)
      # Prometheus.Enabled = true;
    };
  };

  # Firewall not needed - Navidrome binds to localhost only
  # Uncomment if you need network access:
  # networking.firewall.allowedTCPPorts = [ 4533 ];

  # Ensure music directory exists and has correct permissions
  systemd.tmpfiles.rules = [
    "d /home/${username}/Music 0755 ${username} users -"
  ];
}
