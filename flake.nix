{
  description = "NixOS - Isolated Gaming & Dev configurations";

  # SECURITY NOTE: After first build, commit flake.lock to pin inputs to specific
  # commits. Update via `nix flake update` only from trusted sources.
  # This protects against supply-chain attacks from upstream changes.
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    mango = {
      url = "github:DreamMaoMao/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.quickshell.follows = "quickshell";
    };

    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, mango, quickshell, noctalia, nix-gaming, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    specialArgs = { inherit inputs system; };

    # Verify mango flake exports the expected module
    mangoModule = assert lib.hasAttrByPath [ "nixosModules" "mango" ] mango;
      mango.nixosModules.mango;

    commonModules = [
      ./hosts/atlas/hardware-configuration.nix
      ./modules/common.nix
      mangoModule
      # Home Manager module - Foundation for user-level package management
      # User-specific configurations can be added via home-manager.users.<username>
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ];
  in {
    nixosConfigurations = {
      # Development configuration
      dev = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = commonModules ++ [ ./modules/dev.nix ];
      };

      # Gaming configuration
      gaming = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules = commonModules ++ [ ./modules/gaming.nix ];
      };
    };
  };
}
