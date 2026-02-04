# Atlas - NixOS Desktop Configuration

A modular, flake-based NixOS configuration for a high-performance desktop workstation with AMD GPU, optimized for gaming and development.

## Features

- **Nix Flakes** - Reproducible, declarative system configuration
- **CachyOS Kernel** - Performance-optimized kernel with sched-ext scheduler
- **Wayland Desktop** - Niri compositor with Noctalia shell
- **AMD GPU** - Full Vulkan, VA-API, and overclocking support via CoreCtrl
- **Gaming Ready** - Steam, Proton-GE, Gamemode, Gamescope, Wine, Lutris
- **Development** - Docker, direnv, modern CLI tools, multiple language runtimes
- **Audio** - PipeWire with high-quality Bluetooth codecs (LDAC, AAC, aptX)
- **Secure Boot** - Limine bootloader with Secure Boot support

## Quick Start

```bash
# Clone the repository
git clone https://github.com/ragusa-it/nixos.git
cd nixos

# Test configuration (recommended first)
sudo nixos-rebuild test --flake .#nixos

# Apply configuration
sudo nixos-rebuild switch --flake .#nixos
```

## Repository Structure

```
nixos/
├── flake.nix                   # Flake inputs and outputs
├── flake.lock                  # Pinned dependency versions
├── configuration.nix           # Main config (imports all modules)
├── hardware-configuration.nix  # Auto-generated hardware config
├── AGENTS.md                   # Guidelines for AI agents
└── modules/
    ├── apps.nix                # User applications
    ├── audio.nix               # PipeWire & Bluetooth audio
    ├── boot-plymouth.nix       # Plymouth boot splash
    ├── desktop.nix             # Wayland, portals, polkit
    ├── dev.nix                 # Docker, dev tools, languages
    ├── gaming.nix              # Steam, Gamemode, Wine
    ├── gpu-amd.nix             # AMD GPU drivers & tools
    ├── navidrome.nix           # Music streaming server
    ├── power.nix               # Power management
    ├── services.nix            # System services
    ├── shell.nix               # Fish shell config
    └── theming.nix             # Fonts, themes, cursors
```

## Flake Inputs

| Input | Description |
|-------|-------------|
| `nixpkgs` | NixOS unstable channel |
| `nix-cachyos-kernel` | CachyOS performance-optimized kernels |
| `noctalia` | Noctalia desktop shell |
| `zen-browser` | Zen Browser (Firefox fork) |
| `opencode` | AI coding assistant |

## Module Overview

### Desktop Environment

| Component | Choice |
|-----------|--------|
| Compositor | Niri (Wayland) |
| Shell | Noctalia |
| Display Manager | Ly |
| Terminal | Ghostty |
| File Manager | Nautilus |
| Editor | Zed |
| Browser | Zen Browser, Firefox |

### Hardware Configuration

| Hardware | Configuration |
|----------|---------------|
| CPU | AMD Ryzen with `amd_pstate=active` |
| GPU | AMD with RADV, VA-API, CoreCtrl |
| Audio | PipeWire (ALSA, PulseAudio, JACK) |
| Bluetooth | Enabled with LDAC, AAC, aptX codecs |

### Gaming Stack

| Component | Description |
|-----------|-------------|
| Steam | With Proton-GE, remote play, LAN transfers |
| Gamemode | CPU/GPU optimization during gaming |
| Gamescope | Micro-compositor for games |
| Lutris | Game launcher |
| Heroic | Epic/GOG launcher |
| Wine | Latest staging with winetricks |
| Scheduler | `scx_lavd` low-latency scheduler |

### Development Tools

| Category | Tools |
|----------|-------|
| Containers | Docker, docker-compose, lazydocker |
| Languages | Node.js, Bun, Python, Rust |
| Build | gcc, cmake, make, pkg-config |
| Version Control | git, gh, lazygit, delta |
| CLI | ripgrep, fd, fzf, eza, bat, jq, yq |

## Shell Aliases

The Fish shell is configured with useful aliases:

```bash
# NixOS
rebuild          # sudo nixos-rebuild switch --flake .
rebuild-test     # sudo nixos-rebuild test --flake .
update           # nix flake update
gc-nix           # sudo nix-collect-garbage -d

# Git shortcuts
gs, gd, gl, ga, gc, gp, gpu, gco, gb

# Docker shortcuts
dc, dps, dpa, dl, dex

# Modern replacements
ll, ls, cat, find, grep, df, du  # → eza, bat, fd, rg, duf, dust
```

## Common Tasks

### Rebuild System

```bash
# Test without switching (dry-run)
sudo nixos-rebuild test --flake .#nixos

# Apply changes
sudo nixos-rebuild switch --flake .#nixos

# Rebuild for next boot only
sudo nixos-rebuild boot --flake .#nixos
```

### Update Dependencies

```bash
# Update all flake inputs
nix flake update

# Update specific input
nix flake update nixpkgs
```

### Garbage Collection

```bash
# Manual cleanup (removes generations older than 14 days)
sudo nix-collect-garbage --delete-older-than 14d

# List generations
nix-env --list-generations

# Remove all old generations
sudo nix-collect-garbage -d
```

### Package Management

```bash
# Search for packages
nix search nixpkgs <package>

# Install user GUI apps (via nix profile)
nix profile install nixpkgs#<package>

# Update user apps
nix profile upgrade '.*'

# List installed user apps
nix profile list
```

### Validate Configuration

```bash
# Quick syntax check
nix flake check

# Show flake outputs
nix flake show
```

## Services

| Service | Port | Description |
|---------|------|-------------|
| Navidrome | 4533 | Music streaming (localhost only) |
| Tailscale | - | Mesh VPN |
| SSH | 22 | Remote access |

## System Optimizations

- **ZRAM Swap** - Compressed RAM swap with zstd
- **SSD TRIM** - Weekly fstrim for SSD longevity
- **EarlyOOM** - Prevents system freeze on memory exhaustion
- **Profile Sync Daemon** - Browser profiles in RAM
- **Auto GC** - Weekly garbage collection of old generations

## Kernel Tweaks

```nix
# Gaming optimizations
"fs.inotify.max_user_watches" = 524288  # Large games support
"vm.swappiness" = 10                     # Prefer RAM over swap
"vm.vfs_cache_pressure" = 50             # Keep directory caches
```

## Theming

| Element | Choice |
|---------|--------|
| GTK Theme | adw-gtk3-dark |
| Icons | Papirus-Dark |
| Cursor | Adwaita (24px) |
| Fonts | Inter (UI), JetBrains Mono Nerd Font (mono) |
| Color Scheme | Dark |

Configure with `nwg-look` or `dconf-editor`.

## Adding New Modules

1. Create `modules/newmodule.nix`:

```nix
# modules/newmodule.nix
# Brief description
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Module content
}
```

2. Add import to `configuration.nix`:

```nix
imports = [
  # ...
  ./modules/newmodule.nix
];
```

3. Test: `sudo nixos-rebuild test --flake .#nixos`

## Troubleshooting

### Build Fails

```bash
# Check for syntax errors
nix flake check

# Build with verbose output
sudo nixos-rebuild switch --flake .#nixos --show-trace
```

### Rollback

```bash
# Boot into previous generation from bootloader menu
# Or switch to specific generation:
sudo nixos-rebuild switch --rollback
```

### GPU Issues

```bash
# Check Vulkan
vulkaninfo | grep deviceName

# Check VA-API
vainfo

# Monitor GPU
nvtop
radeontop
```

### Audio Issues

```bash
# Check PipeWire status
systemctl --user status pipewire pipewire-pulse wireplumber

# Restart audio stack
systemctl --user restart pipewire pipewire-pulse wireplumber
```

## Notes

- **State Version**: `26.05` - Do not change unless migrating
- **Username**: `pinj` - Configured throughout the system
- **Locale**: English (US) with German regional settings
- **Keyboard**: German (nodeadkeys)
- **Timezone**: Europe/Berlin

## License

Personal configuration. Feel free to use as inspiration for your own setup.
