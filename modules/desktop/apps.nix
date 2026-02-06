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
    xwayland-satellite
    grim
    slurp
    mission-center
    file-roller
    gnome-disk-utility

    # File management
    nautilus

    # Editor
    zed-editor

    # Zen Browser
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Desktop shell
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Terminal
    ghostty

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
    gitkraken

    # Game Launchers
    lutris
    heroic

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
