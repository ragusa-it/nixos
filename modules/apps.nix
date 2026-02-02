# modules/apps.nix
# User applications: media, productivity, communication, system utilities
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # NOTE: Most GUI apps are managed via `nix profile` for faster updates
  # Run `update-apps` to update, `list-apps` to see installed
  environment.systemPackages = with pkgs; [
    # ─────────────────────────────────────────────────────────────
    # File Management (GNOME integration)
    # ─────────────────────────────────────────────────────────────
    file-roller # Archive manager (GUI)
    gnome-disk-utility # Disk management

    # Archive tools (for file-roller and CLI)
    unzip
    zip
    p7zip
    unrar

    # ─────────────────────────────────────────────────────────────
    # Security (GNOME Keyring integration)
    # ─────────────────────────────────────────────────────────────
    seahorse # GNOME Keyring GUI

    # ─────────────────────────────────────────────────────────────
    # System Tools
    # ─────────────────────────────────────────────────────────────
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
