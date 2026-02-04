# modules/desktop/theming.nix
# Fonts, themes, and visual configuration
{
  config,
  pkgs,
  lib,
  ...
}:

{
  fonts = {
    packages = with pkgs; [
      jetbrains-mono
      nerd-fonts.jetbrains-mono
      inter
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      source-sans
      source-serif
      source-code-pro
      fira-code
    ];

    fontconfig = {
      enable = true;
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
      hinting = {
        enable = true;
        style = "slight";
      };
      antialias = true;
      subpixel.rgba = "rgb";
    };
  };

  environment.systemPackages = with pkgs; [
    adw-gtk3
    adwaita-icon-theme
    papirus-icon-theme
    libsForQt5.qt5ct
    kdePackages.qt6ct
    dconf-editor
    nwg-look
  ];
}
