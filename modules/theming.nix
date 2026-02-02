# modules/theming.nix
# Visual theming: fonts, GTK/Qt themes, cursors, icons
{ config, pkgs, lib, ... }:

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
      inter                     # Modern UI font
      noto-fonts               # Wide Unicode coverage
      noto-fonts-cjk-sans      # Chinese, Japanese, Korean
      noto-fonts-emoji         # Color emoji

      # Optional nice fonts
      source-sans              # Adobe Source Sans
      source-serif             # Adobe Source Serif
      source-code-pro          # Adobe Source Code
      fira-code                # Alternative coding font with ligatures
    ];

    fontconfig = {
      enable = true;

      # Default fonts
      defaultFonts = {
        sansSerif = [ "Inter" "Noto Sans" ];
        serif = [ "Noto Serif" ];
        monospace = [ "JetBrainsMono Nerd Font" "JetBrains Mono" ];
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
    adw-gtk3              # GTK3 theme matching libadwaita
    adwaita-icon-theme    # GNOME icons (needed for many apps)

    # Icon theme
    papirus-icon-theme    # Modern, flat icons

    # Cursor theme
    bibata-cursors        # Modern cursor theme

    # Qt theming
    qt5ct                 # Qt5 configuration tool
    qt6ct                 # Qt6 configuration tool
    adwaita-qt            # Adwaita theme for Qt5
    adwaita-qt6           # Adwaita theme for Qt6

    # Theme tools
    dconf-editor          # Edit GNOME/GTK settings
    nwg-look              # GTK settings editor for Wayland
  ];

  # ─────────────────────────────────────────────────────────────
  # Qt Theming Environment
  # ─────────────────────────────────────────────────────────────
  environment.sessionVariables = {
    # Qt platform integration
    QT_QPA_PLATFORMTHEME = "qt5ct";

    # Cursor theme (for apps that don't respect system settings)
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
  };

  # ─────────────────────────────────────────────────────────────
  # GTK Settings via dconf
  # ─────────────────────────────────────────────────────────────
  # These can be overridden by the user with nwg-look or dconf-editor
  # Default theme settings are applied per-user

  programs.dconf = {
    enable = true;
    profiles.user.databases = [{
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "adw-gtk3-dark";
          icon-theme = "Papirus-Dark";
          cursor-theme = "Bibata-Modern-Classic";
          cursor-size = lib.gvariant.mkInt32 24;
          font-name = "Inter 11";
          document-font-name = "Inter 11";
          monospace-font-name = "JetBrainsMono Nerd Font 10";
        };
        "org/gnome/desktop/wm/preferences" = {
          titlebar-font = "Inter Bold 11";
        };
      };
    }];
  };
}
