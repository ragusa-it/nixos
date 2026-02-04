# modules/desktop.nix
# Core desktop infrastructure: portals, polkit, launcher, screen lock, wallpaper, idle
{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  # ═══════════════════════════════════════════════════════════════
  # XDG PORTALS
  # ═══════════════════════════════════════════════════════════════
  # Required for screen sharing, file pickers, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    config.common = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
    };
  };

  # ═══════════════════════════════════════════════════════════════
  # POLKIT
  # ═══════════════════════════════════════════════════════════════
  # GUI privilege escalation
  security.polkit.enable = true;

  # Polkit authentication agent
  systemd.user.services.polkit-gnome-agent = {
    description = "Polkit GNOME Authentication Agent";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  # ═══════════════════════════════════════════════════════════════
  # DESKTOP PACKAGES
  # ═══════════════════════════════════════════════════════════════
  environment.systemPackages = with pkgs; [
    # Polkit agent
    polkit_gnome

    # Portal helpers
    xdg-utils
    xdg-user-dirs

    # Wayland utilities
    wl-clipboard
    wtype # Wayland keyboard automation
    wlr-randr # Display configuration
    wayland-utils # Debug utilities

    # ─── Additional Desktop Utilities ───
    cliphist # Clipboard history for Wayland
    wlsunset # Blue light filter / night mode
    brightnessctl # Brightness control (even for desktop monitors via DDC)
    wlogout # Logout menu / session manager
    bazaar # App Store
  ];

  # ═══════════════════════════════════════════════════════════════
  # WAYLAND ENVIRONMENT
  # ═══════════════════════════════════════════════════════════════
  # Environment variables for Wayland compatibility
  environment.sessionVariables = {
    # Wayland defaults
    NIXOS_OZONE_WL = "1"; # Electron apps use Wayland
    MOZ_ENABLE_WAYLAND = "1"; # Firefox Wayland
    QT_QPA_PLATFORM = "wayland"; # Qt apps use Wayland
    SDL_VIDEODRIVER = "wayland"; # SDL games use Wayland
    _JAVA_AWT_WM_NONREPARENTING = "1"; # Java apps fix

    # XDG
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "niri";

    # Theming (consolidated from theming.nix)
    QT_QPA_PLATFORMTHEME = "qt6ct";
    GTK_THEME = "adw-gtk3-dark";
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
  };

  # ═══════════════════════════════════════════════════════════════
  # GNOME SERVICES
  # ═══════════════════════════════════════════════════════════════
  # Better desktop integration
  services.gvfs.enable = true; # Virtual filesystem (trash, MTP, SMB)
  services.udisks2.enable = true; # Disk mounting
}
