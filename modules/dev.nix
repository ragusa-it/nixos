# modules/dev.nix
# Development tools: Docker, Node.js, direnv, build tools
{
  config,
  pkgs,
  lib,
  username,
  ...
}:

{
  # ═══════════════════════════════════════════════════════════════
  # DOCKER
  # ═══════════════════════════════════════════════════════════════
  virtualisation.docker = {
    enable = true;

    # Recommended settings
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--all" ];
    };
  };

  # Add user to docker group
  users.users.${username}.extraGroups = [ "docker" ];

  # ═══════════════════════════════════════════════════════════════
  # DIRENV
  # ═══════════════════════════════════════════════════════════════
  # Per-project environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true; # Faster direnv for Nix
  };

  # ═══════════════════════════════════════════════════════════════
  # DEVELOPMENT PACKAGES
  # ═══════════════════════════════════════════════════════════════
  environment.systemPackages = with pkgs; [
    # ─── Containers ───
    docker-compose # Docker Compose v2
    lazydocker

    # ─── Languages & Runtimes ───
    bun
    pnpm
    nodejs
    python3
    rustup

    # ─── Build Tools ───
    gcc
    gnumake
    cmake
    pkg-config

    # ─── Version Control ───
    git
    gh
    delta
    lazygit

    # ─── Editors & LSP ───
    nil
    nixfmt

    # ─── CLI Utilities ───
    jq # JSON processor
    yq # YAML processor
    ripgrep # Fast grep
    fd # Fast find
    fzf # Fuzzy finder
    eza # Modern ls
    bat # Cat with syntax highlighting
    broot # TUI Folder Tree

    # Additional CLI tools
    tealdeer # tldr - simplified man pages
    duf # Better df (disk usage)
    sd # Better sed (find & replace)
    pv # Pipe viewer (progress bar for pipes)
    parallel # GNU parallel (run commands in parallel)
  ];
}
