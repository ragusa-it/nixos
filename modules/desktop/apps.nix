# modules/desktop/apps.nix
# GUI applications and system packages
{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    # Core utilities
    gnupg
    fastfetch
    micro
    wget
    curl
    sbctl
    nil
    nixd

    # Wayland
    xwayland-satellite
    grim
    slurp

    # File management
    nautilus

    # Editors and browsers
    zed-editor
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Desktop shell
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Terminal
    ghostty
    claude-code

    # Media viewers
    loupe
    evince
    celluloid
    mpv
    vlc

    # Music
    feishin
    picard
    beets
    cava

    # Communication
    vesktop
    thunderbird
    signal-desktop
    telegram-desktop

    # Office
    onlyoffice-desktopeditors
    obsidian

    # System utilities
    btop
    mission-center
    file-roller
    gnome-disk-utility
    unzip
    zip
    p7zip
    unrar

    # Recording
    gpu-screen-recorder

    # Security
    bitwarden-desktop
    seahorse

    # Utilities
    gnome-calculator
    gnome-clocks
    baobab
    localsend
    protonvpn-gui
    protonmail-bridge-gui

    # Cloud sync
    rclone
  ];

  services.gnome.gnome-keyring.enable = true;

  services.flatpak.enable = true;
  system.activationScripts.flatpak-flathub.text = ''
    ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
  '';

  programs.yazi.enable = true;
  programs.firefox.enable = true;
}
