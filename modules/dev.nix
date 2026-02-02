# modules/dev.nix
# Development tools: Docker, Node.js, direnv, build tools
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Docker
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
  users.users.pinj.extraGroups = [ "docker" ];

  # Direnv for per-project environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true; # Faster direnv for Nix
  };

  # Development packages
  environment.systemPackages = with pkgs; [
    # ─────────────────────────────────────────────────────────────
    # Containers
    # ─────────────────────────────────────────────────────────────
    docker-compose # Docker Compose v2
    lazydocker # Terminal UI for Docker

    # ─────────────────────────────────────────────────────────────
    # Languages & Runtimes
    # ─────────────────────────────────────────────────────────────
    nodejs_22 # Node.js LTS (for Vicinae extensions, etc.)
    bun # Fast JavaScript runtime/bundler
    python3 # Python 3
    rustup # Rust toolchain manager

    # ─────────────────────────────────────────────────────────────
    # Build Tools
    # ─────────────────────────────────────────────────────────────
    gcc
    gnumake
    cmake
    pkg-config

    # ─────────────────────────────────────────────────────────────
    # Version Control
    # ─────────────────────────────────────────────────────────────
    git
    gh # GitHub CLI
    lazygit # Terminal UI for Git
    delta # Better git diff

    # ─────────────────────────────────────────────────────────────
    # Editors & LSP
    # ─────────────────────────────────────────────────────────────
    # nil already in base config (Nix LSP)
    nixfmt # Nix formatter

    # ─────────────────────────────────────────────────────────────
    # CLI Utilities
    # ─────────────────────────────────────────────────────────────
    jq # JSON processor
    yq # YAML processor
    ripgrep # Fast grep
    fd # Fast find
    fzf # Fuzzy finder
    eza # Modern ls
    bat # Cat with syntax highlighting
    httpie # Better curl
    curlie # Curl wrapper with httpie-like syntax

    # Additional CLI tools (migrated from Arch)
    tealdeer # tldr - simplified man pages
    duf # Better df (disk usage)
    sd # Better sed (find & replace)
    pv # Pipe viewer (progress bar for pipes)
    parallel # GNU parallel (run commands in parallel)
    inxi # System information tool
    glances # System monitor (htop alternative)
    grc # Generic colorizer for CLI output

    # ─────────────────────────────────────────────────────────────
    # Database Tools
    # ─────────────────────────────────────────────────────────────
    dbeaver-bin # Universal database tool (GUI)
  ];

  # Note: Shell aliases are now managed in shell.nix (Fish shell)
  # Zsh is kept as a fallback shell but Fish is the primary
}
