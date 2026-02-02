# modules/desktop.nix
# Core desktop infrastructure: portals, polkit, launcher, screen lock, wallpaper, idle
{ config, pkgs, inputs, lib, ... }:

{
  # XDG Portal - Required for screen sharing, file pickers, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "*";
  };

  # Polkit - GUI privilege escalation
  security.polkit.enable = true;

  # Polkit authentication agent (runs on login)
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

  # Screen locker service (swayidle triggers this)
  systemd.user.services.swaylock = {
    description = "Screen Locker";
    serviceConfig = {
      Type = "forking";
      ExecStart = "${pkgs.swaylock-effects}/bin/swaylock -f";
    };
  };

  # Idle daemon - lock screen and turn off display
  systemd.user.services.swayidle = {
    description = "Idle Manager";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.swayidle}/bin/swayidle -w \
          timeout 300 'systemctl --user start swaylock' \
          timeout 600 'niri msg action power-off-monitors' \
          before-sleep 'systemctl --user start swaylock'
      '';
      Restart = "on-failure";
      RestartSec = 1;
    };
  };

  # Wallpaper service
  systemd.user.services.swaybg = {
    description = "Wallpaper Daemon";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      # Default to a solid color - change path to your wallpaper
      ExecStart = "${pkgs.swaybg}/bin/swaybg -c '#1e1e2e'";
      Restart = "on-failure";
    };
  };

  # Desktop packages
  environment.systemPackages = with pkgs; [
    # Vicinae launcher
    inputs.vicinae.packages.${pkgs.system}.default

    # Screen lock & idle
    swaylock-effects
    swayidle

    # Wallpaper
    swaybg

    # Polkit agent
    polkit_gnome

    # Portal helpers
    xdg-utils
    xdg-user-dirs

    # Wayland utilities
    wl-clipboard
    wtype            # Wayland keyboard automation
    wlr-randr        # Display configuration
    wayland-utils    # Debug utilities
  ];

  # Environment variables for Wayland compatibility
  environment.sessionVariables = {
    # Wayland defaults
    NIXOS_OZONE_WL = "1";           # Electron apps use Wayland
    MOZ_ENABLE_WAYLAND = "1";       # Firefox Wayland
    QT_QPA_PLATFORM = "wayland";    # Qt apps use Wayland
    SDL_VIDEODRIVER = "wayland";    # SDL games use Wayland
    _JAVA_AWT_WM_NONREPARENTING = "1"; # Java apps fix

    # XDG
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "niri";
  };

  # Enable dconf for GTK settings
  programs.dconf.enable = true;

  # GNOME services for better desktop integration
  services.gvfs.enable = true;        # Virtual filesystem (trash, MTP, SMB)
  services.udisks2.enable = true;     # Disk mounting
}
