{ pkgs, username, ... }:

{
  # Identification tag (shows in boot menu and `nixos-version`)
  system.nixos.tags = [ "dev" ];

  # --------------------------------------------------------------------------
  # KERNEL - Latest stable for RDNA 4 GPU support
  # --------------------------------------------------------------------------
  # NOTE: LTS kernels often lag behind new GPU support.
  # For RDNA 4 (RX 9060 XT), use linuxPackages_latest instead of linuxPackages.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # --------------------------------------------------------------------------
  # DOCKER
  # --------------------------------------------------------------------------
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # NOTE: After first enabling/applying this dev profile, you must log out and
  # log back in (or reboot) for the docker group membership to take effect.
  users.users.${username}.extraGroups = [ "docker" ];

  # --------------------------------------------------------------------------
  # DEVELOPMENT TOOLS
  # --------------------------------------------------------------------------
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;  # Caches nix shells
  };

  users.users.${username}.packages = with pkgs; [
    # -- Git --
    lazygit
    gh              # GitHub CLI
    delta           # Git diff viewer
    meld            # Visual diff tool

    # -- Node.js --
    nodejs_22
    nodePackages.pnpm
    nodePackages.yarn

    # -- CLI Tools --
    httpie          # HTTP client
    jq              # JSON processor
    yq              # YAML processor
    fd              # Find alternative
    ripgrep         # Grep alternative
    eza             # ls alternative
    bat             # cat alternative
    fzf             # Fuzzy finder
    zoxide          # cd alternative

    # -- Database & API Tools --
    postgresql      # psql client
    dbeaver-bin     # Database GUI
    insomnia        # API testing
    # redis          # Uncomment if needed

    # -- Misc --
    gnumake
    gcc
  ];

  # --------------------------------------------------------------------------
  # SERVICES (Optional - uncomment if needed)
  # --------------------------------------------------------------------------
  # Local PostgreSQL
  # services.postgresql = {
  #   enable = true;
  #   ensureDatabases = [ "devdb" ];
  #   ensureUsers = [{
  #     name = "<username>";
  #     ensureDBOwnership = true;
  #   }];
  # };

  # Local Redis
  # services.redis.servers."dev" = {
  #   enable = true;
  #   port = 6379;
  # };
}
