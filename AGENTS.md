# AGENTS.md - NixOS Configuration Guidelines

Guidelines for AI agents working with this NixOS flake-based configuration.

## Project Overview

Modular NixOS configuration for a desktop workstation using Nix flakes.

**Tech Stack:** NixOS, Nix Flakes, Fish shell, Wayland (Niri), AMD GPU

## Repository Structure

```
nixos/
├── flake.nix                 # Flake inputs and outputs
├── configuration.nix         # Main config (imports all modules)
├── hardware-configuration.nix # Auto-generated (don't edit)
├── overlays/                 # Custom nixpkgs overlays
│   └── limine-install-patched.py  # Patched Limine install script
└── modules/
    ├── apps.nix              # User applications
    ├── desktop.nix           # Wayland, portals, polkit
    ├── dev.nix               # Docker, dev tools, languages
    ├── gaming.nix            # Steam, Gamemode, Wine
    ├── gpu-amd.nix           # AMD GPU drivers
    ├── limine-custom-labels.nix  # Custom boot entry labels
    ├── shell.nix             # Fish shell config
    ├── theming.nix           # Fonts, themes, cursors
    └── ...                   # Other modules
```

## Build Commands

```bash
# Test configuration without switching (recommended first)
sudo nixos-rebuild test --flake .#nixos

# Switch to new configuration
sudo nixos-rebuild switch --flake .#nixos

# Quick syntax validation
nix flake check

# Update all flake inputs
nix flake update

# Garbage collection
sudo nix-collect-garbage --delete-older-than 14d
```

## Code Style Guidelines

### File Structure

Each module follows this pattern:

```nix
# modules/example.nix
# Brief description of what this module does
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Module content here
}
```

### Formatting

- **Formatter**: `nixfmt`
- **Indentation**: 2 spaces (no tabs)
- **Line length**: ~100 chars, break long lists

### Naming Conventions

- **Files**: `kebab-case.nix` (e.g., `gpu-amd.nix`)
- **Options**: NixOS convention, camelCase (e.g., `extraGroups`)

### Comments & Headers

- Major sections: `# ═══ SECTION NAME ═══` (full line of `═`)
- Subsections: `# ─── Subsection ───` (full line of `─`)
- Inline comments for non-obvious settings

### Package Lists & Attribute Sets

```nix
environment.systemPackages = with pkgs; [
  # Category header
  package1
  package2
];

# Short sets inline: { enable = true; }
# Multi-line with indentation:
services.example = {
  enable = true;
  settings.Option = "value";
};
```

## Important Notes

1. **hardware-configuration.nix**: Auto-generated, never edit manually
2. **Username**: `pinj` - used throughout the config
3. **User groups**: Distributed across modules via `users.users.pinj.extraGroups`
4. **GUI apps**: Managed via `nix profile`, not system packages
5. **Unfree packages**: Enabled in `configuration.nix`
6. **State version**: `26.05` - don't change unless migrating

## Flake Inputs

| Input | Purpose |
|-------|---------|
| `nixpkgs` | NixOS unstable channel |
| `nix-cachyos-kernel` | CachyOS optimized kernel |
| `noctalia` | Desktop shell |

## Common Patterns

### Adding a New Module

1. Create `modules/newmodule.nix` with standard header
2. Add import to `configuration.nix`
3. Test with `sudo nixos-rebuild test --flake .#nixos`

### Adding System Packages

Add to the relevant module's `environment.systemPackages`:
```nix
environment.systemPackages = with pkgs; [
  newpackage
];
```

### Adding User to Group

```nix
users.users.pinj.extraGroups = [ "groupname" ];
```

### Using Flake Inputs

```nix
# Add inputs to module arguments
{ config, pkgs, inputs, lib, ... }:

{
  environment.systemPackages = [
    inputs.flakename.packages.${pkgs.system}.default
  ];
}
```

### Adding User GUI Apps

```bash
nix profile install nixpkgs#packagename
```

## Error Handling

- NixOS fails builds on errors - this is the primary validation
- Always test with `nixos-rebuild test` before `switch`
- Use `nix flake check` for quick syntax validation

## Custom Limine Boot Labels (MAINTENANCE REQUIRED)

**Files:**
- `modules/limine-custom-labels.nix` - Module that applies the patch
- `overlays/limine-install-patched.py` - Patched install script

**What it does:**
- Changes boot entries from "Generation XYZ" to "Linux 6.X.Y-cachyos - Generation XYZ"
- Removes "default profile" from group name (shows just "NixOS")
- Shows kernel version in all entries including specialisations

**How it works:**
The module imports the standard Limine module but overrides `system.build.installBootLoader` 
with a patched Python script that extracts kernel version from the kernel path.

**Maintenance burden:**
- **HIGH** - This will break when nixpkgs updates the limine module
- Check after every `nix flake update` by running `nixos-rebuild test`
- If it breaks, compare `overlays/limine-install-patched.py` with the upstream
  `nixos/modules/system/boot/loader/limine/limine-install.py` in nixpkgs
- Typical breakage: line number changes, function signature changes, new bootspec fields

**To fix breakage:**
1. Check current upstream script: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/system/boot/loader/limine/limine-install.py
2. Identify the changes needed
3. Re-apply the two key modifications:
   - Line ~550: Change `group_name = 'default profile'...` to `group_name = ''`
   - Add `get_kernel_version()` function and use it in `generate_config_entry()`
4. Test with `sudo nixos-rebuild test --flake .#nixos`
