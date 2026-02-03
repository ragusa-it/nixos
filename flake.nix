{
  description = "atlas - NixOS Config for Desktop";

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

    # Application launcher
    vicinae = {
      url = "github:vicinaehq/vicinae";
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
      "https://vicinae.cachix.org"
      "https://nix-community.cachix.org"
      "https://attic.xuyh0120.win/lantian"
    ];
    extra-trusted-public-keys = [
      "vicinae.cachix.org-1:1kDrfienkGHPYbkpNj1mWTr7Fm1+zcenzgTizIcI3oc="
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
      username = "pinj"; # Single source of truth for username
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs username;
        };
        modules = [
          ./configuration.nix
          { nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ]; }
        ];
      };
    };
}
