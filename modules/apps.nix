# modules/apps.nix
# User applications: media, productivity, communication, system utilities
{
  config,
  pkgs,
  lib,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    # ═══════════════════════════════════════════════════════════════
    # MEDIA VIEWERS
    # ═══════════════════════════════════════════════════════════════
    loupe # GNOME image viewer
    evince # PDF/document viewer
    celluloid # MPV frontend (GTK video player)
    mpv # Powerful CLI video player
    vlc

    # ═══════════════════════════════════════════════════════════════
    # MUSIC
    # ═══════════════════════════════════════════════════════════════
    feishin # Navidrome/Jellyfin client
    picard # MusicBrainz Picard - music tagger
    beets # Music library manager
    cava # Audio visualizer

    # ═══════════════════════════════════════════════════════════════
    # COMMUNICATION
    # ═══════════════════════════════════════════════════════════════
    vesktop # Discord client (Wayland-native, with Vencord)
    thunderbird # Email client
    signal-desktop # Encrypted messaging
    telegram-desktop # Telegram client

    # ═══════════════════════════════════════════════════════════════
    # OFFICE & PRODUCTIVITY
    # ═══════════════════════════════════════════════════════════════
    onlyoffice-desktopeditors # Office suite (latest)
    obsidian # Note-taking with Markdown

    # ═══════════════════════════════════════════════════════════════
    # SYSTEM UTILITIES
    # ═══════════════════════════════════════════════════════════════
    btop # Modern system monitor (terminal)
    mission-center # GNOME system monitor (GUI, like Windows Task Manager)

    # ═══════════════════════════════════════════════════════════════
    # FILE MANAGEMENT
    # ═══════════════════════════════════════════════════════════════
    file-roller # Archive manager (GUI)
    gnome-disk-utility # Disk management

    # Archive tools (for file-roller and CLI)
    unzip
    zip
    p7zip
    unrar

    # ═══════════════════════════════════════════════════════════════
    # SCREENSHOTS & RECORDING
    # ═══════════════════════════════════════════════════════════════
    # Screen recording
    gpu-screen-recorder # Lightweight GPU-accelerated recorder (AMD/NVIDIA/Intel)

    # ═══════════════════════════════════════════════════════════════
    # SECURITY & PASSWORDS
    # ═══════════════════════════════════════════════════════════════
    bitwarden-desktop # Password manager
    seahorse # GNOME Keyring GUI

    # ═══════════════════════════════════════════════════════════════
    # UTILITIES
    # ═══════════════════════════════════════════════════════════════
    gnome-calculator # Calculator
    gnome-clocks # World clocks, alarms, timers
    baobab # Disk usage analyzer
    localsend # AirDrop-like file sharing (cross-platform)

    # ═══════════════════════════════════════════════════════════════
    # SYSTEM TOOLS
    # ═══════════════════════════════════════════════════════════════
    rclone # Cloud storage sync (Google Drive, Dropbox, etc.)
  ];

  # GNOME Keyring for secrets storage
  services.gnome.gnome-keyring.enable = true;

  # Enable Flatpak for additional apps (Feishin, etc.)
  services.flatpak.enable = true;

  # Automatically add Flathub repository on system activation
  system.activationScripts.flatpak-flathub.text = ''
    ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
  '';
}
