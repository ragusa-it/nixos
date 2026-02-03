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
  users.users.${username}.extraGroups = [ "docker" ];

  # Direnv for per-project environments
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true; # Faster direnv for Nix
  };

  # Development packages
  # NOTE: GUI tools (dbeaver) and optional TUIs (lazygit, lazydocker) are in `nix profile`
  environment.systemPackages = with pkgs; [
    # ─────────────────────────────────────────────────────────────
    # Containers
    # ─────────────────────────────────────────────────────────────
    docker-compose # Docker Compose v2

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
    delta # Better git diff
    lazygit # Git UI

    # ─────────────────────────────────────────────────────────────
    # Editors & LSP
    # ─────────────────────────────────────────────────────────────
    # nil already in base config (Nix LSP)
    nixfmt # Nix formatter

    # ─────────────────────────────────────────────────────────────
    # CLI Utilities (used by shell aliases)
    # ─────────────────────────────────────────────────────────────
    jq # JSON processor
    yq # YAML processor
    ripgrep # Fast grep
    fd # Fast find
    fzf # Fuzzy finder
    eza # Modern ls
    bat # Cat with syntax highlighting
    broot

    # Additional CLI tools
    tealdeer # tldr - simplified man pages
    duf # Better df (disk usage)
    sd # Better sed (find & replace)
    pv # Pipe viewer (progress bar for pipes)
    parallel # GNU parallel (run commands in parallel)
  ];

  # Note: Shell aliases are now managed in shell.nix (Fish shell)
  # Zsh is kept as a fallback shell but Fish is the primary
}
