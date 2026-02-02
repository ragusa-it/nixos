# 🐧 Atlas - NixOS Configuration

A modular, flake-based NixOS configuration for a desktop workstation optimized for gaming, development, and daily use.

## ✨ Features

- **🎮 Gaming-Ready**: Steam, Proton-GE, Lutris, Heroic, Gamemode with AMD GPU optimizations
- **🖥️ Wayland-Native**: Niri compositor with modern Wayland tooling
- **⚡ Performance**: CachyOS kernel with scx_lavd scheduler for low-latency
- **🛠️ Development**: Docker, Node.js, Rust, Python, and modern CLI tools
- **🎨 Theming**: Adwaita dark theme, Papirus icons, JetBrains Mono fonts
- **🎵 Media**: Navidrome music server, PipeWire audio stack

## 📁 Structure

```
nixos/
├── flake.nix                 # Flake definition with inputs
├── flake.lock                # Locked dependencies
├── configuration.nix         # Main config (imports modules)
├── hardware-configuration.nix # Hardware-specific config
├── modules/
│   ├── apps.nix              # User applications (media, productivity, communication)
│   ├── audio.nix             # Bluetooth and audio controls
│   ├── desktop.nix           # Wayland, portals, polkit, desktop utilities
│   ├── dev.nix               # Docker, languages, build tools, CLI utilities
│   ├── gaming.nix            # Steam, Gamemode, Lutris, Wine/Proton
│   ├── gpu-amd.nix           # AMD drivers, Vulkan, VA-API, CoreCtrl
│   ├── navidrome.nix         # Music streaming server
│   ├── power.nix             # Power management, CPU governors
│   ├── services.nix          # System services (fstrim, zram, avahi)
│   ├── shell.nix             # Fish shell configuration
│   ├── theming.nix           # Fonts, GTK/Qt themes, cursors
│   └── virtualization.nix    # QEMU, KVM, virt-manager
└── .config/                  # Dotfiles for user applications
```

## 🚀 Flake Inputs

| Input | Description |
|-------|-------------|
| `nixpkgs` | NixOS unstable channel |
| `nix-cachyos-kernel` | CachyOS optimized kernel |
| `noctalia` | Noctalia shell |
| `zen-browser` | Zen Browser |
| `ghostty` | Ghostty terminal emulator |
| `opencode` | OpenCode |
| `vicinae` | Vicinae launcher |

## 📦 Installation

### Prerequisites

- NixOS installed with flakes enabled
- AMD GPU (configuration is AMD-specific)

### Steps

1. **Clone this repository:**
   ```bash
   git clone https://github.com/yourusername/nixos.git /etc/nixos
   ```

2. **Generate hardware configuration:**
   ```bash
   sudo nixos-generate-config --show-hardware-config > /etc/nixos/hardware-configuration.nix
   ```

3. **Update the user configuration** in `configuration.nix`:
   - Change `users.users.pinj` to your username
   - Update `networking.hostName` if desired
   - Adjust timezone in `time.timeZone`

4. **Rebuild the system:**
   ```bash
   sudo nixos-rebuild switch --flake .#nixos
   ```

5. **Set up Flathub** (after first boot):
   ```bash
   flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
   ```

## 🔧 Usage

### Rebuild System

```bash
# Test configuration without switching
sudo nixos-rebuild test --flake .#nixos

# Switch to new configuration
sudo nixos-rebuild switch --flake .#nixos

# Build and set as boot default (without switching)
sudo nixos-rebuild boot --flake .#nixos
```

### Update Flake Inputs

```bash
# Update all inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs
```

### Garbage Collection

Automatic garbage collection is configured weekly, but you can run it manually:

```bash
# Collect garbage older than 14 days
sudo nix-collect-garbage --delete-older-than 14d

# Optimize store
nix-store --optimise
```

## 🖥️ Desktop Environment

- **Compositor**: Niri (scrollable tiling Wayland compositor)
- **Display Manager**: Ly
- **Launcher**: Vicinae
- **Terminal**: Ghostty
- **Browser**: Zen Browser, Firefox
- **File Manager**: Nautilus

## 🎮 Gaming

The gaming module provides:

- **Steam** with Proton-GE for enhanced Windows game compatibility
- **Gamemode** for automatic performance optimizations
- **Lutris** for non-Steam games
- **Heroic** for Epic Games and GOG
- **Gamescope** micro-compositor for problematic games
- **MangoHud** (via dotfiles) for in-game overlays

### AMD GPU Optimizations

- CoreCtrl for fan curves and overclocking
- Full power management features enabled
- RADV (Mesa Vulkan) driver
- VA-API hardware video acceleration

## 🛠️ Development

Included tools:

- **Languages**: Node.js 22, Python 3, Rust (via rustup), Bun
- **Containers**: Docker with auto-prune, docker-compose, lazydocker
- **Git**: lazygit, gh (GitHub CLI), delta (better diffs)
- **CLI**: ripgrep, fd, fzf, eza, bat, jq, yq, and more
- **Editors**: Zed, VS Code (config), micro

## 🎵 Audio & Media

- **Audio Stack**: PipeWire with JACK support
- **Bluetooth**: Enabled with experimental features
- **Music Server**: Navidrome for self-hosted streaming
- **Music Client**: Feishin
- **Video**: MPV, Celluloid, OBS Studio

## ⚙️ Key Services

| Service | Description |
|---------|-------------|
| Tailscale | Mesh VPN |
| OpenSSH | Remote access |
| Navidrome | Music streaming server |
| Avahi | Local network discovery |
| Profile-sync-daemon | Browser profile in tmpfs |
| ZRAM | Compressed swap in RAM |

## 📝 Notes

- **Kernel**: Uses CachyOS kernel with x86_64-v3 optimizations
- **Scheduler**: scx_lavd for low-latency gaming performance
- **Shell**: Fish is the default shell (Zsh available as fallback)
- **Unfree packages**: Enabled (Steam, Discord, etc.)
- **State Version**: 26.05

## 📄 License

This configuration is provided as-is for personal use and reference.