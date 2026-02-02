# modules/theming.nix
# Visual theming: fonts, GTK/Qt themes, cursors, icons
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # ─────────────────────────────────────────────────────────────
  # Fonts
  # ─────────────────────────────────────────────────────────────
  fonts = {
    packages = with pkgs; [
      # Your existing fonts
      jetbrains-mono
      nerd-fonts.jetbrains-mono

      # Additional fonts for full coverage
      inter # Modern UI font
      noto-fonts # Wide Unicode coverage
      noto-fonts-cjk-sans # Chinese, Japanese, Korean
      noto-fonts-color-emoji # Color emoji

      # Optional nice fonts
      source-sans # Adobe Source Sans
      source-serif # Adobe Source Serif
      source-code-pro # Adobe Source Code
      fira-code # Alternative coding font with ligatures
    ];

    fontconfig = {
      enable = true;

      # Default fonts
      defaultFonts = {
        sansSerif = [
          "Inter"
          "Noto Sans"
        ];
        serif = [ "Noto Serif" ];
        monospace = [
          "JetBrainsMono Nerd Font"
          "JetBrains Mono"
        ];
        emoji = [ "Noto Color Emoji" ];
      };

      # Font rendering settings
      hinting = {
        enable = true;
        style = "slight";
      };
      antialias = true;
      subpixel.rgba = "rgb";
    };
  };

  # ─────────────────────────────────────────────────────────────
  # GTK Theme
  # ─────────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # GTK themes
    adw-gtk3 # GTK3 theme matching libadwaita
    adwaita-icon-theme # GNOME icons (needed for many apps)

    # Icon theme
    papirus-icon-theme # Modern, flat icons

    # Cursor theme (Adwaita cursor is included in adwaita-icon-theme above)

    # Qt theming
    libsForQt5.qt5ct # Qt5 configuration tool
    kdePackages.qt6ct # Qt6 configuration tool

    # Theme tools
    dconf-editor # Edit GNOME/GTK settings
    nwg-look # GTK settings editor for Wayland
  ];

  # ─────────────────────────────────────────────────────────────
  # Environment Variables for Theming
  # ─────────────────────────────────────────────────────────────
  environment.sessionVariables = {
    # Qt platform integration
    QT_QPA_PLATFORMTHEME = "qt6ct";

    # GTK theme (for apps that don't read dconf)
    GTK_THEME = "adw-gtk3-dark";

    # Cursor theme
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
  };

  # Ensure cursor themes are found
  environment.pathsToLink = [ "/share/icons" ];

  # ─────────────────────────────────────────────────────────────
  # GTK Settings via dconf
  # ─────────────────────────────────────────────────────────────
  # These can be overridden by the user with nwg-look or dconf-editor
  # Default theme settings are applied per-user

  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            gtk-theme = "adw-gtk3-dark";
            icon-theme = "Papirus-Dark";
            cursor-theme = "Adwaita";
            cursor-size = lib.gvariant.mkInt32 24;
            font-name = "Inter 11";
            document-font-name = "Inter 11";
            monospace-font-name = "JetBrainsMono Nerd Font 10";
          };
          "org/gnome/desktop/wm/preferences" = {
            titlebar-font = "Inter Bold 11";
          };
        };
      }
    ];
  };
}
