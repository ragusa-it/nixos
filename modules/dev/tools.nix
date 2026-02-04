# modules/dev/tools.nix
# Development tools and CLI utilities
{
  config,
  pkgs,
  lib,
  ...
}:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  environment.systemPackages = with pkgs; [
    bun
    pnpm
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
    nil
    nixfmt
    jq
    yq
    ripgrep
    fd
    fzf
    eza
    bat
    broot
    tealdeer
    duf
    sd
    pv
    parallel
  ];
}
