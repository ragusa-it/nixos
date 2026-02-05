{
  description = "NixOS Configurations - atlas, laptop, and server";

  # ═══════════════════════════════════════════════════════════════
  # INPUTS
  # ═══════════════════════════════════════════════════════════════
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Desktop shell
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Kernel
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    # Browser
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # AI coding assistant
    opencode = {
      url = "github:anomalyco/opencode";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Binary caches for faster builds
  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://attic.xuyh0120.win/lantian"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    ];
  };

  # ═══════════════════════════════════════════════════════════════
  # OUTPUTS
  # ═══════════════════════════════════════════════════════════════
  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      username = "pinj";

      # Helper function to create NixOS configurations
      mkHost =
        hostname:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs username;
          };
          modules = [
            ./hosts/${hostname}/configuration.nix
            { nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ]; }
          ];
        };
    in
    {
      nixosConfigurations = {
        # Desktop - full gaming and media setup
        atlas = mkHost "atlas";

        # Server - headless, core + dev only
        server = mkHost "server";

        # Laptop - desktop environment, no gaming
        laptop = mkHost "laptop";
      };
    };
}
