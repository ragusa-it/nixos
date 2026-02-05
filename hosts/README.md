# Host Configurations

This directory contains NixOS configurations for multiple machines.

## Structure

```
hosts/
├── atlas/                    # Desktop gaming machine
│   ├── configuration.nix     # Main config (core + hardware + desktop + dev + gaming + services)
│   └── hardware-configuration.nix  # Hardware-specific settings
├── laptop/                   # Laptop with desktop environment
│   ├── configuration.nix     # Main config (core + hardware + desktop + dev + services)
│   └── hardware-configuration.nix  # Placeholder - generate on actual machine
└── server/                   # Headless server
    ├── configuration.nix     # Main config (core + hardware[no GPU] + dev + maintenance)
    └── hardware-configuration.nix  # Placeholder - generate on actual machine
```

## Module Assignments

### All Hosts
- **Core**: boot, networking, users, system, localization
- **Development**: tools, docker, shell

### Atlas & Laptop Only
- **Hardware**: GPU, audio, storage, power
- **Desktop**: window manager, apps, theming, portals
- **Services**: printing, avahi, maintenance (navidrome only on atlas)

### Atlas Only
- **Gaming**: steam, gamemode, wine

### Server Only
- Headless - no desktop or gaming
- SSH enabled for remote management

## Usage

### Build a specific host

```bash
# Build atlas (current desktop)
nixos-rebuild switch --flake .#atlas

# Build server (once hardware-config is ready)
nixos-rebuild switch --flake .#server

# Build laptop (once hardware-config is ready)
nixos-rebuild switch --flake .#laptop
```

### Setting up a new machine

1. Install NixOS on the target machine
2. Generate hardware config:
   ```bash
   sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
   ```
3. Copy that file to `hosts/<hostname>/hardware-configuration.nix` in this repo
4. Adjust `hosts/<hostname>/configuration.nix` as needed
5. Build and switch:
   ```bash
   nixos-rebuild switch --flake .#<hostname>
   ```

## Adding a new host

1. Create `hosts/<hostname>/` directory
2. Copy `configuration.nix` from similar host as template
3. Generate `hardware-configuration.nix` on target machine
4. Add to `flake.nix`:
   ```nix
   nixosConfigurations.<hostname> = mkHost "<hostname>";
   ```
