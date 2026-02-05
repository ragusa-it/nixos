# atlas - NixOS Configuration

[![NixOS](https://img.shields.io/badge/NixOS-unstable-blue?logo=nixos)](https://nixos.org)
[![Flakes](https://img.shields.io/badge/Nix-Flakes-blue?logo=nixos)](https://nixos.wiki/wiki/Flakes)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

> A modular, declarative NixOS configuration for desktop gaming and development.

## Overview

This repository contains the complete NixOS system configuration for multiple hosts:

- **atlas** - Desktop gaming and media setup
- **server** - Headless server (core + dev tools only)
- **laptop** - Laptop with desktop environment (no gaming)

It uses Nix flakes for reproducible builds and modular organization for maintainability.

### System Highlights

- **OS**: NixOS (unstable channel)
- **Kernel**: CachyOS optimized kernel with x86_64-v3 microarchitecture
- **Bootloader**: Limine with Secure Boot support
- **Window Manager**: Niri (scrollable-tiling Wayland compositor)
- **Shell**: Fish with Zsh fallback
- **Terminal**: Ghostty
- **Browser**: Zen Browser + Firefox
- **Editor**: Zed

## Features

### Gaming
- Steam with Proton-GE
- Lutris, Heroic (Epic/GOG), Faugus Launchers
- GameMode optimizations
- MangoHud & vkBasalt support
- AMD GPU with ROCm acceleration

### Development
- Rust, Python, Node.js toolchains
- Docker & container tools
- Git, GitHub CLI, Lazygit
- Nix language server (nil, nixd)
- Claude Code & Opencode AI assistants

### Desktop Environment
- Custom Noctalia desktop shell
- Wayland portals for screen sharing
- Flatpak support with Flathub
- Nordic theming
- Plymouth boot splash

### Security & Privacy
- Full disk encryption (LUKS2)
- Encrypted swap partition
- Secure Boot with custom keys
- Bitwarden password manager
- Proton VPN

## Structure

```
.
├── flake.nix                  # Flake inputs and outputs
├── hosts/
│   ├── atlas/                 # Desktop configuration
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   ├── laptop/                # Laptop configuration
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   └── server/                # Server configuration
│       ├── configuration.nix
│       └── hardware-configuration.nix
├── modules/
│   ├── core/                  # Boot, users, networking
│   ├── hardware/              # GPU, audio, power
│   ├── desktop/               # WM, apps, theming
│   ├── services/              # System services
│   ├── dev/                   # Development tools
│   └── gaming/                # Steam, Wine, Gamemode
├── overlays/                  # Package patches
├── scripts/                   # Installation helpers
└── wallpaper/                 # Desktop backgrounds
```

## Installation

### Prerequisites
- NixOS installation media
- Internet connection
- Target disk (e.g., `/dev/nvme0n1`)

### Automated Install (Full Disk Encryption)

```bash
# Boot from NixOS ISO, then:
curl -sL https://raw.githubusercontent.com/ragusa-it/nixos/main/scripts/install-fde.sh | sudo bash
```

### Manual Install

```bash
# 1. Partition, format, and mount
cryptsetup luksFormat /dev/nvme0n1p3
cryptsetup open /dev/nvme0n1p3 cryptroot
mkfs.xfs /dev/mapper/cryptroot
mount /dev/mapper/cryptroot /mnt

# 2. Clone and install
git clone https://github.com/ragusa-it/nixos.git /mnt/etc/nixos
cd /mnt/etc/nixos

# Install for specific host (atlas, laptop, or server)
nixos-install --flake .#atlas
```

### Post-Install

```bash
# Set up Secure Boot (optional but recommended)
sudo /etc/nixos/scripts/setup-secureboot.sh

# Switch to new configuration
sudo nixos-rebuild switch --flake /etc/nixos
```

## Daily Usage

```bash
# Rebuild system (use appropriate host)
sudo nixos-rebuild switch --flake .#atlas

# Update flake inputs
nix flake update

# Clean old generations
sudo nix-collect-garbage -d

# Format all nix files
nixfmt **/*.nix
```

## Hardware Requirements

- **CPU**: AMD Ryzen (with x86_64-v3 support for CachyOS kernel)
- **GPU**: AMD Radeon (ROCm supported)
- **RAM**: 16GB+ recommended
- **Storage**: NVMe SSD recommended

## External Dependencies

This configuration uses the following flake inputs:

- [nixpkgs](https://github.com/NixOS/nixpkgs) - Main package repository
- [noctalia-shell](https://github.com/noctalia-dev/noctalia-shell) - Desktop environment
- [nix-cachyos-kernel](https://github.com/xddxdd/nix-cachyos-kernel) - Optimized kernel
- [zen-browser](https://github.com/youwen5/zen-browser-flake) - Zen Browser
- [opencode](https://github.com/anomalyco/opencode) - AI coding assistant

## Acknowledgments

- [NixOS](https://nixos.org/) - The purely functional Linux distribution
- [CachyOS](https://cachyos.org/) - Optimized kernel and packages
- [Limine](https://limine-bootloader.org/) - Modern bootloader
- [Niri](https://github.com/YaLTeR/niri) - Scrollable-tiling Wayland compositor

## License

This configuration is released into the public domain. Feel free to use, modify, and distribute as needed.

---

<p align="center">Made with ❄️ Nix</p>
