# modules/apps.nix
# User applications: media, productivity, communication, system utilities
{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # ─────────────────────────────────────────────────────────────
    # Media Viewers
    # ─────────────────────────────────────────────────────────────
    loupe               # GNOME image viewer
    evince              # PDF/document viewer
    celluloid           # MPV frontend (GTK video player)
    mpv                 # Powerful CLI video player

    # ─────────────────────────────────────────────────────────────
    # Music
    # ─────────────────────────────────────────────────────────────
    amberol             # Simple music player for local files
    feishin             # Navidrome/Jellyfin client
    picard              # MusicBrainz Picard - music tagger
    beets               # Music library manager
    cava                # Audio visualizer
    # Feishin available via Flatpak for Navidrome/Jellyfin

    # ─────────────────────────────────────────────────────────────
    # Communication
    # ─────────────────────────────────────────────────────────────
    vesktop             # Discord client (Wayland-native, with Vencord)
    thunderbird         # Email client
    signal-desktop      # Encrypted messaging
    telegram-desktop    # Telegram client

    # ─────────────────────────────────────────────────────────────
    # Office & Productivity
    # ─────────────────────────────────────────────────────────────
    libreoffice-fresh   # Office suite (latest)
    obsidian            # Note-taking with Markdown

    # ─────────────────────────────────────────────────────────────
    # System Utilities
    # ─────────────────────────────────────────────────────────────
    btop                # Modern system monitor (terminal)
    mission-center      # GNOME system monitor (GUI, like Windows Task Manager)
    
    # File management
    file-roller         # Archive manager (GUI)
    gnome-disk-utility  # Disk management

    # Archive tools (for file-roller and CLI)
    unzip
    zip
    p7zip
    unrar

    # ─────────────────────────────────────────────────────────────
    # Screenshots & Screen Recording
    # ─────────────────────────────────────────────────────────────
    swappy              # Screenshot annotation tool
    # grim + slurp already in your base config

    # Screen recording
    obs-studio          # Full-featured streaming/recording suite
    gpu-screen-recorder # Lightweight GPU-accelerated recorder (AMD/NVIDIA/Intel)
    kooha               # Simple GNOME-style screen recorder

    # ─────────────────────────────────────────────────────────────
    # Security & Passwords
    # ─────────────────────────────────────────────────────────────
    bitwarden-desktop   # Password manager
    seahorse            # GNOME Keyring GUI

    # ─────────────────────────────────────────────────────────────
    # Utilities
    # ─────────────────────────────────────────────────────────────
    gnome-calculator    # Calculator
    gnome-clocks        # World clocks, alarms, timers
    baobab              # Disk usage analyzer
    localsend           # AirDrop-like file sharing (cross-platform)
    meld                # Visual diff and merge tool
    rclone              # Cloud storage sync (Google Drive, Dropbox, etc.)
  ];

  # GNOME Keyring for secrets storage
  services.gnome.gnome-keyring.enable = true;

  # Enable Flatpak for additional apps (Feishin, etc.)
  services.flatpak.enable = true;

  # Add Flathub repository automatically on activation
  # Run manually after first boot: flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  # Then install Feishin: flatpak install flathub io.github.feishin.feishin
}
