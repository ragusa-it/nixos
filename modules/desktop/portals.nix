# modules/desktop/portals.nix
# XDG portals and polkit authentication
{
  config,
  pkgs,
  lib,
  ...
}:

{
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
    };
  };

  security.polkit.enable = true;

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

  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.gnome.gnome-online-accounts.enable = true;

  environment.systemPackages = with pkgs; [
    polkit_gnome
    xdg-utils
    xdg-user-dirs
    wl-clipboard
    wtype
    wlr-randr
    wayland-utils
    cliphist
    wlsunset
    brightnessctl
    wlogout
    bazaar
    matugen
  ];

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    GIO_EXTRA_MODULES = [ "${pkgs.gvfs}/lib/gio/modules" ];
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "niri";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    XCURSOR_THEME = "default";
    XCURSOR_SIZE = "24";
  };

  environment.pathsToLink = [ "/share/icons" ];
}
