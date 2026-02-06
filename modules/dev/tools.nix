# modules/dev/tools.nix
# Development tools and CLI utilities
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  environment.systemPackages = with pkgs; [
    nodePackages.codex
    bun
    pnpm
    fastfetch
    nodejs
    python3
    rustup
    gcc
    gnumake
    cmake
    pkg-config
    git
    gh
    delta
    lazygit
    gnupg
    micro
    wget
    curl
    sbctl
    nixd
    nil
    nixfmt
    jq
    yq
    ripgrep
    fd
    fzf
    eza
    unzip
    zip
    p7zip
    unrar
    btop
    bat
    broot
    tealdeer
    duf
    sd
    pv
    parallel
    claude-code
    inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
