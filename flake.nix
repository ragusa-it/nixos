{
  description = "NixOS - Isolated Gaming & Dev configurations";

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
  };

  outputs = { self, nixpkgs, mango, quickshell, noctalia, ... }@inputs:
  let
    system = "x86_64-linux";
    specialArgs = { inherit inputs system; };

    # IMPORTANT: Replace <hostname> with actual hostname
    commonModules = [
      ./hosts/<hostname>/hardware-configuration.nix
      ./modules/common.nix
      mango.nixosModules.mango
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
